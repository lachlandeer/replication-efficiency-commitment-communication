#--- Libraries --- #
library(readr)
library(zTree)
library(janitor)
library(dplyr)
library(optparse)
library(purrr)
library(stringr)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-d", "--datapath"),
                type = "character",
                default = NULL,
                help = "a path to where data is stored",
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
                default = "out_subjects.csv",
                help = "output file name [default = %default]",
                metavar = "character"
                ),
	make_option(c("-g", "--globals"),
                type = "character",
                default = "out_globals.csv",
                help = "output file name [default = %default]",
                metavar = "character"
                )
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$datapath)){
  print_help(opt_parser)
  stop("Input data path must be provided", call. = FALSE)
}
if (is.null(opt$treatments)){
  print_help(opt_parser)
  stop("Treatment mapping must be provided", call. = FALSE)
}

# --- Loading Data --- #
message("Loading data")
filepath <- opt$datapath
print(filepath)
ext <- ".csv"

treatment_table <- 
    read_csv(opt$treatments) %>%
    clean_names()

# remark
# 210323_1637.csv is missing
# should be 210324_1613

file_list <-
    treatment_table %>%
    select(session_code) %>%
    pull() %>%
    map_chr(~ str_c(filepath, ., ext))


message("Loading ztree data")
ztree_out <-
    zTreeTables(file_list, 
                tables = c("globals", 
                           "subjects"),
                sep = ",", 
                ignore.errors = TRUE)

# --- Subjects Table --- #
message("working with subjects data")
subjects <- 
    ztree_out$subjects %>%
    clean_names() %>%
    select(date, period, subject, group, group_id, 
           role, choices, 
           everything()
           ) %>%
    select(-treatment) %>%
    arrange(date, group_id, period, role)


# add treatment data to subjects table
subjects_w_treatment <-
    subjects %>%
    left_join(treatment_table, by = join_by(date == session_code)) %>%
    # add a unique identifier using hashing
    rowwise() %>%
    mutate(subject_id = digest::digest(paste(subject, treatment, session), 
                                                        algo = "md5")
           ) %>%
    rowwise() %>%
    mutate(group_id_unique = digest::digest(paste(group_id, date), 
                              algo = "md5")
    ) %>%
    select(date, treatment, session, treatment_simple, group_id, group_id_unique, 
           period, subject, subject_id, role, 
           choices, everything()
           )

# --- globals table
# lots of data used in the analysis is stored in the globals table
# we'll format it and save it
message("Working with globals table")

globals <- 
    ztree_out$globals %>%
    clean_names() %>%
    select(date, treatment, period, num_subjects, group_size, num_groups, 
            starts_with("choice"), 
            starts_with("decision")
            ) %>%
    left_join(treatment_table, 
              by = join_by(date == session_code)
              ) %>%
    select(date, treatment = treatment.y, 
           session, treatment_simple, period, 
           everything()
           )

# --- Save Data --- #
message("Saving Data")
write_csv(subjects_w_treatment, opt$subjects)
write_csv(globals, opt$globals)    