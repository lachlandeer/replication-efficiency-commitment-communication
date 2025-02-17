library(readr) 
library(dplyr)
library(gt)


 s
read_csv("out/analysis/result_01_tests.csv") %>%
    select(group1, group2, statistic, p, n1, n2) %>%
    mutate(p = if_else(p < 0.001, "<0.000", as.character(p))) %>%
    gt() %>%
    cols_label(
        group1 = "Treatment 1",
        group2 = "Treatment 2",
        statistic = "Test Statistic",
        p = "p-value",
        n1 = "N. Obs. Treatment 1",
        n2 = "N. Obs. Treatment 2"
    )
    #fmt_number(decimals = 3)
