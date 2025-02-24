# --- Load Libraries --- #
library(rlist)
library(modelsummary)
library(tibble)
library(kableExtra)
library(optparse)

 #--- CLI parsing --- #
option_list = list(
    make_option(c("-m", "--models"),
                type = "character",
                default = NULL,
                help = "a Rds file name",
                metavar = "character"),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out.tex",
                help = "output file name [default = %default]",
                metavar = "character")
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$models)){
  print_help(opt_parser)
  stop("Input models must be provided", call. = FALSE)
}

#--- Load Regression Models ---# 
models <- list.load(opt$models)

# --- Extra Info to add to the table --- #
# setting up column names of table
col_names <- c('(1)', '(2)', '(3)', '(4)', '(5)', '(6)', '(7)', '(8)', '(9)', '(10)')
names(models) <- col_names

cm <- c(
        'relevel(as.factor(treatment), ref = "Revision Mechanism")Synchronous RM' = "Synchronous RM",
        'relevel(as.factor(treatment), ref = "Revision Mechanism")Infrequent Revision Mechanism' = 'Infrequent RM',
        # we omit controls and present them as Yes/No
        # finally the intercept
        '(Intercept)' = 'Intercept'
        )

# Additional Rows to add to table
add_rows <-tribble(
    ~term, ~'(1)', ~'(2)', ~'(3)', ~'(4)', ~'(5)', ~'(6)', ~'(7)', ~'(8)', ~'(9)', ~'(10)',
    'Period FE', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes'
    )


attr(add_rows, 'position') <- c(7)

# Adding a name for the dependent variable
dep_var <- c(' ' =1, 'Dependent variable' =10)
dep_var_names <- c(' ' =1, 
                   'Payoff' =1, 
                   'Efficiency' = 1, 
                   'Minimum Effort' =1, 
                   'Freq Efficient Effort' =1, 
                   'Full Coordination' =1,
                   'Eqm Deviation' = 1,
                   'Eff. Eqm Deviation' = 1,
                   'Effort 4 and above',
                   'Effort 5 and above',
                   'Effort 6 and above'
                   )


#--- Create the Regression Table --- #
tab <-
    modelsummary(models,
                 fmt = 3,
                 #stars = TRUE,
                 stars = c('*' = .1, '**' = .05, '***' = 0.01),
                 coef_map = cm,
                 coef_omit = "period",
                 add_rows = add_rows,
                 gof_omit = 'R2 Adj|AIC|BIC|RMSE|Log',
                 gof_map = c("r.squared", "nobs"),
                 output = 'latex_tabular',
                 escape = FALSE # render latex as latex- needs FALSE
    )   %>%
    add_header_above(dep_var_names) %>%
    add_header_above(dep_var) %>%
    row_spec(7, 
             extra_latex_after = "\\midrule") 

# --- Save the Output --- #
tab

tab %>%
    save_kable(file = opt$out, self_contained = FALSE)