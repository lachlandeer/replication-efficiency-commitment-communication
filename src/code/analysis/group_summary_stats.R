library(readr)
library(dplyr)
library(optparse)

option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a csv group level data by period",
                metavar = "character"
                ),
	make_option(c("-o", "--out"),
                type = "character",
                default = "summary_stats.csv",
                help = "output file name [default = %default]",
                metavar = "character"
                )
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("Group level data must be provided", call. = FALSE)
}

# --- Load Data --- #
df <- 
    read_csv(opt$data)

# --- Compute Summary Stats --- #
group_level_summary <- 
    df %>%
    group_by(treatment) %>%
    summarize(min_effort = mean(min_effort),
              # if each group has one distinct value, then they've coordinated on it
              full_coord = mean(full_coord),
              # how often is a seven chosen
              num_sevens = mean(num_sevens),
              # average payoff
              payoff = mean(payoff),
              # eqn dev
              eqn_dev = mean(eqn_dev),
              choice = mean(choice)
    )

# --- Save --- #
write_csv(group_level_summary, opt$out)