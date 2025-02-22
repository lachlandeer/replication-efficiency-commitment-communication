# analysis_group : Create the data set used in empirical analysis scripts for group level outcomes
rule analysis_group:
    input:
        script = config["src_data_mgt"] + "gen_analysis_data_group.R",
        indiv  = config["out_data"] + "analysis_data/individual.csv",
        eff    = config["out_analysis"] + "efficiency_group_period.csv"
    output:
        data = config["out_data"] + "analysis_data/group.csv"
    log:
        config["log"] + "data_mgt/gen_analysis_data_group.txt",
    shell:
        "{runR} {input.script} --data {input.indiv} --efficiency {input.eff} \
            --out {output.data} > {log} {logAll}"  

# analysis_individual : Create the data set used in empirical analysis scripts for individual level outcomes
rule analysis_individual:
    input:
        script = config["src_data_mgt"] + "gen_analysis_data_individual.R",
        decisions       = config["out_data"] + "decisions/subject_decisions_w_payoffs.csv",
        characteristics = config["out_data"] + "subject_characteristics.csv"
    output:
        data = config["out_data"] + "analysis_data/individual.csv"
    log:
        config["log"] + "data_mgt/gen_analysis_data_individual.txt",
    shell:
        "{runR} {input.script} --decisions {input.decisions} --characteristics {input.characteristics} \
            --out {output.data} > {log} {logAll}"  

# decisions_w_payoffs : Add payoffs to subject decisions data 
rule decisions_w_payoffs:
    input:
        script = config["src_data_mgt"] + "decisions_with_payoffs.R",
        data   = config["out_data"] + "decisions/subject_decisions.csv",
        payoff = config["src_lib"] + "compute_payoff.R",
    output:
        data = config["out_data"] + "decisions/subject_decisions_w_payoffs.csv",
    log:
        config["log"] + "data_mgt/decisons_w_payoffs.txt"
    shell:
        "{runR} {input.script} --data {input.data} --payoffFunction {input.payoff} --out {output.data} > {log} {logAll}"       

rule gather_decisions:
    input:
        script    = config["src_data_mgt"] + "gather_decisions.R",
        baseline  = config["out_data"] + "decisions/baseline.csv",
        cheaptalk = config["out_data"] + "decisions/cheap_talk.csv",
        revision  = config["out_data"] + "decisions/revision_mechanism.csv",
        subjects  = config["out_data"] + "ztree/subjects.csv"
    output:
        data = config["out_data"] + "decisions/subject_decisions.csv"
    log:
        config["log"] + "data_mgt/gather_decisions.txt"
    shell:
        "{runR} {input.script} \
            --baseline  {input.baseline}  \
            --cheaptalk {input.cheaptalk} \
            --revision  {input.revision} \
            --subjects  {input.subjects} \
            --out {output.data} \
            > {log} {logAll}"

# recover_decisions_revision_final: retrives final effort choices for treatments that feature revision mechanism
rule recover_decisions_revision_final:
    input:
        script = config["src_data_mgt"] + "recover_decisions_revision_final.R",
        data = config["out_data"] + "ztree/globals.csv"
    output:
        data = config["out_data"] + "decisions/revision_mechanism.csv"
    params:
        period_length = 60
    log:
        config["log"] + "data_mgt/recover_decisions_revision_mechanism.txt"
    shell:
        "{runR} {input.script} --data {input.data} --length {params.period_length} \
            --out {output.data} \
            > {log} {logAll}"

# recover_decisions_revision_inital: retrives intial effort choices for treatments that feature revision mechanism
rule recover_decisions_revision_initial:
    input:
        script = config["src_data_mgt"] + "recover_decisions_revision_initial.R",
        data = config["out_data"] + "ztree/globals.csv"
    output:
        data = config["out_data"] + "intermediate_decisions/revision_inital.csv"
    params:
        period_length = 60
    log:
        config["log"] + "data_mgt/recover_decisions_revision_mechanism_initial.txt"
    shell:
        "{runR} {input.script} --data {input.data} --length {params.period_length} \
            --out {output.data} \
            > {log} {logAll}"

# recover_decisions_cheap_talk: retrives effort choices for treatments that feature cheap talk
rule recover_decisions_cheap_talk:
    input:
        script = config["src_data_mgt"] + "recover_decisions_cheap_talk.R",
        data = config["out_data"] + "ztree/subjects.csv"
    output:
        data = config["out_data"] + "decisions/cheap_talk.csv"
    log:
        config["log"] + "data_mgt/recover_decisions_cheap_talk.txt"
    shell:
        "{runR} {input.script} --data {input.data} \
            --out {output.data} \
            > {log} {logAll}"

# recover_decisions_baseline: retrives effort choices for baseline treatment
rule recover_decisions_baseline:
    input:
        script = config["src_data_mgt"] + "recover_decisions_baseline.R",
        data = config["out_data"] + "ztree/subjects.csv"
    output:
        data = config["out_data"] + "decisions/baseline.csv"
    log:
        config["log"] + "data_mgt/recover_decisions_baseline.txt"
    shell:
        "{runR} {input.script} --data {input.data} \
            --out {output.data} \
            > {log} {logAll}"

# ztree_tables  : Parse zTree Tables data and extract subjects/globals
rule ztree_tables:
    input:
        script     = config["src_data_mgt"] + "ztree_tables.R",
        treatments = config["src_data"] + "treatment_mapping.csv",
        raw_data   = expand(config["src_data"] + "ztree/" +
                            "{iFile}",
                            iFile = RAWDATA,
                            )
    output:
        subjects_data = config["out_data"] + "ztree/subjects.csv",
        globals_data = config["out_data"] + "ztree/globals.csv"
    params:
        path = "src/data/ztree/"
    log:
        config["log"] + "data_mgt/ztree_tables.txt"
    shell:
        "{runR} {input.script} --datapath {params.path} --treatments {input.treatments}\
            --subjects {output.subjects_data} --globals {output.globals_data} \
            > {log} {logAll}"

# clean_subject_characteristics: Cleans the subject characteristics data
rule clean_subject_characteristics:
    input:
        script        = config["src_data_mgt"] +"clean_subject_characteristics.R",
        treatments    = config["src_data"] + "treatment_mapping.csv",
        subjects_data = config["out_data"] + "ztree/subjects.csv",
        raw_data      = expand(config["src_data"] + "ztree/" +
                            "{iFile}",
                            iFile = RAWDATA,
                            )
    output:
        data = config["out_data"] + "subject_characteristics.csv"
    params:
        datapath = "src/data/ztree/"
    log:
        config["log"] + "data_mgt/subject_characteristics.txt"
    shell:
        "{runR} {input.script} --datapath {params.datapath} --treatments {input.treatments}\
            --subjects {input.subjects_data} --out {output.data} \
            > {log} {logAll}"

