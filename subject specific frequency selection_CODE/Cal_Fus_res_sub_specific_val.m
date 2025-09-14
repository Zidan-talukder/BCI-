clear all;
close all;
clc;

load feat_fus_log_var_win_val %feat_fus_log_var_win   feat_fus_log_var

classifier = 'LDA'; resS=[];
fprintf('flow=%d fhigh=%d fHop=%d fSpan=%d winsize=%2.2f winhop=%2.2f featureN=%s nfold=%d cspPair=%d\n',flow, fhigh, fHop, fSpan, winsize, winhop, featureN, nfold, cspPair)
%%---------------------------------------------
%searchin cofusion combination with increasing optimum-add algorithm
disp('Increasing Optimum add')
for s = 1:size(feat_bank,3)%subjects
    fprintf('for subject: %d',s); 
    
    tFF= [];  FF= 1:size(feat_bank,1); %frequency 
    prev_resV = 0;    prev_resT = 0;
    %feat_fus_res(tFF,feat_bank,classifier);   fprintf('Top feat=%2i, %s: Res=%2.2f ',tFF,FeatS{tFF},prev_res);
    while (length(FF)>0)
        resV=[]; rerT=[];    fprintf(' \n Searching indv(+) res : ');
        for i=1:length(FF)
            [resV(i) resT(i)] = feat_fus_res_sub_specific_val([tFF FF(i)],feat_bank,classifier,s);   
            fprintf(' %2.2f ',resV(i));     %fprintf(' %2.2f ',res(i));          
        end
        %fprintf('Valid = [%s],\n Test = [%s] ', num2str(resV), num2str(resT) );
        [v, mi] = max(resV);
        t = resT(mi);
        
        if  v > prev_resV 
            tFF = [tFF FF(mi)];     
            fprintf('\n Found and added: feat=%2i, Low=%s: Res=%2.2f new tFF =[ %s ] ',FF(mi),FeatS{FF(mi)},v, num2str(tFF) );
            prev_resV = v; FF(mi)=[];
            prev_resT = t;
        else 
            break;
        end        
    end
%    fprintf('\n Found and added: feat=%2i, Low=%s: Res=%2.2f new tFF =[ %s ] ',FF(mi),FeatS{FF(mi)},v, num2str(tFF) );

    resS(s)=prev_resT;
    resB(s)=prev_resV;
    
    fprintf('\n');
end%subject
fprintf('Test result');disp(resS)
fprintf('validation result');disp(resB)

fprintf('Increasing add algorithm AVERAGE Based on Test = %2.2f \n', mean(resS));
fprintf('Increasing add algorithm AVERAGE Based on Validation = %2.2f \n', mean(resB));
fprintf('\n');



%%% searchin cofusion combination with decreasing optimum-subtr algorithm
% disp('Decreasing Optimum subtractor')
% resS1=[];
% for s = 1:size(feat_bank,3)%subjects
%     fprintf('\nfor subject: %d\n',s);  
%     prev_res = feat_fus_res_sub_specific([1],feat_bank,classifier,s);  %fprintf('Top feat=%2i, %s: Res=%2.2f ',1,FeatS{1},prev_res);
%     FF=1:size(feat_bank,1); hres= feat_fus_res_sub_specific(FF,feat_bank,classifier,s); fprintf('\nCombined feat=%s,: Res=%2.2f ',num2str(FF),hres);% disp(FeatS)
%     
%     while (length(FF)>1)
%         res=[];         %fprintf('\n Searching indv(-) res : ');
%         for i=1:length(FF) 
%             tFF=FF; tFF(i)=[]; 
%             res(i)= feat_fus_res_sub_specific(tFF,feat_bank,classifier,s);  %fprintf(' %2.2f ',res(i)); 
%         end
%         [v, mi]=max(res);
% 
%         if v>=hres
%             hres=v;  %fprintf('\n Found and discarded: feat= %i, %s:  ',FF(mi),FeatS{FF(mi)});
%             FF(mi)=[];  %fprintf(' Res=%2.2f new tFF =[ %s ] ',v, num2str(FF) );
%         else
%             break;
%         end    
% 
%     end %while
%     fprintf('\n Found and discarded: feat= %i, %s:  ',FF(mi),FeatS{FF(mi)});
%     fprintf(' Res=%2.2f new tFF =[ %s ] ',v, num2str(FF) );
%     resS1(s)=hres;
%     fprintf('\n'); 
% end
% resS1
% fprintf('Decreasing Sub_tr algorithm,  AVERAGE = %2.2f \n', mean(resS1));