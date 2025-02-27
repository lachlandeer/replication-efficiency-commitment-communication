# A Replication of "A Road to Efficiency through Communication and Commitment"

[![lifecycle](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![lifecycle](https://img.shields.io/badge/version-0.1.0-red.svg)]()

## Project Overview

This project replicates the main tables and figures from Avoyan & Ramos' article, ["A Road to Efficiency through Communication and Commitment"](https://www.aeaweb.org/articles?id=10.1257/aer.20171014) published in the *American Economic Review*.

## Data Availability and Provenance Statements

The dataset used in this replication is sourced from [Avoyan & Ramos' ICPSR repository](https://www.openicpsr.org/openicpsr/project/185662/version/V1/view).

- [X] We certify that the author(s) of the manuscript have legitimate access to and permission to use the data used in this manuscript. 
- [X] All data **are** publicly available.


## Code and Reproducibility

The analysis is conducted using R scripts organized in the `src/` directory. 

- `src/code/`: Contains all the code to clean and analyze the data
  - `src/code/analysis/`: Scripts to conduct statistical analysis
  - `src/code/data-mgt/`: Scripts to clean the data prior to analysis
  - `src/code/figs/`: Scripts to assemble the figures used in the Discussion paper
  - `src/code/tables/`: Scripts to assemble the tables used in the Discussion paper
- `src/data/`: Contains the data and data README files
- `src/lib/` Contains scripts to install `renv` via Snakemake and re-useable functions

The project utilizes the `renv` package for R to manage dependencies, ensuring a reproducible environment. The `renv.lock` file captures the exact package versions used.

We use `Snakemake` to manage the workflow.

- `Snakefile` in the root directory manages the build
- Snakefiles in the `rules/` subdirectory contain rules that execute analysis.

## Software and Dependencies

To replicate the analyses, ensure the following software is installed:

- **Python**: Version 3.6 or higher
- **Snakemake**: [Installation instructions](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html)
- **R**: Version 4.2.0 or higher

R package dependencies are specified in the `renv.lock` file. To install them:

1. Open R in the project directory.
2. Run:
   ```r
   install.packages("renv")
   renv::restore()
   ```

OR use the Snakemake rules provided in `rules/renv.smk`.

## Computational requirements

- [X] The replication package contains one or more programs to install all dependencies and set up the necessary directory structure. 

Portions of the code use bash scripting, which may require Linux.

### Controlled Randomness

- [X] No Pseudo random generator is used in the analysis described here.

#### Summary

Approximate time needed to reproduce the analyses on a standard (CURRENT YEAR) desktop machine:

- [X] <10 minutes
- [ ] 10-60 minutes
- [ ] 1-2 hours
- [ ] 2-8 hours
- [ ] 8-24 hours
- [ ] 1-3 days
- [ ] 3-14 days
- [ ] > 14 days

Approximate storage space needed:

- [X] < 25 MBytes
- [ ] 25 MB - 250 MB
- [ ] 250 MB - 2 GB
- [ ] 2 GB - 25 GB
- [ ] 25 GB - 250 GB
- [ ] > 250 GB

- [ ] Not feasible to run on a desktop machine, as described below.

#### Details

The code was last run on a **16-core Intel-based laptop with PopOS version 5.18.10-76051810-generic with 50GB of free space**. 

## Instructions for Replication


1. **Clone the Repository**:
   ```bash
   git clone https://github.com/lachlandeer/replication-games-corrupted-algo.git
   cd replication-games-corrupted-algo
   ```

2. **Set Up Python Environment**:
   - Install [Anaconda Python](https://www.anaconda.com/products/individual) or use the deadsnakes PPA for Python installation.
   - Create and activate a virtual environment:
     ```bash
     conda create -n replication-env python=3.8
     conda activate replication-env
     ```

3. **Install Snakemake**:
   ```bash
   pip3 install -r requirements.txt
   ```

4. **Set Up R Environment**:
   - Ensure R is installed.
   - Restore R package dependencies:
     ```r
     install.packages("renv")
     renv::restore()
     ```
     OR
     ```bash
     snakemake --cores 1 renv_install
     snakemake --cores 1 renv_consent
     snakemake --cores 1 renv_restore
     ```

5. Download the datafiles from the authors ICPSR page and place files from the `data/raw/` directory into `src/data/ztree`.

6. **Execute the Analysis Pipeline**:
   - Run the Snakemake pipeline:
     ```bash
     snakemake all --cores 1
     ```

   This command will execute the analysis workflow as defined in the `Snakefile`, generating the replicated tables and figures.

## Citation and License

If you use or adapt this replication code, please cite the original study:

Avoyan, Ala, and João Ramos. 2023. "A Road to Efficiency through Communication and Commitment." American Economic Review 113 (9): 2355–81. DOI: 10.1257/aer.20171014.

Additionally, cite our replication report as:

Egor Bronnikov, Lachlan Deer and Cristina Figueroa. (2025). "Replication Report:  A Road to Efficiency through Communication and Commitment". I4R Discussion Paper Series XXX

This project is licensed under the [MIT License](LICENSE).

---

*Note: Ensure all software installations and environment setups are compatible with your operating system. For any issues or questions, please open an issue in this repository.*