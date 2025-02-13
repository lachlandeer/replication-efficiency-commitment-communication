# --- Libraries --- #
library(readr)
library(dplyr)
library(gt)
library(tidyr)
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
    filter(period != "overall") %>%
    mutate(period = as.numeric(period))

# --- Make Table --- #
efficiency_wide <- 
    efficiency %>%
    select(treatment_simple, period, efficiency) %>%  # Ensure relevant columns
    pivot_wider(names_from = period, values_from = efficiency) %>%  # Convert periods to columns
    mutate(treatment_simple = case_when(
        treatment_simple == "Baseline" ~ "B",
        treatment_simple == "Standard Cheap Talk" ~ "S-CT",
        treatment_simple == "Standard Revision Mechanism" ~ "S-RM",
        treatment_simple == "Revision Cheap Talk" ~ "R-CT",
        treatment_simple == "Richer RCT" ~ "R-R-CT",
        treatment_simple == "Infrequent Revision Mechanism" ~ "I-RM",
        treatment_simple == "Random RM" ~ "R-RM",
        treatment_simple == "Revision Mechanism" ~ "RM",
        treatment_simple == "RM VHBB" ~ "RM-VHBB",
        treatment_simple == "Synchronous RM" ~ "S-RM",
        TRUE ~ treatment_simple  # Keeps unchanged values
    )) %>%
    arrange(get(names(.)[11]))

# Create the `gt` table
tab <- 
    efficiency_wide %>%
    gt(rowname_col = "treatment_simple") %>%  # Treat treatment as row names
    fmt_number(columns = everything(), decimals = 3) %>%
    tab_spanner(label = "Efficiency by Period", columns = -treatment_simple) %>%
    cols_label(
        treatment_simple = "Treatment"
    )


# --- Save --- #
 gtsave(tab, opt$out)
