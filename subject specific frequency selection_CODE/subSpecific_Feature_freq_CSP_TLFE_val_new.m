%this is the code for specific frequency selection experiment. here
%we are trying to observe the performance of each frequency band and how it
%affects the overall accuracy of the model

%this portion of the code is used to record every frequency band
%information and afterwards with the help of "Cal_Fus_res_val.m" 
%frequency band which provides additive performance is found

clear all; close all; clc;

chn=[];%for empty channel use "[]"

startEpoch=0.5;
endEpoch=4.8;

order=4;%order of the butterworth filter
%frequency parameters
flow=6; fhigh=20;
fHop=1; 
fSpan=2;

clssifier = 'LDA';
featureN= 'log_Var';%log_Var, log_Var_Win, log_Var_Wavedec, katz, katz_Wavedec, higuchi, higuchi_Wavedec, MAV, RMS,  Eng, Ent, fft, katz_Win

nfold = 5;%folding size

%parameters for time window selection.
%only selected on "log_Var_Win" and "katz_Win"
global winsize winhop; 
winsize=3.6;
winhop=0.2;

cspPair=3;

fprintf('TLFE: SE=%1.1f, EE=%1.1f, Ch=%s, Ord=%d, L=%d, H=%d, feature=%s,  Classif=%s winsize=%1.1f winhop=%1.1f \n'...
    ,startEpoch,endEpoch, num2str(chn),order,flow,fhigh, featureN, clssifier, winsize, winhop);

%[raw_dataTrain] = data_read(startEpoch,endEpoch);%turn on this portion of
%when conducting experiment for startepoch and endEpoch

 %BCI_C4D1; %BCI_C4D1_allsub_4s; %BCI_C4D1;%   BCI_C4D1_sub1267_4s; % 

% hf = [14, 20, 27, 40];
% lf = [6, 16];   %, 15, 22];


 for flow= flow:fHop:fhigh
    
    low=flow;
    high=low+fSpan;
    load BCI_C4D1.mat
    nbSubjects = length(raw_dataTrain);
    for s=1:nbSubjects
        dataTrainS = raw_dataTrain{s};

        %channel selection
        if (~isempty(chn)) 
            dataTrainS.x = dataTrainS.x(chn,:,:);
        end %if
        %sorting data classwise
         Lb = dataTrainS.y; ind_c1 = find(Lb==1); ind_c2 = find(Lb==2);
         dataTrainS.x =dataTrainS.x(:,:,[ind_c1 ind_c2]);   
         dataTrainS.y =dataTrainS.y([ind_c1 ind_c2]);

         %folding loop
         for fold = 1:nfold
             dataTrain = dataTrainS;
             dataTest.y = dataTrain.y(fold:nfold:end);
             dataTest.x = dataTrain.x(:,:,fold:nfold:end);
             dataTest.sf = dataTrain.sf; 
             dataTrain.y(fold:nfold:end)=[]; 
             dataTrain.x(:,:,fold:nfold:end)=[];        
             %for validation set
             si=fold;% 2 3 4
             if(fold==nfold) si=1; end

             dataValid.y = dataTrain.y(si:(nfold-1):end);
             dataValid.x = dataTrain.x(:,:,si:(nfold-1):end);
             dataValid.sf = dataTrain.sf; 
             dataTrain.y(si:(nfold-1):end)=[]; 
             dataTrain.x(:,:,si:(nfold-1):end)=[];         
    %          % disp('Train Test Divided ...'); 



             fb=1;%fb= frequency band, for csp and tlfe band number is one.


                dataTrain_f = eegButterFilter(dataTrain, low, high, order);
                dataTest_f = eegButterFilter(dataTest, low, high, order);
                dataValid_f = eegButterFilter(dataValid, low, high, order);


                [dataTrain_f.x, dataTest_f.x,dataValid_f.x] = MC_CSP_val(dataTrain_f,dataTest_f,dataValid_f,cspPair);

                feat_bank(fb,fold,s).train_feat = extractFeature(dataTrain_f.x,featureN); 
                feat_bank(fb,fold,s).test_feat = extractFeature(dataTest_f.x,featureN);
                feat_bank(fb,fold,s).valid_feat = extractFeature(dataValid_f.x,featureN);

                feat_bank(fb,fold,s).lb_train = dataTrain.y;  
                feat_bank(fb,fold,s).lb_test = dataTest.y; 
                feat_bank(fb,fold,s).lb_valid = dataValid.y; 

             FeatS{fb}=num2str(low);

             %fprintf('\n folding no: %d for subject: %d \n',fold ,s)
         end%fold loop end
        % fprintf('\n done for subject: %d \n',s);
    end%subject loop
   % disp('Done for all the subjects. Now saving!!')
    save feat_fus_log_var_win_val feat_bank FeatS flow fhigh fHop fSpan winsize winhop featureN nfold cspPair           %classifier   feat_fus_log_var, feat_fus_log_var_win
   % disp('saved')


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    load feat_fus_log_var_win_val %feat_fus_log_var_win   feat_fus_log_var

    classifier = 'LDA'; resS=[];
    fprintf('flow=%d fhigh=%d fHop=%d fSpan=%d winsize=%2.2f winhop=%2.2f featureN=%s nfold=%d cspPair=%d\n',flow, flow+fSpan, fHop, fSpan, winsize, winhop, featureN, nfold, cspPair)
    %%---------------------------------------------
    %searchin cofusion combination with increasing optimum-add algorithm
    disp('Increasing Optimum add')
    for s = 1:size(feat_bank,3)%subjects
        fprintf('for subject: %d',s); 

        tFF= [];  FF= 1:size(feat_bank,1);
        prev_resV = 0;    prev_resT = 0;
        %feat_fus_res(tFF,feat_bank,classifier);   fprintf('Top feat=%2i, %s: Res=%2.2f ',tFF,FeatS{tFF},prev_res);
        while (length(FF)>0)
            resV=[]; rerT=[];    %fprintf(' \n Searching indv(+) res : ');
            for i=1:length(FF)
                [resV(i) resT(i)] = feat_fus_res_sub_specific_val([tFF FF(i)],feat_bank,classifier,s);  % fprintf(' %2.2f ',res(i));             
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
      %  fprintf('\n Found and added: feat=%2i, Low=%s: Res=%2.2f new tFF =[ %s ] ',FF(mi),FeatS{FF(mi)},v, num2str(tFF) );

        resS(s)=prev_resT;
        resB(s)=prev_resV;
        
        index1=4;%keep this as initial start frequency and access result_mat for accessing subject wise data for excel format. if the fhop is not 2 then error would occur
        index=index_funct(flow,index1);%if the fhop is not 2 then error would occur in this function
        result_mat(index, s)  = prev_resT;

        fprintf('\n');
    end%subject
            
    fprintf('Test result');disp(resS)
    
    fprintf('validation result');disp(resB)
    fb_num=index_funct(flow,index1);%frequency band number.found using low frequency
    mean_Res_mat(fb_num)=mean(resS);
    
    fprintf('Increasing add algorithm AVERAGE Based on Test = %2.2f \n', mean(resS));
    fprintf('Increasing add algorithm AVERAGE Based on Validation = %2.2f \n', mean(resB));
    fprintf('\n');


end%for frequency selection  

