function results = my_LDA (train_data,train_lb,test_data,test_lb)

train_data (:,end+1) = train_lb;
test_data(:,end+1) = test_lb;
ldaParams = LDA_Train(train_data);
result = LDA_Test(test_data,ldaParams);
results = result.accuracy;