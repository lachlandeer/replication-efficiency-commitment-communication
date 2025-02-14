# --- Libraries --- #
library(rstatix)
library(readr)
library(dplyr)
library(optparse)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a csv file subject decisions and payoffs",
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


# --- Load Data -- #
df <- 
    read_csv(opt$data)

head(df)

# --- Filter treatments --- # 
df <-
    df %>%
    filter(treatment %in% 
        c('Baseline', 'Revision Mechanism', 'Standard Cheap Talk')
        )

# --- Run Analysis --- #
out <- 
    pairwise_wilcox_test(
        df, 
        payoff ~ treatment,
        p.adjust.method = "BH"
        )

# --- Save ---# 
write_csv(out, opt$out)
