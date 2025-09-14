function [resV resT] = feat_fus_res_val(fcInd,feat_bank,classifier) % for folds

for s = 1:size(feat_bank,3)%subjects
   FFresV=[]; FFresT=[];
    for F=1:size(feat_bank,2) % fold
        feature_train = []; feature_test = []; result_fold_mat = [];
        for fc = fcInd
            feature_train = [feature_train feat_bank(fc,F,s).train_feat];
            feature_test = [feature_test feat_bank(fc,F,s).test_feat];
            feature_valid = [feature_valid feat_bank(fc,F,s).valid_feat];
        end
        if isequal(classifier,'LDA')
            [resV resT] = my_LDA_val(feature_train,feat_bank(fc,F,s).lb_train,...
                feature_valid,feat_bank(fc,F,s).lb_valid,...
                feature_test,feat_bank(fc,F,s).lb_test);
        elseif isequal(classifier,'MLP')
            result_fold_mat =  myMLP(feature_train,feat_bank(fc,F,s).lb_train, feature_test, feat_bank(fc,F,s).lb_test);
        elseif isequal(classifier,'SVM')
            result_fold_mat = my_SVM (feature_train,feat_bank(fc,F,s).lb_train,feature_test,feat_bank(fc,F,s).lb_test);
        end
            

        

    end%fold
         FFresV(F) = resV;        
        FFresT(F) = resT;
end%subject

   resV(s) = mean(FFresV); 
   resT(s) = mean(FFresT);  


    

