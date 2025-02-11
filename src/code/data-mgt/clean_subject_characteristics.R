# --- Libraries --- #
library(dplyr)
library(readr)
library(purrr)
library(tidyr)
library(janitor)
library(stringr)
library(optparse)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-d", "--datapath"),
                type = "character",
                default = NULL,
                help = "a path to where survey data is stored",
                metavar = "character"
                ),
    make_option(c("-t", "--treatments"),
                type = "character",
                default = NULL,
                help = "a csv file to where data mapping treatment times to treatments is stored",
                metavar = "character"
                ),
    make_option(c("-s", "--subjects"),
                type = "character",
                default = NULL,
                help = "a csv file of the aggregated data from ztree subjects tables",
                metavar = "character"
                ),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out_subjects.csv",
                help = "output file name [default = %default]",
                metavar = "character"
                )
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$datapath)){
  print_help(opt_parser)
  stop("Path to characteristics data must be provided", call. = FALSE)
}
if (is.null(opt$subjects)){
  print_help(opt_parser)
  stop("Subjects data must be provided", call. = FALSE)
}
if (is.null(opt$treatments)){
  print_help(opt_parser)
  stop("Treatment data must be provided", call. = FALSE)
}

# --- Helper Functions --- #
# Function to extract datetime as a string (keeping original format)
extract_datetime <- function(file_path) {
    str_extract(basename(file_path), "\\d{6}_\\d{4}")  # Extract "151209_1044"
}

# Function to read, transpose, and add datetime
read_and_transpose <- function(file) {
    read_csv(file, col_names = FALSE) %>%
        pivot_longer(-X1, names_to = "subject", values_to = "value") %>%
        pivot_wider(names_from = X1, values_from = "value") %>%
        mutate(datetime = extract_datetime(file))  # Add datetime column (as string)
}

# --- Load Data --- #
# Define the directory containing the survey files
survey_dir <- opt$datapath  # Change this to match your actual path

subjects <- read_csv(opt$subjects)

treatment_table <- 
    read_csv(opt$treatments) %>%
    clean_names()

# List all survey files
files <- list.files(survey_dir, full.names = TRUE) %>%
    keep(~ str_detect(.x, "survey\\.csv$"))  # Keep only files ending in "survey.csv"

# Read and combine all survey files
message("Loading survey data")
df_combined <- files %>%
    map_dfr(read_and_transpose, .id = "file_name") %>%  # Keep file names for reference
    janitor::clean_names() %>%
    select(datetime, subject = subject_2, client, sex, major, other, gpa, game_theory)


# ---  Add Treatment Data to characteristics data --- #

survey_w_id <-
    df_combined %>%
    left_join(treatment_table, by = join_by(datetime == session_code)) %>%
    # add a unique identifier using hashing
    rowwise() %>%
    mutate(subject_id = digest::digest(paste(subject, treatment, session), 
                                       algo = "md5")
    ) %>%
    ungroup() %>%
    mutate(gpa_missing = if_else (gpa == -1, TRUE, FALSE),
           gpa = as.numeric(gpa),
           gpa_mean = mean(gpa[gpa != -1], na.rm = TRUE),
    # paper does mean imputation for missing GPA's 
           gpa_imputed = case_when(
               gpa == -1 ~ gpa_mean,
                .default = gpa
           )
    ) %>%
    select(datetime, subject, subject_id, client, sex, major, other, gpa, gpa_missing, gpa_imputed, game_theory)

# --- Add Quiz Answers from Subjects table so can use as a control variable --- #
subjects_quiz <- 
    subjects %>%
    filter(period == 1) %>%
    select(subject_id, treatment, starts_with("input"))

# Define correct answers for each treatment
correct_answers <- list(
    default = c(0.42, .5, .62, .82, .74),  # Expected values for all treatments except VHBB
    vhbb = c(0.6, 0.8, 0.8, 1, 0.8)   # Expected values for VHBB
)

# Verify row-wise and count correct matches
subjects_quiz_n_correct <- 
    subjects_quiz %>%
    mutate(quiz_ans = if_else(treatment == "RM VHBB", "vhbb", "default")) %>%
    rowwise() %>%
    # count based on the correct quiz answers -- which are different for VHBB
    mutate(correct_count = sum(c_across(input11:input15) == correct_answers[[quiz_ans]])) %>%
    ungroup() %>%
    select(subject_id, correct_count)

# --- Bring together --- # 
subject_characteristics <-
    survey_w_id %>%
    inner_join(subjects_quiz_n_correct, by = join_by(subject_id))

# --- Save File --- #
write_csv(subject_characteristics, opt$out)