library(ggplot2)
library(dplyr)
library(tibble)
library(tidyr)
library(corrplot)
library(randomForest)
library(caret)
library(rpart)
library(visTree)
library(rpart.plot)
setwd("/Users/hamzasheikh/Desktop/DAEN/final")
getwd()
## Reading the files
data <- read.csv("NewData_new.csv")
data
dim(data)
str(data)
#data$new_category<- lapply(data$new_category, as.numeric)
#data$new_category <- as.numeric(factor(data$new_category))
#str(data)
#library(lubridate)
#dataset$Box <- as.numeric(factor(dataset$Box))
#data$posted_date=as.Date.factor(data$posted_date,"mdy")
#str(data)
## 75% of the sample size
smp_size <- floor(0.80 * nrow(data))

## set the seed to make your partition reproducible
set.seed(123)
train_ind <- sample(seq_len(nrow(data)), size = smp_size)
train_ind
train <- data[train_ind, ]
test <- data[-train_ind, ]

Rm_admin<-randomForest(salary~ +new_category+posted_date+Experience , data=train, ntree=270, importance=T,mtry=2)
Rm_admin
data.test=data[-train_ind,"salary"]
#data.test

yhat.rf = predict(Rm_admin,newdata=test)
yhat.rf
#(mean((yhat.rf-data.test)^2))
library(Metrics)

# Taking two vectors
# Calculating RMSE using rmse()         
result = rmse(data.test, yhat.rf)########
result
plot(Rm_admin)
importance(Rm_admin)
varImpPlot(Rm_admin)
# from the plot we can see the error becomes constant when o trees are close to 500 
#so we are going to use NoOfTrees=500
#predicting on test set
#Adm.test=AdminData1[-train,"Chance.of.Admit"]
#Adm.test
#set.seed(123)
#yhat.rf = predict(rf.Adm,newdata=AdminData1[-train,])
#sqrt(mean((yhat.rf-Adm.test)^2))
# TEST RMSE for this model is 0.074 which is little better than bagged
#importance(rf.Adm)
#varImpPlot(rf.Adm)



###############################################################################
train_control <- trainControl(method="cv", number=5)


# 4: RANDOM FOREST WITH CROSS VALIDATION WITH 300 TREES with all predictors
set.seed(123)
rf.cv=train(salary~ +new_category+posted_date+Experience,data=data
             ,importance=TRUE,trControl=train_control,ntree=300,method="rf")
# Summarise Results
print(rf.cv)

data.test=data[-train_ind,"salary"]
#data.=data[-train_ind,"posted_date"]
yhat.rf = predict(rf.cv,newdata=test)
yhat.rf

# Taking two vectors
# Calculating RMSE using rmse()         
result = rmse(data.test, yhat.rf)########
result
###################################################################################
###### DATA from LSI
install.packages("readxl")
library("readxl")

newdata <- read_excel("final_dataset.xlsx")
newdata
dim(newdata)
str(newdata)
newdata$posted_date=format(newdata$posted_date, format="%Y")
str(newdata)
train_control <- trainControl(method="cv", number=5)


# 4: RANDOM FOREST WITH CROSS VALIDATION WITH 300 TREES with all predictors
set.seed(123)
rf.cv=train(salary~ +title+posted_date+Experience,data=newdata
            ,importance=TRUE,trControl=train_control,ntree=300,method="rf")
# Summarise Results
print(rf.cv)









###################################################################################


ggplot(data.frame(yhat.rf, data.test), aes(x=yhat.rf ,y=data.test)) +
  geom_point() +
  geom_abline(slope=1,intercept=0) +
  labs(x="predicted", 
       y="test-set",
       title="Random forest regression tree")

