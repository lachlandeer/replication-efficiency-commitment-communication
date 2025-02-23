#---- Libraries --- #
library(readr)
library(dplyr)
library(optparse)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-d", "--decisions"),
                type = "character",
                default = NULL,
                help = "a csv file with decisions and payoffs from ALL treatments",
                metavar = "character"
                ),
    make_option(c("-c", "--characteristics"),
                type = "character",
                default = NULL,
                help = "a csv file with subject characteristics",
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

if (is.null(opt$decisions)){
  print_help(opt_parser)
  stop("Subject Decisions must be provided", call. = FALSE)
}
if (is.null(opt$characteristics)){
  print_help(opt_parser)
  stop("Characteristics data must be provided", call. = FALSE)
}

# --- Load Data --- #
message("Loading Data")
in_decisions <- opt$decisions
in_charac    <- opt$characteristics
df <- 
    read_csv(in_decisions) %>%
    mutate(treatment = if_else(treatment == "RM at IU", "Revision Mechanism", treatment))

subject_charac <-
    read_csv(in_charac)

# --- Merge in Subject Characteristics --- #
message("Merging decisions and characteristics")
df <-
    df %>%
    inner_join(subject_charac, by = join_by("subject_id")) 

# --- Add Individual's Equilibrium Deviation ---# 
# eq_dev defined as distance between effort choice and minimum
# eq_dev_abs defined as absolute distance between effort choice and minimum
# eq_dev_sq defined as squared distance between effort choice and minimum
message("Adding additional outcome variables")
df <-
    df %>%
    group_by(period, group_id_unique) %>%
    mutate(min_choice = min(choice),
           eqn_dev = choice - min_choice,
           #eqn_dev_abs = abs(eqn_dev),
           #eqn_dev_sq = eqn_dev**2
           efficient_dev = 7 - choice
           ) %>%
    ungroup()

# --- Save --- #
message("Saving")
write_csv(df, opt$out)
