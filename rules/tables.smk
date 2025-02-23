# tab_result_09: Produce a results table summarizing U tests for Result 9
rule tab_result_09: 
    input:
        script = config["src_tables"] + "result_09.R",
        data   = config["out_analysis"] + "result_09_tests.csv",
    output:
        tex = config["out_tables"] + "result_09.tex",
    log:
        config["log"] + "tables/result_09.txt",
    shell:
        "{runR} {input.script} --data {input.data} --out {output.tex} > {log} {logAll}" 

# tab_result_08: Produce a results table summarizing U tests for Result 9
rule tab_result_08: 
    input:
        script = config["src_tables"] + "result_08.R",
        data   = config["out_analysis"] + "result_08_tests.csv",
    output:
        tex = config["out_tables"] + "result_08.tex",
    log:
        config["log"] + "tables/result_08.txt",
    shell:
        "{runR} {input.script} --data {input.data} --out {output.tex} > {log} {logAll}" 

# tab_result_05: Produce a results table summarizing U tests for Result 4
rule tab_result_05: 
    input:
        script = config["src_tables"] + "result_05.R",
        data   = config["out_analysis"] + "result_05_tests.csv",
    output:
        tex = config["out_tables"] + "result_05.tex",
    log:
        config["log"] + "tables/result_05.txt",
    shell:
        "{runR} {input.script} --data {input.data} --out {output.tex} > {log} {logAll}" 

# tab_result_04: Produce a results table summarizing U tests for Result 4
rule tab_result_04: 
    input:
        script = config["src_tables"] + "result_04.R",
        data   = config["out_analysis"] + "result_04_tests.csv",
    output:
        tex = config["out_tables"] + "result_04.tex",
    log:
        config["log"] + "tables/result_04.txt",
    shell:
        "{runR} {input.script} --data {input.data} --out {output.tex} > {log} {logAll}" 

# tab_result_03: Produce a results table summarizing U tests for Result 3
rule tab_result_03: 
    input:
        script = config["src_tables"] + "result_03.R",
        data   = config["out_analysis"] + "result_03_tests.csv",
    output:
        tex = config["out_tables"] + "result_03.tex",
    log:
        config["log"] + "tables/result_03.txt",
    shell:
        "{runR} {input.script} --data {input.data} --out {output.tex} > {log} {logAll}" 

# tab_02_homosk:   Regression Table for estimates in Table 2 of AR w/ clustered SE
rule tab_02_homosk:
    input: 
        script = config["src_tables"] + "tab_02_homosk.R",
        models = config["out_analysis"] + "table_02_homosk.Rds",
    output:
        tex = config["out_tables"] + "table_02_homosk.tex",
    log:
        config["log"] + "tables/table_02_homosk.txt",
    shell:
        "{runR} {input.script} --models {input.models} --out {output.tex} > {log} {logAll}" 

# tab_02_clustered:   Regression Table for estimates in Table 2 of AR w/ clustered SE
rule tab_02_clustered:
    input: 
        script = config["src_tables"] + "tab_02_clustered.R",
        models = config["out_analysis"] + "table_02_clustered.Rds",
    output:
        tex = config["out_tables"] + "table_02_clustered.tex",
    log:
        config["log"] + "tables/table_02_clustered.txt",
    shell:
        "{runR} {input.script} --models {input.models} --out {output.tex} > {log} {logAll}" 

# tab_result_01_mwu: Produce a results table summarizing U tests for Result 1
rule tab_result_01_mwu: 
    input:
        script = config["src_tables"] + "result_01_mwu.R",
        data   = config["out_analysis"] + "result_01_tests.csv",
    output:
        tex = config["out_tables"] + "result_01_mwu.tex",
    log:
        config["log"] + "tables/result_01_mwu.txt",
    shell:
        "{runR} {input.script} --data {input.data} --out {output.tex} > {log} {logAll}" 

# tab_efficiency_summary: Summarize overall efficiency by treatment in table
rule tab_efficiency_summary:
    input: 
        script = config["src_tables"] + "efficiency_summary.R",
        data   = config["out_analysis"] + "efficiency.csv",
    output:
        tex = config["out_tables"] + "efficiency_summary.tex",
    log:
        config["log"] + "tables/efficiency_summary.txt",
    shell:
        "{runR} {input.script} --data {input.data} --out {output.tex} > {log} {logAll}" 

# tab_efficiency_by_round: Summarize efficiency by round and treatment in table 
rule tab_efficiency_by_round:
    input: 
        script = config["src_tables"] + "efficiency_by_round.R",
        data   = config["out_analysis"] + "efficiency.csv",
    output:
        tex = config["out_tables"] + "efficiency_by_round.tex",
    log:
        config["log"] + "tables/efficiency_by_round.txt",
    shell:
        "{runR} {input.script} --data {input.data} --out {output.tex} > {log} {logAll}" 

# tab_grp_summary: Report group level summary statistics by treatment 
rule tab_grp_summary:
    input: 
        script = config["src_tables"] + "tab_grp_summary.R",
        data   = config["out_analysis"] + "group_summary_stats.csv",
    output:
        tex = config["out_tables"] + "tab_grp_summary.tex",
    log:
        config["log"] + "tables/tab_grp_summary.txt",
    shell:
        "{runR} {input.script} --data {input.data} --out {output.tex} > {log} {logAll}" 
