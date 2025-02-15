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
