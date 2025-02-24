# --- Libraries --- #
library(estimatr)
library(readr)
library(dplyr)
library(rlist)
library(optparse)

#--- CLI parsing --- #
option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a csv file subject of group decisions",
                metavar = "character"
                ),
	make_option(c("-o", "--out"),
                type = "character",
                default = "result_01_robust.csv",
                help = "output file name [default = %default]",
                metavar = "character"
                )
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("Group by Period summary data must be provided", call. = FALSE)
}


# --- Load Data -- #
group_level <- 
    read_csv(opt$data)

# --- Filter treatments --- # 
group_level <-
    group_level %>%
    filter(treatment %in% 
        c('Baseline', 'Revision Mechanism', 'Standard Cheap Talk')
        )

# --- Run Analysis --- #
# --- Linear regression --- #
# Authors state that they cluster standard errors at the group level, so we do the same
message("Payoff Regression")
model_1 <-
    lm_robust(payoff ~ relevel(as.factor(treatment), ref = "Standard Cheap Talk") + 
                  as.factor(period),
              data = group_level, 
              clusters = group_id_unique
    )

# model 2
message("efficiency Regression")
model_2 <-
    lm_robust(efficiency ~ relevel(as.factor(treatment), ref = "Standard Cheap Talk") + 
                  as.factor(period),
              data = group_level,
              clusters = group_id_unique
    )

# min effort
message("Min Effort Regression")
model_3<-
    lm_robust(min_effort~ relevel(as.factor(treatment), ref = "Standard Cheap Talk") + 
                  as.factor(period),
              data = group_level,
              cluster = group_id_unique
    )

# freq 7's
message("Number of 7's Regression")
model_4 <-
    lm_robust(num_sevens ~ relevel(as.factor(treatment), ref = "Standard Cheap Talk") + 
                  as.factor(period),
              data = group_level,
              cluster = group_id_unique
    )

# full coord
message("Full Coordination Regression")
model_5 <-
    lm_robust(full_coord ~ relevel(as.factor(treatment), ref = "Standard Cheap Talk") + 
                  as.factor(period),
              data = group_level, 
              cluster = group_id_unique
    )

# model 5
message("Equil Deviation Regression")
model_6 <-
    lm_robust(eqn_dev ~ relevel(as.factor(treatment), ref = "Standard Cheap Talk") + 
                  as.factor(period),
              data = group_level,
              clusters = group_id_unique
    )

# model 7
model_7 <-
    lm_robust(eff_dev ~ relevel(as.factor(treatment), ref = "Standard Cheap Talk") + 
                  as.factor(period),
              data = group_level,
              clusters = group_id_unique
    )

model_8 <-
    lm_robust(effort_4 ~ relevel(as.factor(treatment), ref = "Standard Cheap Talk") + 
                  as.factor(period),
              data = group_level,
              clusters = group_id_unique
    )

model_9 <-
    lm_robust(effort_5 ~ relevel(as.factor(treatment), ref = "Standard Cheap Talk") + 
                  as.factor(period),
              data = group_level,
              clusters = group_id_unique
    )

model_10 <-
    lm_robust(effort_6 ~ relevel(as.factor(treatment), ref = "Standard Cheap Talk") + 
                  as.factor(period),
              data = group_level,
              clusters = group_id_unique
    )
summary(model_10)
# --- Save --- #
reg_list <- list(
    'mod1' = model_1,
    'mod2' = model_2,
    'mod3' = model_3,
    'mod4' = model_4,
    'mod5' = model_5,
    'mod6' = model_6,
    'mod7' = model_7,
    'mod8' = model_8,
    'mod9' = model_9,
    'mod10' = model_10
)

# --- Export --- #
list.save(reg_list, 
          opt$out)

