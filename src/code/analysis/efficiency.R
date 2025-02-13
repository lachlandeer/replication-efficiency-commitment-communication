# --- Libraries --- #
library(readr)
library(dplyr)
library(jsonlite)
library(optparse)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a csv file subject decisions and payoffs",
                metavar = "character"
                ),
    make_option(c("-p", "--payoffs"),
                type = "character",
                default = NULL,
                help = "a json file with the max and min payoffs for each parametrization",
                metavar = "character"
                ),
	make_option(c("-o", "--out"),
                type = "character",
                default = "efficiency.csv",
                help = "output file name [default = %default]",
                metavar = "character"
                )
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("Decisions and Payoffs data must be provided", call. = FALSE)
}
if (is.null(opt$payoffs)){
  print_help(opt_parser)
  stop("Scaling Payoffs must be provided", call. = FALSE)
}

# --- Data Loading --- #
df <- 
    read_csv(opt$data)

payoffs_profiles <- 
    fromJSON(opt$payoffs) 

# --- Select the Payoffs Needed to compute efficiency ---# 
min_payoff <-
    payoffs_profiles %>%
    filter(payoffs == "standard", condition == "lowest") %>%
    select(avg_group_payoff) %>%
    pull()

max_payoff <-
    payoffs_profiles %>%
    filter(payoffs == "standard", condition == "highest") %>%
    select(avg_group_payoff) %>%
    pull()

min_payoff_vhbb <-
    payoffs_profiles %>%
    filter(payoffs == "vhbb", condition == "lowest") %>%
    select(avg_group_payoff) %>%
    pull()

max_payoff_vhbb <-
    payoffs_profiles %>%
    filter(payoffs == "vhbb", condition == "highest") %>%
    select(avg_group_payoff) %>%
    pull()

# --- Overall Efficiency --- #
# Use all periods, aggregate metric
efficiency <-
    df %>%
    group_by(treatment_simple) %>%
    summarize(efficiency = (mean(payoff) - min_payoff) / (max_payoff - min_payoff),
              se = sd(payoff, na.rm = TRUE) / sqrt(n()) / (max_payoff - min_payoff),
              efficiency_vhbb = (mean(payoff) - min_payoff_vhbb) / (max_payoff_vhbb - min_payoff_vhbb),
              se_vhbb = sd(payoff, na.rm = TRUE) / sqrt(n()) / (max_payoff_vhbb - min_payoff_vhbb)
              ) %>%
    # adjust for VHBB payoffs
    mutate(
        efficiency = if_else(treatment_simple == "RM VHBB",
                             efficiency_vhbb,
                             efficiency),
        se = if_else(treatment_simple == "RM VHBB",
                             se_vhbb,
                             se)
    ) %>%
    ungroup() %>%
    select(treatment_simple, efficiency, se)


# --- Efficiency by Round --- #
efficiency_by_round <-
    df %>%
    group_by(treatment_simple, period) %>%
    summarize(efficiency = (mean(payoff) - min_payoff) / (max_payoff - min_payoff),
              se = sd(payoff, na.rm = TRUE) / sqrt(n()) / (max_payoff - min_payoff),
              efficiency_vhbb = (mean(payoff) - min_payoff_vhbb) / (max_payoff_vhbb - min_payoff_vhbb),
              se_vhbb = sd(payoff, na.rm = TRUE) / sqrt(n()) / (max_payoff_vhbb - min_payoff_vhbb)
    ) %>%
    # adjust for VHBB payoffs
    mutate(
        efficiency = if_else(treatment_simple == "RM VHBB",
                             efficiency_vhbb,
                             efficiency),
        se = if_else(treatment_simple == "RM VHBB",
                     se_vhbb,
                     se)
    ) %>%
    ungroup() %>%
    select(treatment_simple, period, efficiency, se)

# --- Bind measures into single frame --- #
efficiency <-
    efficiency %>%
    mutate(period = "overall") %>%
    rbind(efficiency_by_round)

# --- Save --- #
write_csv(efficiency, opt$out)