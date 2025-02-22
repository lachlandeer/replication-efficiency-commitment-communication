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
    make_option(c("-", "--length"),
                type = "character",
                default = NULL,
                help = "number of seconds a period lasts",
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

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("Input data must be provided", call. = FALSE)
}
if (is.null(opt$length)){
  print_help(opt_parser)
  stop("Length of period in seconds must be provided", call. = FALSE)
}

#--- Effort stored in Globals Table --- # 
globals <- 
    read_csv(opt$data)

# Parameters 
n_period_length <- as.numeric(opt$length)

#--- Get treatment specific effort variable name --- #
rev_mechanism_decisions <-
    globals %>%
    filter(treatment_simple %in% c("Revision Mechanism", 
                                   "Random RM", 
                                   "Infrequent Revision Mechanism", 
                                   "Synchronous RM",
                                   "RM VHBB"
                                   )
           ) %>%
    select(date, treatment, session, treatment_simple, 
            num_subjects, group_size, period, 
            starts_with("decision_")
            ) %>%
    # decisions are stored in columns called "decision"
    pivot_longer(cols = starts_with("decision_")) %>%
    filter(!str_detect(name, "decision_[[:digits]]")) %>%
    filter(!is.na(value)) %>%
    slice(seq(1, n(), by = 60)) %>%
    #filter(name == "decision_1") 
    group_by(treatment, date) %>%
    mutate(subject = rep(1:max(num_subjects), length.out = n())) %>%
    arrange(date, treatment, subject, period) %>%
    ungroup() %>%
    # add a unique identifier using hashing
    rowwise() %>%
    mutate(subject_id = digest::digest(paste(subject, treatment, session), 
                                       algo = "md5")
    ) %>%
    select(date, treatment, treatment_simple, subject_id, period, name, choice = value)

# --- Save to File --- #
write_csv(rev_mechanism_decisions, opt$out)
