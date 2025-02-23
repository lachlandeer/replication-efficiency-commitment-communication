library(readr) 
library(dplyr)
library(gt)
library(optparse)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a csv file with MWU results for treatment comparison",
                metavar = "character"
                ),
	make_option(c("-o", "--out"),
                type = "character",
                default = "table.tex",
                help = "output file name [default = %default]",
                metavar = "character"
                )
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("MW U test results must be provided", call. = FALSE)
}

# --- Load Data --- #
df <-
    read_csv(opt$data)

# --- Produce Table --- #
tab <- 
    df %>%
    select(group1, group2, statistic, p, n1, n2) %>%
    mutate(p = if_else(p < 0.001, "<0.001", as.character(p))) %>%
    gt() %>%
    cols_label(
        group1 = "Treatment 1",
        group2 = "Treatment 2",
        statistic = "Test Statistic",
        p = "p-value",
        n1 = "N. Obs. Treatment 1",
        n2 = "N. Obs. Treatment 2"
    )

# --- Save --- #
gtsave(tab, opt$out)