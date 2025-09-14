%it is used for mainly for adding all the frequency bands
clear all;
close all;
clc;

load feat_fus_log_var_win_val %feat_fus_log_var_win   feat_fus_log_var

classifier = 'LDA'; resS=[];
fprintf('flow=%d fhigh=%d fHop=%d fSpan=%d winsize=%2.2f winhop=%2.2f featureN=%s nfold=%d cspPair=%d\n',flow, fhigh, fHop, fSpan, winsize, winhop, featureN, nfold, cspPair)
%%---------------------------------------------
%searchin cofusion combination with increasing optimum-add algorithm
%disp('Increasing Optimum add')
for s = 1:size(feat_bank,3)%subjects
    fprintf('\nfor subject: %d',s); 
    
    tFF= [];  FF= 1:size(feat_bank,1); % frequency

%         resV=[]; rerT=[];    fprintf(' \n Individual Subject Result : ');
        for i=1:length(FF)
            [resV(i) resT(i)] = feat_fus_res_sub_specific_val([tFF FF(i)],feat_bank,classifier,s);        
        end
        fprintf('\n Valid = [%s],\n Test = [%s] ', num2str(resV), num2str(resT) );
        
        [v, mi] = max(resV);
        fprintf('\n For Validation : frequency bank =%2i, Low frequency =%s: Result=%2.2f ',FF(mi),FeatS{FF(mi)},v);
        
%         %t = resT(mi);
%         fprintf('\n For Test : frequency bank =%2i, Low frequency =%s: Result=%2.2f ',FF(mi),FeatS{FF(mi)},t);
              
        [t,ti] = max(resT);
        fprintf('\n For Test : frequency bank =%2i, Low frequency =%s: Result=%2.2f ',FF(ti),FeatS{FF(ti)},t);
                
            prev_resV = v; 
            prev_resT = t;
            
    resS(s)=prev_resT;
    resB(s)=prev_resV;
    
    fprintf('\n');
end%subject
fprintf('Test result');disp(resS)
fprintf('validation result');disp(resB)


fprintf('All Subject Over all Test = %2.2f \n', mean(resS));
fprintf('All Subject Over all Validation = %2.2f \n', mean(resB));
fprintf('\n');