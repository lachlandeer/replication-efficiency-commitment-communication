# --- Libraries --- #
library(readr)
library(dplyr)
library(rstatix)
library(optparse)

# --- CLI Parsing --- # 
option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a csv group level data by period",
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

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("Group level data must be provided", call. = FALSE)
}

# --- Load the Data --- #
group_level <- 
    read_csv("out/data/analysis_data/group.csv") %>%
    filter(treatment %in% c("Revision Mechanism", "Revision Cheap Talk")) %>%
    mutate(full_coord = as.numeric(full_coord))


#--- Pairwise Tests --- #
out_1 <- 
    pairwise_wilcox_test(group_level, 
                         payoff ~ treatment, 
                         )
out_2 <- 
    pairwise_wilcox_test(group_level, 
                         eqn_dev ~ treatment
                         )
out_3 <- 
    pairwise_wilcox_test(group_level, 
                        min_effort ~ treatment)
out_4 <- 
    pairwise_wilcox_test(group_level, 
                         num_sevens ~ treatment
                         )
out_5 <- 
    pairwise_wilcox_test(group_level, 
                         full_coord ~ treatment
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
