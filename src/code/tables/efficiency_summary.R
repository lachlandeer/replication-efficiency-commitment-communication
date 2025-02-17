# --- Libraries --- #
library(readr)
library(dplyr)
library(gt)
library(optparse)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a csv file with efficiency and std errors by treatment",
                metavar = "character"
                ),
	make_option(c("-o", "--out"),
                type = "character",
                default = "efficiency.tex",
                help = "output file name [default = %default]",
                metavar = "character"
                )
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("efficiency data must be provided", call. = FALSE)
}

# --- Load Data --- #
efficiency <-
    read_csv(opt$data) %>%
    filter(period == "overall")

# --- Make Table --- #
tab <-
    efficiency %>%
    select(-period) %>%
    arrange(efficiency) %>%
    gt() %>%
    fmt_number(decimals = 3) %>%
    cols_label(
        treatment_simple = "Treatment",
        efficiency = "Mean Efficiency",
        se = "Std Error"
    ) %>%
    text_case_match(
        "Baseline" ~ "B",
        "Standard Cheap Talk" ~ "S-CT",
        "Standard Revision Mechanism" ~ "S-RM",
        "Revision Cheap Talk" ~ "R-CT",
        "Richer RCT" ~ "R-R-CT",
        "Infrequent Revision Mechanism" ~ "I-RM",
        "Random RM" ~ "R-RM",
        "Revision Mechanism" ~ "RM",
        "RM VHBB" ~ "RM-VHBB",
        "Synchronous RM" ~ "S-RM"
    )


# --- Save --- #
 gtsave(tab, opt$out)
