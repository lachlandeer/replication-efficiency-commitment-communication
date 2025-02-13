# ---- SIMULATION:  all possible payoffs ------- #
library(tidyr)
library(dplyr)
library(readr)
library(optparse)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-p", "--payoffFunction"),
                type = "character",
                default = NULL,
                help = "an R script with payoff function that can be mapped onto a dataframe",
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

if (is.null(opt$payoffFunction)){
  print_help(opt_parser)
  stop("Payoff Function must be provided", call. = FALSE)
}

# --- Parameters --- #
effort_choices <- 1:7
n_players <- 6

# Load Payoff Function 
source(opt$payoffFunction)

# Generate all possible effort combinations for six players
df_simulated <- 
    expand_grid(
        player1 = effort_choices,
        player2 = effort_choices,
        player3 = effort_choices,
        player4 = effort_choices,
        player5 = effort_choices,
        player6 = effort_choices
    ) %>%
    mutate(period = 1,
           strategy_profile = row_number()  # Single group
           ) 

# Convert data to long format
df_long <- 
    df_simulated %>%
    pivot_longer(cols = starts_with("player"), 
                 names_to = "player", 
                values_to = "effort"
                )

# Compute payoffs for each combination
df_payoffs <- 
    df_long %>%
    compute_payoff(
        effort_col = "effort", 
        group_col = "strategy_profile", 
        time = "period", 
        gamma = 0.6, 
        alpha = 0.2, 
        beta = 0.1
        )

# Compute total group payoff
df_group_payoff <- 
    df_payoffs %>%
    group_by(strategy_profile) %>%
    summarise(
        min_effort = first(min(effort)),
        total_group_payoff = sum(payoff),
        avg_group_payoff = total_group_payoff / n_players
    ) %>%
    ungroup()

# Pivot back to wide format
df_wide <- 
    df_payoffs %>%
    select(strategy_profile, player, effort, payoff) %>%
    pivot_wider(names_from = player, 
                values_from = c(effort, payoff)
                )

# Merge with min effort & total group payoff
df_final <- 
    df_wide %>%
    left_join(df_group_payoff, 
              by = "strategy_profile"
              )
# ---Save it --- # 
write_csv(df_final, opt$out)