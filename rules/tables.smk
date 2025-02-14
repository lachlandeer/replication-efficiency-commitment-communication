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
