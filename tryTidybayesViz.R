# Visualization attempt using Tidybayes

require(tidyverse)
require(tidybayes)
require(here)

load(here("IEEEModel.RData"))

## Tidybayes draws
get_variables(IEEE.mod)

# how do I get original values for index variables back?
# recover_types() does not work, probably because of the way I specified my data frame before I entered it into the model

# extract draws for different predictors
draws <- IEEE.mod %>%
  # I'm not sure if the r_listener bit is correct; it creates a column with listener ID, term (intercept or dBSPL slope), and the value. 
  spread_draws(b_Intercept, 
               b_manipulation, 
               b_dBSPL,
               b_group,
               `b_manipulation:group`,
               `b_dBSPL:group`,
               `b_manipulation:dBSPL:group`,
               r_listener[listener,term]) %>%
  # spread to fix these weird r_listener columns - must be a smarter way
  spread(term, r_listener) %>% 
  rename(r_listener_intercept = Intercept,
         r_listener_slope = dBSPL) %>% 
  # create estimates for individual levels of a predictor
  # I don't understand why I need this r_listener stuff - and it's probably not even right because of this spread business above. I don't understand what it means either.
  mutate(manip = b_Intercept + 
           b_manipulation + r_listener_slope + r_listener_intercept)




