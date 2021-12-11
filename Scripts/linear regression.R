library(tidymodels)
library(vip) # for variable importance



job <- read.csv('jobsdata.csv',header=T)






#----------------
set.seed(271)

# Create a split object
jobs_split <- initial_split(job, prop = 0.75, 
                             strata = salary)

# Build training data set
jobs_training <- jobs_split %>% 
  training()

# Build testing data set
jobs_test <- jobs_split %>% 
  testing()


jobs_recipe <- recipe(salary ~ ., data = jobs_training) %>% 
  step_YeoJohnson(all_numeric(), -all_outcomes()) %>% 
  step_normalize(all_numeric(), -all_outcomes()) %>% 
  step_dummy(all_nominal(), - all_outcomes())


jobs_recipe %>% 
  prep(training = jobs_training) %>% 
  bake(new_data = jobs_test)

lm_model <- linear_reg() %>% 
  set_engine('lm') %>% 
  set_mode('regression')

jobs_workflow <- workflow() %>% 
  add_model(lm_model) %>% 
  add_recipe(jobs_recipe)

jobs_fit <- jobs_workflow %>% 
  last_fit(split = jobs_split)

jobs_fit %>% 
  collect_metrics()

# Obtain test set predictions data frame
jobs_results <- jobs_fit %>% 
  collect_predictions()
# View results
jobs_results


ggplot(data = jobs_results,
       mapping = aes(x = .pred, y = salary)) +
  geom_point(alpha = 0.2) +
  geom_abline(intercept = 0, slope = 1, color = 'red', linetype = 2) +
  coord_obs_pred() +
  labs(title = 'Linear Regression Results',
       x = 'Predicted salary',
       y = 'Actual salary') +
  theme_light()


jobs_training_baked <- jobs_recipe %>% 
  prep(training = jobs_training) %>% 
  bake(new_data = NULL)

# View results
jobs_training_baked

jobs_lm_fit <- lm_model %>% 
  fit(salary ~ ., data = jobs_training_baked)

vip(jobs_lm_fit)

