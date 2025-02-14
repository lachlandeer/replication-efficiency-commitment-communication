# --- Libraries --- #
library(readr)
library(dplyr)
library(estimatr)
library(rlist)
library(optparse)

# --- CLI Parse --- #
option_list = list(
    make_option(c("-s", "--subjects"),
                type = "character",
                default = NULL,
                help = "a csv file name",
                metavar = "character"),
    make_option(c("-g", "--group"),
                type = "character",
                default = NULL,
                help = "a csv file name",
                metavar = "character"),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out.csv",
                help = "output file name [default = %default]",
                metavar = "character")
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$subjects)){
  print_help(opt_parser)
  stop("Subject decisions data must be provided", call. = FALSE)
}
if (is.null(opt$group)){
  print_help(opt_parser)
  stop("Group decisions data must be provided", call. = FALSE)
}

# --- Load Data --- #
individual <- 
    read_csv(opt$subjects) %>%
    filter(treatment %in% c('Baseline', 'Revision Mechanism', 'Standard Cheap Talk'))

group_level <- 
    read_csv(opt$group) %>%
    filter(treatment %in% c('Baseline', 'Revision Mechanism', 'Standard Cheap Talk'))


# --- Linear regression --- #
# Authors state that they cluster standard errors at the group level, so we do the same
message("Payoff Regression")
model_1 <-
    lm_robust(payoff ~ relevel(as.factor(treatment), ref = "Standard Cheap Talk") + 
              sex + game_theory + gpa_imputed,
              data = individual, 
              clusters = group_id_unique
    )

summary(model_1)

# min effort
message("Min Effort Regression")
model_2 <-
    lm_robust(min_effort ~ relevel(as.factor(treatment), ref = "Standard Cheap Talk"),
              data = group_level, 
              cluster = group_id_unique
    )

summary(model_2)

# freq 7's
message("Number of 7's Regression")
model_3 <-
    lm_robust(num_sevens ~ relevel(as.factor(treatment), ref = "Standard Cheap Talk"),
              data = group_level, 
              cluster = group_id_unique
    )

summary(model_3)

# full coord
message("Full Coordination Regression")
model_4 <-
    lm_robust(full_coord ~ relevel(as.factor(treatment), ref = "Standard Cheap Talk"),
              data = group_level, 
              cluster = group_id_unique
    )

summary(model_4)

# model 5
message("Equil Deviation Regression")
model_5 <-
    lm_robust(eqn_dev ~ relevel(as.factor(treatment), ref = "Standard Cheap Talk") + 
              sex + game_theory + gpa_imputed,
              data = individual, 
              clusters = group_id_unique
    )

summary(model_5)

# --- Save --- #
reg_list <- list(
    'mod1' = model_1,
    'mod2' = model_2,
    'mod3' = model_3,
    'mod4' = model_4,
    'mod5' = model_5
    )

# --- Export --- #
list.save(reg_list, 
          opt$out)