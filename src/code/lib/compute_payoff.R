# --- Libraries --- #
library(dplyr)

#--- the payoff function ---
compute_payoff <- function(data, effort_col, group_col, time, gamma = 0.18, alpha = 0.2, beta = 0.04) {
    data %>%
        group_by(!!sym(group_col), !!sym(time)) %>%  # Group by the specified group column
        mutate(
            min_effort = min(!!sym(effort_col), na.rm = TRUE),  # Compute min effort in group
            payoff = gamma + alpha * min_effort - beta * !!sym(effort_col)  # Apply equation
        ) %>%
        ungroup() %>%
        select(-min_effort)
}