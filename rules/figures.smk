rule figure_2:
    input: 
        script = config["src_figures"] + "efficiency_by_treatment.R",
        data = config["out_analysis"] + "efficiency.csv",
    output:
        pdf = config["out_figures"] + "efficiency_by_treatment.pdf",
    log:
        config["log"] + "figs/efficiency_by_treatment.txt"
    shell:
        "{runR} {input.script} --data {input.data} --out {output.pdf} > {log} {logAll}" 
