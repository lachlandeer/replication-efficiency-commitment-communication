# result_05: Statistical tests for result 5
rule result_05:
    input: 
        script = config["src_analysis"] + "result_05.R",
        data   = config["out_data"] + "analysis_data/group.csv",
    output:
        file = config["out_analysis"] + "result_05_tests.csv"
    log:
        config["log"] + "analysis/result_05.txt"
    shell:
        "{runR} {input.script} --data {input.data} \
         --out {output.file} > {log} {logAll}"

# result_04: Statistical tests for result 4
rule result_04:
    input: 
        script = config["src_analysis"] + "result_04.R",
        data   = config["out_data"] + "analysis_data/group.csv",
    output:
        file = config["out_analysis"] + "result_04_tests.csv"
    log:
        config["log"] + "analysis/result_04.txt"
    shell:
        "{runR} {input.script} --data {input.data} \
         --out {output.file} > {log} {logAll}"


# result_03: Statistical tests for result 3 
rule result_03:
    input: 
        script = config["src_analysis"] + "result_03.R",
        data   = config["out_data"] + "analysis_data/group.csv",
    output:
        file = config["out_analysis"] + "result_03_tests.csv"
    log:
        config["log"] + "analysis/result_03.txt"
    shell:
        "{runR} {input.script} --data {input.data} \
         --out {output.file} > {log} {logAll}"

# result_02: Statistical Tests for Result 2
rule result_02:
    input:
        script  = config["src_analysis"] + "result_02.R",
        choices = config["out_data"] + "analysis_data/individual.csv",
        initial = config["out_data"] + "intermediate_decisions/revision_inital.csv",
        payoffs = config["out_models"] + "max_and_min_profiles.json",
    output: 
        mwu = config["out_analysis"] + "result_02_mwu.csv",
        binomial = config["out_analysis"] + "result_02_binomial.json"
    log:
        config["log"] + "analysis/result_02.txt"
    shell:
        "{runR} {input.script} --choices {input.choices} --initial {input.initial} \
         --payoffs {input.payoffs} --mwu {output.mwu} --binomial {output.binomial} > {log} {logAll}"

# table_02_clustered: Replicate Table 2 of main text w/ clustered SE
rule table_02_clustered:
    input: 
        script    = config["src_analysis"] + "table_02_clustered.R",
        subject   = config["out_data"] + "analysis_data/individual.csv",
        group     = config["out_data"] + "analysis_data/group.csv",
    output:
        file = config["out_analysis"] + "table_02_clustered.Rds"
    log:
        config["log"] + "analysis/table_02_clustered.txt"
    shell:
        "{runR} {input.script} --subjects {input.subject} --group {input.group} \
         --out {output.file} > {log} {logAll}"

# table_02_homosk: Replicate Table 2 of main text w/ homosk SE
rule table_02_homosk:
    input: 
        script    = config["src_analysis"] + "table_02_homosk.R",
        subject   = config["out_data"] + "analysis_data/individual.csv",
        group     = config["out_data"] + "analysis_data/group.csv",
    output:
        file = config["out_analysis"] + "table_02_homosk.Rds"
    log:
        config["log"] + "analysis/table_02_homosk.txt"
    shell:
        "{runR} {input.script} --subjects {input.subject} --group {input.group} \
         --out {output.file} > {log} {logAll}"

# result_01_mwu: Mann Whitney U test results for Result 1
rule result_01_mwu:
    input: 
        script = config["src_analysis"] + "result_01.R",
        data   = config["out_data"] + "analysis_data/individual.csv",
    output:
        file = config["out_analysis"] + "result_01_tests.csv"
    log:
        config["log"] + "analysis/result_01.txt"
    shell:
        "{runR} {input.script} --data {input.data} \
         --out {output.file} > {log} {logAll}"


# efficiency: Compute efficiency metrics by treatment and period
rule efficiency:
    input:
        script = config["src_analysis"] + "efficiency.R",
        data   = config["out_data"] + "analysis_data/individual.csv",
        payoff_scalers = config["out_models"] + "max_and_min_profiles.json"
    output:
        data = config["out_analysis"] + "efficiency.csv",
    log:
        config["log"] + "analysis/efficiency.txt"
    shell:
        "{runR} {input.script} --data {input.data} --payoffs {input.payoff_scalers} \
         --out {output.data} > {log} {logAll}"
    
rule group_summary_stats:
    input:
        script = config["src_analysis"] + "group_summary_stats.R",
        data   = config["out_data"] + "analysis_data/group.csv",
    output:
        data = config["out_analysis"] + "group_summary_stats.csv",
    log:
        config["log"] + "analysis/group_summary.txt"
    shell:
        "{runR} {input.script} --data {input.data} \
         --out {output.data} > {log} {logAll}"