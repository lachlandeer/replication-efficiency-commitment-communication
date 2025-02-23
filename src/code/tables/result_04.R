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
    read_csv(opt$data) #%>%
    #filter(!(group1 %in% c("Synchronous RM", "Infrequent Revision Mechanism") & group2 %in% c("Synchronous RM", "Infrequent Revision Mechanism"))) 

# --- Produce Table --- #
tab <- 
    df %>%
    select(group1, group2, outcome =".y.", statistic, p) %>%
    mutate(p = if_else(p < 0.001, "<0.001", as.character(p)),
           outcome = case_when(
               outcome == "payoff" ~ "Payoff",
               outcome == "eqn_dev" ~ "Eqm Deviation",
               outcome == "min_effort" ~ "Min. Effort",
               outcome == "num_sevens" ~ "Freq. Efficient Effort",
               outcome == "efficiency" ~ "Efficiency",
               TRUE ~ "Full Coordination"
           )
           ) %>%
    arrange(desc(outcome)) %>%
    gt() %>%
    cols_label(
        group1 = "Treatment 1",
        group2 = "Treatment 2",
        outcome  = "Outcome",
        statistic = "Test Statistic",
        p = "p-value"#,
        #n1 = "N. Obs. Treatment 1",
        #n2 = "N. Obs. Treatment 2"
    )
    #fmt_number(decimals = 3)

# --- Save --- #
gtsave(tab, opt$out)