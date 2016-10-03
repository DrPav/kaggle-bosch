#10 - Feature importance with random forest
library(data.table)
library(dplyr)
df = fread("data-transformed/response.csv") %>%
  inner_join(fread("data-transformed/numeric_noNA.csv")) %>%
  inner_join(fread("data-transformed/date_noNA.csv")) %>%
  inner_join(fread("data-transformed/categorical_noNA_binary.csv")) %>%
  inner_join(fread("data-transformed/05-for-bayes-sample.csv")) %>%
  inner_join(fread("data-transformed/date_timespan.csv"))

write.csv(df, "data-transformed/sampled-data-joined.csv", row.names = F)

#Still too large for random forest

library(caret)
set.seed(999)
# #Re sample to make smaller
# sampleIndex <- createDataPartition(df$Response, p = .33,
#                                    list = FALSE,
#                                    times = 1)
# 
# df = df[sampleIndex, ]
# summary(df$Response)

library(randomForest)


rf = randomForest(Response ~.,
                  data =df,
                  ntree = 500 ,
                  mtry = 100
                  )

