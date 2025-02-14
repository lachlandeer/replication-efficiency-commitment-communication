# --- Load Libraries --- #
library(readr)
library(rstatix)
library(dplyr)
library(jsonlite)
library(optparse)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-i", "--initial"),
                type = "character",
                default = NULL,
                help = "a csv file with initial decisions in the revision treatments",
                metavar = "character"
                ),
    make_option(c("-c", "--choices"),
                type = "character",
                default = NULL,
                help = "a csv file with choices of subjects",
                metavar = "character"
                ),
    make_option(c("-b", "--binomial"),
                type = "character",
                default = "binomial.json",
                help = "a json file to store binomial test results [default = %default]",
                metavar = "character"
                ),
    make_option(c("-p", "--payoffs"),
                type = "character",
                default = NULL,
                help = "a json file with the max and min payoffs for each parametrization",
                metavar = "character"
                ),
	make_option(c("-m", "--mwu"),
                type = "character",
                default = "mwu.csv",
                help = "output file name for mann whitney test result [default = %default]",
                metavar = "character"
                )
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$initial)){
  print_help(opt_parser)
  stop("Initial choices data must be provided", call. = FALSE)
}
if (is.null(opt$choices)){
  print_help(opt_parser)
  stop("Decisions data must be provided", call. = FALSE)
}
if (is.null(opt$payoffs)){
  print_help(opt_parser)
  stop("Scaling Payoffs must be provided", call. = FALSE)
}

# --- Load Data ---# 
df_initial <- 
    read_csv(opt$initial) %>%
    filter(treatment_simple == "Revision Mechanism") %>%
    mutate(is_seven = choice==7)

df_choices <-
    read_csv(opt$choices) %>%
    filter(treatment_simple == "Revision Mechanism")

payoffs_profiles <- 
    fromJSON(opt$payoffs) 

# Select Max Payoff to test against
max_payoff <-
    payoffs_profiles %>%
    filter(payoffs == "standard", condition == "highest") %>%
    select(avg_group_payoff) %>%
    pull()

# --- Statistical Tests --- #
# payoff less than max ?
payoff_max <- 
    wilcox_test(df_choices, 
                payoff ~ 1, 
                mu = max_payoff, 
                alternative =  "less"
                )

print(payoff_max)

# initial choice analysis
# overall
initial_choice_overall <-
    binom_test(x = df_initial %>%
                filter(is_seven == TRUE) %>% 
                nrow(),
            n = nrow(df_initial), 
            p = 1, alternative = "less",
            detailed = TRUE)

print(initial_choice_overall)

# in final period
initial_choice_final <-
    binom_test(x = df_initial %>%
                filter(period == 10) %>% 
                filter(is_seven == TRUE) %>% 
                nrow(),
            n = df_initial %>%
                filter(period == 10) %>% 
                nrow(), 
            p = 1, alternative = "less",
            detailed = TRUE)

# --- Save --- #
# MWU test
write_csv(payoff_max, opt$mwu)
# Binomial Test results 
json_output <- 
    toJSON(list(
            'all_periods'  = initial_choice_overall, 
            'final_period' = initial_choice_final
            ), 
            pretty = TRUE
        )
write(json_output, opt$binomial)
