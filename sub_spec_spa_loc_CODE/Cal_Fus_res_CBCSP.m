%it is used for mainly for adding all the frequency bands
clear all;
close all;
clc;

load feat_fus_log_var_win_val_chn %feat_fus_log_var_win   feat_fus_log_var

classifier = 'LDA'; resS=[];
fprintf('flow=%2.2f fhigh=%2.2f winsize=%2.2f winhop=%2.2f featureN=%s nfold=%d cspPair=%d\n',flow,fhigh, winsize, winhop, featureN, nfold, cspPair)
%%---------------------------------------------
%searchin cofusion combination with increasing optimum-add algorithm
%disp('Increasing Optimum add')
for s = 1:size(feat_bank,3)%subjects
    fprintf('\nfor subject: %d',s); 
    
    tFF= [];  FF= 1:size(feat_bank,1); % channel bank

%         resV=[]; rerT=[];    fprintf(' \n Individual Subject Result : ');
        for i=1:length(FF)
            [resV(i) resT(i)] = feat_fus_res_sub_specific_val([tFF FF(i)],feat_bank,classifier,s);        
        end
        %fprintf('\n Valid = [%s],\n Test = [%s] ', num2str(resV), num2str(resT) );
        
        [v, mi] = max(resV);
        %fprintf('\n For Validation : channel bank no =%2i, Channel Bank =%s Result=%2.2f ',FF(mi),FeatS{FF(mi)},v);
              
        [t,ti] = max(resT);
        fprintf('\n For Test : channel bank no =%2i, Channel Bank =%s Result=%2.2f \n',FF(ti),FeatS{FF(ti)},t);
          Every_Window_Accuracy =resT
          
         if isequal(Feats{1,(FF(ti))},'all channels')
             fprintf('\n MAP=All Channel\n');
         else
             MAP=map(Feats{1,(FF(ti))});
             
         end 
          %fprintf('\n For Test : frequency bank =%2i, Low frequency =%s: Result=%2.2f ',FF(mi),FeatS{FF(mi)},t);
                
            prev_resV = v; 
            prev_resT = t;
            
    resS(s)=prev_resT;
    resB(s)=prev_resV;
    
    fprintf('\n');
end%subject
fprintf('\n\nBest Test result');disp(resS)
%fprintf('Best validation result');disp(resB)


fprintf('All Subject Over all Best Test Result= %2.2f \n', mean(resS));
%fprintf('All Subject Over all Best Validation Result = %2.2f \n', mean(resB));
fprintf('\n');