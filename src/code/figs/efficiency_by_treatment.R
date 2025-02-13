# --- Libraries --- #
library(readr)
library(dplyr)
library(ggplot2)
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
                default = "efficiency.pdf",
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

# --- Treatment Labels --- #
# For easier visualization
treatment_labels <- c(
    "Baseline" = "B",
    "Standard Cheap Talk" = "S-CT",
    "Standard Revision Mechanism" = "S-RM",
    "Revision Cheap Talk" = "R-CT",
    "Richer RCT" = "R-R-CT",
    "Infrequent Revision Mechanism" = "I-RM",
    "Random RM" = "R-RM",
    "Revision Mechanism" = "RM",
    "RM VHBB" = "RM-VHBB",
    "Synchronous RM" = "S-RM"
)

# --- Plot --- #
# Generate ordered grey shades from light to dark
grey_shades <- scales::grey_pal(start = 0.9, end = 0.3)(nrow(efficiency))   # Light to dark grey

# Plot with correctly ordered greys
ggplot(efficiency, 
    aes(x = reorder(treatment_simple, 
                    efficiency), 
        y = efficiency, 
        fill = reorder(treatment_simple, 
                       efficiency)
            )
        ) +
    geom_col() +  # Standard bar chart
    geom_errorbar(aes(ymin = efficiency - se, ymax = efficiency + se), 
        width = 0.2
        ) +  # Add SE bars
    scale_fill_manual(values = grey_shades) +  # Apply ordered grey shades
    scale_x_discrete(labels = treatment_labels) +  # Apply custom labels
    labs(
         x = "Treatment",
         y = "Normalized Efficiency") +
    ylim(0, 1) +
    theme_minimal() +
    theme(legend.position = "none")  # Remove legend if not needed

# --- Save it --- #
ggsave(opt$out)