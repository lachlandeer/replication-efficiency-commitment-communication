# --- Libraries --- #

library(readr)
library(dplyr)
library(optparse)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a csv file with subjects data",
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

#--- Effort stored in Subjects Table --- # 
subjects <- 
    read_csv(opt$data)

#--- Get treatment specific effort variable name --- #
standard_cheap_talk <-
    subjects %>%
    filter(treatment == "Standard Cheap Talk") %>%
    select(subject_id, period, choice = answers)

revision_cheap_talk <-
    subjects %>%
    filter(treatment == "Revision Cheap Talk") %>%
    select(subject_id, period, choice = answer)

revision_cheap_talk_mem <-
    subjects %>%
    filter(treatment == "Revision Cheap Talk Memory") %>%
    select(subject_id, period, choice = answers)

richer_cheap_talk <-
    subjects %>%
    filter(treatment == "Richer RCT") %>%
    select(subject_id, period, choice = answers)

# --- Bind Treatments Together --- #
decisions_cheaptalk <-
    richer_cheap_talk %>%
    bind_rows(
        revision_cheap_talk_mem, 
        revision_cheap_talk,
        standard_cheap_talk
          )

# --- Save to File --- #
write_csv(decisions_cheaptalk, opt$out)
