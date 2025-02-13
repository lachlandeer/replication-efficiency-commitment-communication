# get_max_min: Get max and min simulated payoffs and strategy profiles
rule get_max_min:
    input:
        script = config["src_models"] + "get_max_min.R",
        profiles      = config["out_models"] + "simulated_payoffs.csv",
        profiles_vhbb = config["out_models"] + "simulated_payoffs_vhbb.csv",
    output:
        profiles = config["out_models"] + "max_and_min_profiles.json",
    log:
        config["log"] + "models/get_max_min.txt"
    shell:
        "{runR} {input.script} --standard {input.profiles} --vhbb {input.profiles_vhbb} \
         --out {output.profiles} > {log} {logAll}" 

# simulated_payoffs: Simulate Payoff Matrix for main parameterizaion
rule simulated_payoffs:
    input:
        script = config["src_models"] + "simulate_payoffs.R",
        payoff = config["src_lib"] + "compute_payoff.R",
    output:
        data = config["out_models"] + "simulated_payoffs.csv",
    log:
        config["log"] + "models/simulate_payoffs.txt"
    shell:
        "{runR} {input.script} --payoffFunction {input.payoff} --out {output.data} > {log} {logAll}" 

# simulated_payoffs_vhbb : Simulate Payoff Matrix for VHBB parameterizaionrule simulated_payoffs:
rule simulated_payoffs_vhbb: 
    input:
        script = config["src_models"] + "simulate_payoffs_vhbb.R",
        payoff = config["src_lib"] + "compute_payoff.R",
    output:
        data = config["out_models"] + "simulated_payoffs_vhbb.csv",
    log:
        config["log"] + "models/simulate_payoffs_vhbb.txt"
    shell:
        "{runR} {input.script} --payoffFunction {input.payoff} --out {output.data} > {log} {logAll}" 