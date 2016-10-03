#Explore the date timestamps on sampled data

library(data.table)
library(dplyr)

dates = fread("data-sampled/train_date.csv")
id = dates$Id



#Get a min and max for each row
mins = dates %>% select(-Id) %>% apply(MARGIN = 1, min, na.rm = T) 
mins[mins == Inf] = 0

maxes = dates %>% select(-Id) %>% apply(MARGIN = 1, max, na.rm = T)
maxes[maxes == -Inf] = 0

new_df = data.frame(Id = id, date_min = mins, date_max = maxes) %>% mutate(date_timespan = date_max-date_min)
# #summary(select(new_df, -Id))
# Id             date_min         date_max      date_timespan   
# Min.   :     16   Min.   :   0.0   Min.   :   0.0   Min.   :  0.00  
# 1st Qu.: 596379   1st Qu.: 465.7   1st Qu.: 491.0   1st Qu.:  1.71  
# Median :1186834   Median : 878.0   Median : 887.6   Median :  3.71  
# Mean   :1184743   Mean   : 847.4   Mean   : 858.2   Mean   : 10.80  
# 3rd Qu.:1772914   3rd Qu.:1226.7   3rd Qu.:1238.5   3rd Qu.: 11.85  
# Max.   :2367440   Max.   :1713.7   Max.   :1718.5   Max.   :662.37  

write.csv(new_df, "data-transformed/date_timespan.csv", row.names = F)

#Boxplot timespan of good vs fail

response = fread("data-sampled/train_numeric.csv") %>% select(Id, Response)

new_df = new_df %>% inner_join(response)

library(ggplot2)
p = ggplot(new_df, aes(x = factor(Response), y = date_timespan))
p + geom_boxplot() + ylim(-5, 100)

# #Look at medians
# #Response = 1
# median(new_df[new_df$Response == 1, "date_timespan"])
# #4.84
# 
# #Response = 0
# median(new_df[new_df$Response == 0, "date_timespan"])
# #3.7

