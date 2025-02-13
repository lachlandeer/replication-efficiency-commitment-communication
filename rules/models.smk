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