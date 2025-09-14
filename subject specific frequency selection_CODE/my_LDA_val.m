function [resV resT] = my_LDA (train_data,train_lb,valid_data,valid_lb,test_data,test_lb)

train_data (:,end+1) = train_lb;
test_data(:,end+1) = test_lb;
valid_data(:,end+1) = valid_lb;
ldaParams = LDA_Train(train_data);
result_valid= LDA_Test(valid_data, ldaParams);
result_test = LDA_Test(test_data,ldaParams);

resV = result_valid.accuracy ; 
resT = result_test.accuracy;
