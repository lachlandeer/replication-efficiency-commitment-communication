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
        script = config["src_data_mgt"] + "ztree_tables.R",
        treatments = config["src_data"] + "treatment_mapping.csv"
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

