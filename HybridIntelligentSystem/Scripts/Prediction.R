setwd("F:/WorkingDirectory")

########Training Data : Original Version#########

train_data_2b <- read.csv("C:/Users/Sakthi/Desktop/Soft_Copies_NUS/Semester - II/KE-U7-FangMing-CA/ws2B/trialPromoResults.csv")

#######OverSampled Training Dataset : SMOTE in Weka#########

check_train<- read.csv("C:/Users/Sakthi/Desktop/Soft_Copies_NUS/Semester - II/KE-U7-FangMing-CA/ws2B/Over_Under_Sample.csv")
check_test <- read.csv("C:/Users/Sakthi/Desktop/Soft_Copies_NUS/Semester - II/KE-U7-FangMing-CA/ws2B/custdatabase.csv")

########Testing Data#########

test_data <- read.csv("C:/Users/Sakthi/Desktop/Soft_Copies_NUS/Semester - II/KE-U7-FangMing-CA/ws2B/custdatabase.csv")

customer_actual_data <- read.csv("C:/Users/Sakthi/Desktop/Soft_Copies_NUS/Semester - II/KE-U7-FangMing-CA/ws2B/Cust_Actual.csv")

#######Decision Tree with Original Dataset########
require(rpart)
rpart_result <- rpart(decision~sex+mstatus+age+children+occupation+education+income+avbal+avtrans, data=train_data_2b)
plotcp(rpart_result)
printcp(rpart_result)
summary(rpart_result)
rpart_predict <- predict(rpart_result,test_data_2b,type="class")
conf_matrix <- table(customer_actual_data$status,rpart_predict)
conf_matrix
accuracy <- ((conf_matrix[1,1] + conf_matrix[2,2] + conf_matrix[3,3])/sum(conf_matrix))
accuracy * 100

#######Decision Tree with Sampled Dataset########

require(rpart)
rpart_result <- rpart(decision~sex+mstatus+age+children+occupation+education+income+avbal+avtrans, data=check_train)
rpart_predict <- predict(rpart_result,check_test,type="class")
conf_matrix <- table(customer_actual_data$status,rpart_predict)
conf_matrix
accuracy <- ((conf_matrix[1,1] + conf_matrix[2,2] + conf_matrix[3,3])/sum(conf_matrix))
accuracy * 100
accuracy
rpart_predict
write.csv(rpart_predict, file ="rpart_tree_result.csv")

#######Random Forest with Sampled Dataset########

library("randomForest")
rf_model <- randomForest(decision~.,check_train,ntree=500)
rf_predict <- predict(rf_model,check_test,type="class")
conf_matrix_rf <- table(customer_actual_data$status,rf_predict)
conf_matrix_rf
write.csv(rf_predict, file ="rf_tree_result.csv")

library("caret")
fitControl <- trainControl(method = "repeatedcv",number = 5,repeats = 3)
set.seed(5)
# Random Forest with different set of random predictors(mtry)
fit <- train(decision ~ ., data = check_train,method = "rf",trControl = fitControl,tuneGrid=data.frame(mtry=c(5,10,15,20,25)), verbose = TRUE)

random_forest_predict <- predict(fit,test_data)
table(customer_actual_data$status,random_forest_predict)

fitControl <- trainControl(## 10-fold CV
  method = "repeatedcv",
  number = 5,
  ## repeated ten times
  repeats = 5)

#######Bagged Decision Tree with Sampled Dataset########

treefit <- train(decision ~ ., data = check_train,
                 method = "treebag",
                 trControl = fitControl,
                 ## This last option is actually one
                 ## for gbm() that passes through
                 verbose = FALSE)

#Print the results
treefit

treefit_predict <- predict(treefit,check_test)
treefit_conf_matrix <- table(customer_actual_data$status,treefit_predict)
treefit_conf_matrix
treefit_accuracy <- ((treefit_conf_matrix[1,1] + treefit_conf_matrix[2,2] + treefit_conf_matrix[3,3])/sum(treefit_conf_matrix))
treefit_accuracy * 100

#######k-NN with Sampled Dataset########

library(class)
knn_train<- read.csv("C:/Users/Sakthi/Desktop/WS-2B-Screenshots/Over_Under_Sample_saved.csv")
knn_test<- read.csv("C:/Users/Sakthi/Desktop/WS-2B-Screenshots/custdatabase_saved.csv")
knn_model<- knn(train=knn_train,test=knn_test,cl=knn_train$TNM_decision, k=3)
knn_predict<-table(customer_actual_data$status,knn_model)
write.csv(knn_model, file ="knn_result.csv")
