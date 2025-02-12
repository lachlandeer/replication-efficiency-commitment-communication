# Main Workflow - XXX
# Contributors: @lachlandeer, XXX

# --- Importing Configuration Files --- #
configfile: "paths.yaml"


# --- Variable Declarations ---- #
runR = "Rscript --no-save --no-restore --verbose"
logAll = "2>&1"

# --- Main Build Rule --- #
# all            : build outputs that are the core of the project
rule all:
    input:
        config["out_data"] + "decisions/subject_decisions_w_payoffs.csv",
        quiz = config["out_data"] + "subject_characteristics.csv",
        subjects_data = config["out_data"] + "ztree/subjects.csv",
        global_data = config["out_data"] + "ztree/globals.csv"


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
# include: config["rules"] + "analysis.smk"
# include: config["rules"] + "figures.smk"
# include: config["rules"] + "tables.smk"
# 2. Other rules
include: config["rules"] + "renv.smk"
# include: config["rules"] + "clean.smk"
# include: config["rules"] + "dag.smk"
