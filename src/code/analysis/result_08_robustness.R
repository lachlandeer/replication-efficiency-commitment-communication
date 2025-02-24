# --- Libraries --- #
library(estimatr)
library(readr)
library(dplyr)
library(rlist)
library(optparse)

# --- CLI Parsing --- # 
option_list = list(
    make_option(c("-d", "--decisions"),
                type = "character",
                default = NULL,
                help = "a csv group level decisions by period",
                metavar = "character"
                ),
    make_option(c("-m", "--messages"),
                type = "character",
                default = NULL,
                help = "a csv group level decisions by period",
                metavar = "character"
                ),
	make_option(c("-o", "--out"),
                type = "character",
                default = "results.csv",
                help = "output file name [default = %default]",
                metavar = "character"
                )
    );

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$decisions)){
  print_help(opt_parser)
  stop("Group level decisions must be provided", call. = FALSE)
}
if (is.null(opt$messages)){
  print_help(opt_parser)
  stop("Group level message data must be provided", call. = FALSE)
}

# --- Load the Data --- #
message("Loading Decisions data")
group_level <- 
    read_csv(opt$decisions) %>% 
    filter(treatment == "Revision Cheap Talk") %>%
    mutate(time = "decision") %>%
    mutate(full_coord = as.numeric(full_coord)) %>% 
    select(group_id_unique, period, min_effort, full_coord, num_sevens, payoff, eqn_dev, choice, time,
            eff_dev, effort_4, effort_5, effort_6
            )

message("Loading Message data")
group_level_messages <-
    read_csv(opt$messages) %>%
    mutate(time = "pre-play") %>%
    select(group_id_unique = group_id, period, min_effort, full_coord, num_sevens, payoff, eqn_dev, choice, time,
            eff_dev, effort_4, effort_5, effort_6
    )

# bind the data frames
message("Binding Data")
group_level <-
    bind_rows(group_level, group_level_messages)

head(group_level)

# --- Run Analysis --- #
# --- Linear regression --- #
# Authors state that they cluster standard errors at the group level, so we do the same
message("Payoff Regression")
model_1 <-
    lm_robust(payoff ~ relevel(as.factor(time), ref = "pre-play") + 
                  as.factor(period),
              data = group_level, 
              clusters = group_id_unique
    )

# model 2
# message("efficiency Regression")
# model_2 <-
#     lm_robust(efficiency ~ relevel(as.factor(time), ref = "pre-play") + 
#                   as.factor(period),
#               data = group_level,
#               clusters = group_id_unique
#     )

# min effort
message("Min Effort Regression")
model_3<-
    lm_robust(min_effort~ relevel(as.factor(time), ref = "pre-play") + 
                  as.factor(period),
              data = group_level,
              cluster = group_id_unique
    )

# freq 7's
message("Number of 7's Regression")
model_4 <-
    lm_robust(num_sevens ~ relevel(as.factor(time), ref = "pre-play") + 
                  as.factor(period),
              data = group_level,
              cluster = group_id_unique
    )

# full coord
message("Full Coordination Regression")
model_5 <-
    lm_robust(full_coord ~ relevel(as.factor(time), ref = "pre-play") + 
                  as.factor(period),
              data = group_level, 
              cluster = group_id_unique
    )

# model 5
message("Equil Deviation Regression")
model_6 <-
    lm_robust(eqn_dev ~ relevel(as.factor(time), ref = "pre-play") + 
                  as.factor(period),
              data = group_level,
              clusters = group_id_unique
    )

# model 7
model_7 <-
    lm_robust(eff_dev ~ relevel(as.factor(time), ref = "pre-play") + 
                  as.factor(period),
              data = group_level,
              clusters = group_id_unique
    )

model_8 <-
    lm_robust(effort_4 ~ relevel(as.factor(time), ref = "pre-play") + 
                  as.factor(period),
              data = group_level,
              clusters = group_id_unique
    )

model_9 <-
    lm_robust(effort_5 ~ relevel(as.factor(time), ref = "pre-play") + 
                  as.factor(period),
              data = group_level,
              clusters = group_id_unique
    )

model_10 <-
    lm_robust(effort_6 ~ relevel(as.factor(time), ref = "pre-play") + 
                  as.factor(period),
              data = group_level,
              clusters = group_id_unique
    )
summary(model_10)
# --- Save --- #
reg_list <- list(
    'mod1' = model_1,
    # 'mod2' = model_2,
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

