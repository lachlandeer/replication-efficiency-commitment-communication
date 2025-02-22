# --- Libraries --- #

library(readr)
library(dplyr)
library(stringr)
library(tidyr)
library(optparse)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a csv file with globals data",
                metavar = "character"
                ),
    make_option(c("-l", "--length"),
                type = "character",
                default = NULL,
                help = "number of seconds a period lasts",
                metavar = "character"
                ),
    make_option(c("-s", "--subjects"),
                type = "character",
                default = NULL,
                help = "subject choices data",
                metavar = "character"
                ),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out_messages.csv",
                help = "output file name [default = %default]",
                metavar = "character"
                )
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("Input data must be provided", call. = FALSE)
}
if (is.null(opt$subjects)){
  print_help(opt_parser)
  stop("Subjects data must be provided", call. = FALSE)
}
if (is.null(opt$length)){
  print_help(opt_parser)
  stop("Length of period in seconds must be provided", call. = FALSE)
}

#--- Effort stored in Globals Table --- # 
globals <- 
    read_csv(opt$data)

# map subject ids back to groups
subjects_group <- 
    read_csv(opt$subjects)  %>%
    filter(treatment_simple %in% c("Revision Cheap Talk")) %>%
    group_by(subject_id) %>%
    summarise(group_id = unique(group_id_unique))

# Parameters 
n_period_length <- as.numeric(opt$length)

# --- Get Final Messages --- #
subject_final_message <- 
    globals %>%
    filter(treatment_simple %in% c("Revision Cheap Talk")) %>%
    #mutate(treatment = "Revision Cheap Talk") %>%
    select(date, treatment, session, treatment_simple,
            num_subjects, group_size, period, 
            starts_with("decision_")
            ) %>%
    pivot_longer(cols = starts_with("decision_")) %>%
    filter(!str_detect(name, "decision_[[:digits]]")) %>%
    filter(!is.na(value)) %>%
    # for each session since we need to work with the num of subjects in a session to correctly extract positions in the decisions columns
    group_by(date) %>%
    mutate(subject = rep(1:max(num_subjects), length.out = n())) %>%
    arrange(date, subject, period) %>%
    ungroup() %>%
    # add a unique identifier using hashing
    rowwise() %>%
    mutate(subject_id = digest::digest(paste(subject, treatment, session), 
                                       algo = "md5")
    ) %>%
    # which second did the decision happen
    group_by(subject_id, treatment_simple, period) %>%
    mutate(second = row_number()) %>%
    inner_join(subjects_group, by = join_by(subject_id)) %>%
    select(subject_id, group_id, treatment_simple, period, name, second, choice = value) %>%
    ungroup() %>%
    filter(second == n_period_length) %>%
    mutate(time = "pre-play") %>%
    select(group_id, period, subject_id, choice, time)

# --- Save to File --- #
write_csv(subject_final_message, opt$out)
