# --- Libraries --- #
library(readr)
library(dplyr)
library(optparse)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a csv file with subjects decisions",
                metavar = "character"
                ),
    make_option(c("-p", "--payoffFunction"),
                type = "character",
                default = NULL,
                help = "an R script with payoff function that can be mapped onto a dataframe",
                metavar = "character"
                ),
	make_option(c("-o", "--out"),
                type = "character",
                default = "decisions_payoffs.csv",
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
if (is.null(opt$payoffFunction)){
  print_help(opt_parser)
  stop("Payoff Function must be provided", call. = FALSE)
}

# --- Load Data --- #
df <- read_csv(opt$data)

# get the function that computes payoffs
source(opt$payoffFunction)

# --- Add Payoffs --- #
# different payoff functions for VHBB treatment
subjects_payoffs <-
    df %>%
    filter(treatment != "RM VHBB") %>%
    compute_payoff(effort_col = "choice", group_col = "group_id_unique", time = "period")

subjects_payoffs_vhbb <-
    df %>%
    filter(treatment == "RM VHBB") %>%
    compute_payoff(effort_col = "choice", group_col = "group_id_unique", time = "period",
                   gamma = 0.6, alpha = 0.2, beta = 0.1)

# --- Bind Treatments --- #
subjects_payoffs <-
    subjects_payoffs %>%
    rbind(subjects_payoffs_vhbb)

# --- Save --- #
write_csv(subjects_payoffs, opt$out)