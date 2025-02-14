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
    
