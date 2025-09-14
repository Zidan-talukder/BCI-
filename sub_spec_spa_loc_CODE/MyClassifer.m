function result = MyClassifer(feature_train,y_train,feature_test,y_test, clssifier)


switch clssifier
    case 'LDA'
        result = my_LDA(feature_train,y_train,feature_test,y_test);
    case 'SVM'    
        result = my_SVM(feature_train,y_train,feature_test,y_test);
    case 'MLP'
        for c=1:2   R(c)=myMLP_2c(feature_train,y_train,feature_test,y_test);    end;     result =  max(R); 
end