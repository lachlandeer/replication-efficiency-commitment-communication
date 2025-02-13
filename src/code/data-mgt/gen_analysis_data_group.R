#---- Libraries --- #
library(readr)
library(dplyr)
library(optparse)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a csv file with decisions and pyaoffs from ALL treatments",
                metavar = "character"
                ),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out_analysis.csv",
                help = "output file name [default = %default]",
                metavar = "character"
                )
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("Subject data with decisions and payofffs must be provided", call. = FALSE)
}


# --- Load Data --- #
message("Loading Data")
in_data <- opt$data

df <- 
    read_csv(in_data) 

# --- Creating Group Outcome Variables ---# 

message("Creating outcome variables")
group_level <-
    df %>%
    group_by(treatment, group_id_unique, period) %>%
    summarize(min_effort = min(choice),
              # if each group has one distinct value, then they've coordinated on it
              full_coord = n_distinct(choice) == 1,
              # how often is a seven chosen
              num_sevens = sum(choice == 7, na.rm = TRUE) / n()
              
    ) %>%
    ungroup()

# --- Save --- #
message("Saving")
write_csv(group_level, opt$out)
