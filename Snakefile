# Main Workflow - XXX
# Contributors: @lachlandeer, XXX

# --- Importing Configuration Files --- #
configfile: "paths.yaml"

RAWDATA = glob_wildcards(config["src_data"] + "ztree/{fname}").fname

# --- Variable Declarations ---- #
runR = "Rscript --no-save --no-restore --verbose"
logAll = "2>&1"

# --- Main Build Rule --- #
# all            : build outputs that are the core of the project
rule all:
    input:
        result_01    = config["out_analysis"] + "result_01_tests.csv",
        table_02_clustered = config["out_tables"] + "table_02_clustered.tex",
        table_02_homosk    = config["out_tables"] + "table_02_homosk.tex",
        # table_02_homosk    = config["out_analysis"] + "table_02_homosk.Rds",
        figure_2     = config["out_figures"] + "efficiency_by_treatment.pdf",
        eff_summary  = config["out_tables"] + "efficiency_summary.tex",
        eff_by_round = config["out_tables"] + "efficiency_by_round.tex"


# --- Cleaning Rules --- #
## clean_all      : delete all output and log files for this project
rule clean_all:
    shell:
        "rm -rf out/ log/ *.pdf *.html"

# --- Help Rules --- #
## help_main      : prints help comments for Snakefile in ROOT directory. 
##                  Help for rules in other parts of the workflows (i.e. in rules/)
##                  can be called by `snakemake help_<workflowname>`
rule help_main:
    input: "Snakefile"
    shell:
        "sed -n 's/^##//p' {input}"

# --- Sub Rules --- #
# Include all other Snakefiles that contain rules that are part of the project
# 1. project specific
include: config["rules"] + "data_mgt.smk"
include: config["rules"] + "models.smk"
include: config["rules"] + "analysis.smk"
include: config["rules"] + "figures.smk"
include: config["rules"] + "tables.smk"
# 2. Other rules
include: config["rules"] + "renv.smk"
# include: config["rules"] + "clean.smk"
include: config["rules"] + "dag.smk"
