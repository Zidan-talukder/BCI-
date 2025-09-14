function avg_acc = feat_fus_res(fcInd,feat_bank,classifier) % for folds

for s = 1:size(feat_bank,3)%subjects
    FFres=[];
    for F=1:size(feat_bank,2) % fold
        feature_train = []; feature_test = []; result_fold_mat = [];
        for fc = fcInd
            feature_train = [feature_train feat_bank(fc,F,s).train_feat];
            feature_test = [feature_test feat_bank(fc,F,s).test_feat];
            
            if isequal(classifier,'LDA')
                result_fold_mat = my_LDA(feature_train,feat_bank(fc,F,s).lb_train,feature_test,feat_bank(fc,F,s).lb_test);
            elseif isequal(classifier,'MLP')
                result_fold_mat =  myMLP(feature_train,feat_bank(fc,F,s).lb_train, feature_test, feat_bank(fc,F,s).lb_test);
            elseif isequal(classifier,'SVM')
                result_fold_mat = my_SVM (feature_train,feat_bank(fc,F,s).lb_train,feature_test,feat_bank(fc,F,s).lb_test);
            end
            

        end
        FFres(F) = mean(result_fold_mat);
    end%fold
    Sres(s)= mean(FFres);    
end%subject

avg_acc = mean(Sres);


    

