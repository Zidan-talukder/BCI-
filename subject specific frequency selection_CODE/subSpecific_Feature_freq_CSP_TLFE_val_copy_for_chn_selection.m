%this is the code for specific frequency selection experiment. here
%we are trying to observe the performance of each frequency band and how it
%affects the overall accuracy of the model

%this portion of the code is used to record every frequency band
%information and afterwards with the help of "Cal_Fus_res_val.m" 
%frequency band which provides additive performance is found

clear all; close all; clc;

chn=[25 26 27 28 29 30 31 ];%for all channel use "[]" %for all channel use "[]" % [ 25:33 ]; % chn=[ 25 27 29 31 33  ]; %   chn=[ 27 29 31 ]; %  chn=[8 25 27 29 31 33 44 ];%

startEpoch=0.5;
endEpoch=4.8;

order=4;%order of the butterworth filter
%frequency parameters
flow=6; fhigh=16;
fHop=2; fSpan=8;

clssifier = 'LDA';
featureN= 'log_Var_Win';%log_Var, log_Var_Win, log_Var_Wavedec, katz, katz_Wavedec, higuchi, higuchi_Wavedec, MAV, RMS,  Eng, Ent, fft, katz_Win; ';%
nfold = 3;%folding size

%parameters for time window selection.
%only selected on "log_Var_Win" and "katz_Win"
global winsize winhop; 
winsize=3.6;
winhop=0.2;

cspPair=3;

fprintf('fbcsp: SE=%1.1f, EE=%1.1f, Ch=%s, Ord=%d, L=%d, H=%d, feature=%s,  Classif=%s winsize=%1.1f winhop=%1.1f \n'...
    ,startEpoch,endEpoch, num2str(chn),order,flow,fhigh, featureN, clssifier, winsize, winhop);

%[raw_dataTrain] = data_read(startEpoch,endEpoch);%turn on this portion of
%when conducting experiment for startepoch and endEpoch

load BCI_C4D1.mat %BCI_C4D1; %BCI_C4D1_allsub_4s; %BCI_C4D1;%   BCI_C4D1_sub1267_4s; % 
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
%              hf = [14, 20, 27, 40];
%              lf = [8, 11, 15, 22];
%            for k = 1:2
%                lowfreq = lf(k);
%                highfreq = hf(k);
%            end


         fb=1;%fb= frequency band,

%             
        %frequency selection
%          for
            low = flow;% this freq loop for testing subject specific performance across multiple frequency band 
            high=fhigh;
           
            fprintf('\nlowfreq=%d highfreq= %d, fHop=%d\n', low,high, fHop);
           
%             dataTrain_f = eegButterFilter(dataTrain.x(u,:,:), low, high, order);
%             dataTest_f = eegButterFilter(dataTest.x(u,:,:), low, high, order);
%             dataValid_f = eegButterFilter(dataValid.x(u,:,:), low, high, order);
            
            dataTrain_f = eegButterFilter(dataTrain, low, high, order);
            dataTest_f = eegButterFilter(dataTest, low, high, order);
            dataValid_f = eegButterFilter(dataValid, low, high, order);


            [dataTrain_f.x, dataTest_f.x,dataValid_f.x] = MC_CSP_val(dataTrain_f,dataTest_f,dataValid_f,cspPair);
        u=length(chn); %finding the length of chn for using in chn sel loop
        %chn selection
        for k = 1:u-1

% dataTrainM = dataTrain.x(k,:,:)
fprintf('\n%d th iteration\n', k);
%end
            feat_bank(fb,fold,s).train_feat = extractFeature(dataTrain_f.x(k,:,:),featureN); 
            feat_bank(fb,fold,s).test_feat = extractFeature(dataTest_f.x(k,:,:),featureN);
            feat_bank(fb,fold,s).valid_feat = extractFeature(dataValid_f.x(k,:,:),featureN);
            
            feat_bank(fb,fold,s).lb_train = dataTrain.y;  
            feat_bank(fb,fold,s).lb_test = dataTest.y; 
            feat_bank(fb,fold,s).lb_valid = dataValid.y; 

         FeatS{fb}=num2str(chn(k));
         fb=fb+1;
%          end%frequency loop
         end %end of chn sel loop 
         fprintf('\n folding no: %d for subject: %d \n',fold ,s)
     end%fold loop end
     fprintf('\n done for subject: %d \n',s);
end%subject loop
disp('Done for all the subjects. Now saving!!')
save feat_fus_log_var_win_val feat_bank FeatS flow fhigh fHop fSpan winsize winhop featureN nfold cspPair%classifier   feat_fus_log_var, feat_fus_log_var_win
disp('saved')
%use the following line to directly use fusion. if particular fusion is needed  use "Cal_Fus_res_sub_specific_val_custom'

Cal_Fus_res_sub_specific_val 
%Cal_Fus_res_sub_specific_val_custom %for all bands no algorithm 

