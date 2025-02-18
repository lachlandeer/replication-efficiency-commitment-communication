library(readr)
library(dplyr)
library(gt)
library(optparse)

option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a csv of group summary stats",
                metavar = "character"
                ),
	make_option(c("-o", "--out"),
                type = "character",
                default = "summary_stats.tex",
                help = "output file name [default = %default]",
                metavar = "character"
                )
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("Group level summary stats must be provided", call. = FALSE)
}

# --- Load Data --- #
df <- 
    read_csv(opt$data)

# --- Make Table --- #
tab <-
    df %>%
    arrange(payoff) %>%
    select(treatment, payoff, choice, min_effort, num_sevens, full_coord, eqn_dev) %>%
    gt() %>%
    fmt_number(decimals = 3) %>%
    cols_label(
        treatment = "Treatment",
        choice = "Effort",
        payoff = "Payoff",
        min_effort = "Min. Effort",
        num_sevens = "Freq 7s",
        full_coord = "Fully Coord",
        eqn_dev = "Equil. Dev."
    ) %>%
    text_case_match(
        "Baseline" ~ "B",
        "Standard Cheap Talk" ~ "S-CT",
        "Standard Revision Mechanism" ~ "S-RM",
        "Revision Cheap Talk" ~ "R-CT",
        "Richer RCT" ~ "R-R-CT",
        "Infrequent Revision Mechanism" ~ "I-RM",
        "Random RM" ~ "R-RM",
        "Revision Mechanism" ~ "RM",
        "RM VHBB" ~ "RM-VHBB",
        "Synchronous RM" ~ "S-RM"
    ) 

# --- Save --- #
gtsave(tab, opt$out) 
