library(readr)
library(dplyr)
library(jsonlite)
library(optparse)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-s", "--standard"),
                type = "character",
                default = NULL,
                help = "a csv file with the simulated payoffs under standard parametrization",
                metavar = "character"
                ),
    make_option(c("-v", "--vhbb"),
                type = "character",
                default = NULL,
                help = "a csv file with the simulated payoffs under vhbb parametrization",
                metavar = "character"
                ),
	make_option(c("-o", "--out"),
                type = "character",
                default = "simulated_payoffs.csv",
                help = "output file name [default = %default]",
                metavar = "character"
                )
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$standard)){
  print_help(opt_parser)
  stop("Simulated Payoffs must be provided", call. = FALSE)
}
if (is.null(opt$vhbb)){
  print_help(opt_parser)
  stop("Simulated Payoffs for VHBB specification must be provided", call. = FALSE)
}

# --- Load Libraries --- #
df <- 
    read_csv(opt$standard)

df_vhbb <- 
    read_csv(opt$vhbb)

# --- Get Max and Min Payoff Profiles for Standard Parameterization --- #
# max avg indiv earning
out_high <- 
    df %>%
    slice_max(avg_group_payoff, n =1) %>%
    mutate(condition = "highest")

# min avg indiv earnings
out_low <- 
    df %>%
    ungroup() %>%
    slice_min(avg_group_payoff, n = 1, with_ties = FALSE) %>%
    mutate(condition = "lowest")

out <- 
    rbind(out_high, out_low) %>%
    mutate(payoffs = "standard")

# --- Get Max and Min Payoff Profiles for VHBB Parameterization --- #
# max indiv earning
out_high_vhbb <- 
    df_vhbb %>%
    slice_max(avg_group_payoff, n =1) %>%
    mutate(condition = "highest")

# min indiv earnings
out_low_vhbb <- 
    df_vhbb %>%
    slice_min(avg_group_payoff, n = 1, with_ties = FALSE) %>%
    mutate(condition = "lowest")

out_vhbb <- 
    rbind(out_high_vhbb, out_low_vhbb) %>%
    mutate(payoffs = "vhbb")

# --- Merge --- #
out <-
    rbind(out, out_vhbb)

# --- Save --- #
# Save as JSON
write_json(out, 
           path = opt$out, 
           pretty = TRUE, 
           auto_unbox = TRUE
           )