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
baseline_decisions <-
    subjects %>%
    filter(treatment == "Baseline") %>%
    select(subject_id, period, choice = choices)

# --- Bind Treatments Together --- #

# --- Save to File --- #
write_csv(baseline_decisions, opt$out)
