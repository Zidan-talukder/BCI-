function [resV resT] = feat_fus_res(fcInd,feat_bank,classifier,s) % for folds


    FFresV=[]; FFresT=[];
    for F=1:size(feat_bank,2) % fold
        feature_train = []; feature_test = [];feature_valid = []; result_fold_mat = [];
        for fc = fcInd
            feature_train = [feature_train feat_bank(fc,F,s).train_feat];
            feature_test = [feature_test feat_bank(fc,F,s).test_feat];
            feature_valid = [feature_valid feat_bank(fc,F,s).valid_feat];
        end    
        
        if isequal(classifier,'LDA')
            [resV resT] = my_LDA_val(feature_train,feat_bank(fc,F,s).lb_train,...
                feature_valid,feat_bank(fc,F,s).lb_valid,...
                feature_test,feat_bank(fc,F,s).lb_test);
%         elseif isequal(classifier,'MLP')
%             result_fold_mat =  myMLP(feature_train,feat_bank(fc,F,s).lb_train, feature_test, feat_bank(fc,F,s).lb_test);%still not implemented for validation
%         elseif isequal(classifier,'SVM')
%             result_fold_mat = my_SVM (feature_train,feat_bank(fc,F,s).lb_train,feature_test,feat_bank(fc,F,s).lb_test);%still not implemented for validation
         end
       
        FFresV(F) = resV;        
        FFresT(F) = resT;
        
    end%fold
   resV = mean(FFresV); 
   resT = mean(FFresT);





    

