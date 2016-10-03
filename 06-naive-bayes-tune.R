#Naive Bayes with Caret
library(caret)
library(dplyr)
train = read.csv("data-transformed/05-for-bayes-sample.csv")
y = read.csv("data-sampled/train_numeric.csv") %>% select(Id, Response)
train = left_join(train, y)
train$Response = as.logical(train$Response)
train$Id <- NULL
rm(y)
gc()

#nb
#nbDiscrete

fitControl <- trainControl(## 3-fold CV
  method = "cv",
  number = 3
  )

set.seed(825)
nbFit1 <- train(Response ~ ., data = train,
                 method = "nb",
                 trControl = fitControl
                 )
nbFit1

