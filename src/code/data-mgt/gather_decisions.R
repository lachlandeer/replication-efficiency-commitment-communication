# --- Libraries --- #
library(readr)
library(dplyr)
library(optparse)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-b", "--baseline"),
                type = "character",
                default = NULL,
                help = "a csv file with decisions from baseline treatment",
                metavar = "character"
                ),
    make_option(c("-c", "--cheaptalk"),
                type = "character",
                default = NULL,
                help = "a csv file with decisions from cheaptalk treatments",
                metavar = "character"
                ),
    make_option(c("-r", "--revision"),
                type = "character",
                default = NULL,
                help = "a csv file with decisions from revision treatments",
                metavar = "character"
                ),
    make_option(c("-s", "--subjects"),
                type = "character",
                default = NULL,
                help = "a csv file of the aggregated data from ztree subjects tables",
                metavar = "character"
                ),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out_subjects.csv",
                help = "output file name [default = %default]",
                metavar = "character"
                )
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$baseline)){
  print_help(opt_parser)
  stop("Baseline Treatment data must be provided", call. = FALSE)
}
if (is.null(opt$revision)){
  print_help(opt_parser)
  stop("Revision Treatment data must be provided", call. = FALSE)
}
if (is.null(opt$cheaptalk)){
  print_help(opt_parser)
  stop("Cheap Talk Treatment data must be provided", call. = FALSE)
}
if (is.null(opt$subjects)){
  print_help(opt_parser)
  stop("Subjects data must be provided", call. = FALSE)
}

# --- Load Data --- #
path_baseline <- opt$baseline 
baseline <-
    read_csv(path_baseline
        # "out/data/decisions/baseline.csv"
        )

path_revision <- opt$revision
revision_mechanism <-
    read_csv(path_revision)

path_cheaptalk <- opt$cheaptalk
cheap_talk <-
    read_csv(path_cheaptalk)

path_subjects <- opt$subjects
subjects <-
    read_csv(path_subjects)

# --- Bind Decisions --- #
all_decisions <- 
    bind_rows(
    baseline,
    revision_mechanism,
    cheap_talk
)

#---  Add session and group info back in to a unified table --- #
meta_info <-
    subjects %>%
    select(date, treatment, session, treatment_simple, 
           group_id, group_id_unique, period, 
           subject_id, role)

df <-
    inner_join(meta_info, all_decisions, by = join_by(subject_id, period))

# --- Save to File --- #
write_csv(df, opt$out)