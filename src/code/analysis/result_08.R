# --- Libraries --- #
library(readr)
library(dplyr)
library(rstatix)
library(optparse)

# --- CLI Parsing --- # 
option_list = list(
    make_option(c("-d", "--decisions"),
                type = "character",
                default = NULL,
                help = "a csv group level decisions by period",
                metavar = "character"
                ),
    make_option(c("-m", "--messages"),
                type = "character",
                default = NULL,
                help = "a csv group level decisions by period",
                metavar = "character"
                ),
	make_option(c("-o", "--out"),
                type = "character",
                default = "results.csv",
                help = "output file name [default = %default]",
                metavar = "character"
                )
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$decisions)){
  print_help(opt_parser)
  stop("Group level decisions must be provided", call. = FALSE)
}
if (is.null(opt$messages)){
  print_help(opt_parser)
  stop("Group level message data must be provided", call. = FALSE)
}

# --- Load the Data --- #
message("Loading Decisions data")
group_level <- 
    read_csv(opt$decisions) %>%
    mutate(time = "decision") %>%
    mutate(full_coord = as.numeric(full_coord)) %>% 
    select(group_id = group_id_unique, period, min_effort, full_coord, num_sevens, payoff, eqn_dev, choice, time)

message("Loading Message data")
group_level_messages <-
    read_csv(opt$messages) %>%
    mutate(time = "pre-play") %>%
    select(group_id, period, min_effort, full_coord, num_sevens, payoff, eqn_dev, choice, time) %>%
    mutate(full_coord = as.numeric(full_coord))

# bind the data frames
message("Binding Data")
group_level <-
    bind_rows(group_level, group_level_messages)

head(group_level)

#--- Pairwise Tests --- #
message("Running Analysis")

out_1 <- 
    pairwise_wilcox_test(group_level, 
                         payoff ~ time
                         )
out_2 <- 
    pairwise_wilcox_test(group_level, 
                         eqn_dev ~ time
                         )
out_3 <- 
    pairwise_wilcox_test(group_level, 
                        min_effort ~ time
                        )
out_4 <- 
    pairwise_wilcox_test(group_level, 
                         num_sevens ~ time,
                         )
out_5 <- 
    pairwise_wilcox_test(group_level, 
                         full_coord ~ time
                         )

# Some Summary Statistics --- #
message("Summary Stats for viewing")
group_level %>%
    group_by(time) %>% 
    summarise(
        payoff = mean(payoff),
        eqn_dev = mean(eqn_dev),
        min_effort = mean(min_effort),
        num_sevens = mean(num_sevens),
        full_coord = mean(full_coord)
    )

# --- Save --- #
out <-
    rbind(out_1,
          out_2,
          out_3,
          out_4,
          out_5
          )

write_csv(out, opt$out)
