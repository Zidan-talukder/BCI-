%this is the code for specific frequency selection experiment. here
%we are trying to observe the performance of each frequency band and how it
%affects the overall accuracy of the model

%this portion of the code is used to record every frequency band
%information and afterwards with the help of "Cal_Fus_res_val.m" 
%frequency band which provides additive performance is found

clear all; close all; clc;
chn= [1 2 56 57 58 59];
% chn=[15:23;25:33;35:43];%[15:23;25:33];%for all channel use "[]" %for all channel use "[]" % [ 25:33 ]; % chn=[ 25 27 29 31 33  ]; %   chn=[ 27 29 31 ]; %  chn=[8 25 27 29 31 33 44 ];%
%type 1
%chn=[18:20 26:28 35:37 ; 20:22 28:30 37:39 ; 22:24 30:32 39:41];
%type 2
%chn = [12:14 20:22 28:30; 27:29 36:38 43:45; 29:31 38:40 45:47];
%type 3
%chn=[18:20 26:28 35:37 ; 20:22 28:30 37:39 ; 22:24 30:32 39:41; 5:7 12:14 20:22; 37:39 44:46 51:53];
%type 4
%chn=[19:21 27:29 36:38 ; 20:22 28:30 37:39 ; 21:23 29:31 38:40; 5:7 12:14 20:22; 37:39 44:46 51:53];
%type 5
%chn=[19:21 27:29 36:38 ; 20:22 28:30 37:39 ;  5:7 12:14 20:22; 37:39 44:46 51:53];
%type 6
%chn=[10:12 18:20 26:28; 5:7 12:14 20:22; 14:16 22:24 30:32; 20:22 28:30 37:39; 30:32 39:41 46:48; 37:39 44:46 51:53; 26:28 35:37 42:44];
%type 7
%chn=[3:5 10:12 18:20 ; 5:7 12:14 20:22 ; 7:9 22:24 30:32 ; 20:22 28:30 37:39 ; 39:41 46:48 53:55 ; 37:39 44:46 51:53 ; 35:37 42:44 49:51];
%type 8
%chn=[3:5 10:12 18:20 ; 5:7 12:14 20:22 ; 7:9 22:24 30:32 ; 20:22 28:30 37:39 ; 39:41 46:48 53:55 ; 37:39 44:46 51:53 ; 35:37 42:44 49:51; 18:20 26:28 35:37; 22:24 30:32 39:41 ];
%type 9
chn = [ 3 4 10 11 18 19; 5 6 12 13 20 21; 7 8 14 15 22 23; 18 19 26 27 35 36; 20 21 28 29 37 38; 22 23 30 31 39 40; 35 36 42 43 49 50; 37 38 44 45 51 52; 39 40 46 47 53 54];
startEpoch=0.5;
endEpoch=4.8;

order=4;%order of the butterworth filter
%frequency parameters
flow=6; fhigh=16;
fHop=2; fSpan=8;

clssifier = 'LDA';
featureN= 'log_Var_Win';%log_Var, log_Var_Win, log_Var_Wavedec, katz, katz_Wavedec, higuchi, higuchi_Wavedec, MAV, RMS,  Eng, Ent, fft, katz_Win; ';%
nfold = 5;%folding size

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
    cb=1;% cb working as channel bank
  
    %channel selection
    u=size(chn,1);
    for k=1:u
        fprintf('iteration %d',k);
        dataTrainS = raw_dataTrain{s};
        chn_temp=chn(k,:);
        if (~isempty(chn_temp)) 
            dataTrainS.x = dataTrainS.x(chn_temp,:,:);
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



%          fb=1;%fb= frequency band,
 
        %frequency selection
         %for
            low = flow;% this freq loop for testing subject specific performance across multiple frequency band 
            high=fhigh;
           
            fprintf('\nlowfreq=%d highfreq= %d, fHop=%d\n', low,high, fHop);
            
            dataTrain_f = eegButterFilter(dataTrain, low, high, order);
            dataTest_f = eegButterFilter(dataTest, low, high, order);
            dataValid_f = eegButterFilter(dataValid, low, high, order);


            [dataTrain_f.x, dataTest_f.x,dataValid_f.x] = MC_CSP_val(dataTrain_f,dataTest_f,dataValid_f,cspPair);
% fprintf('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAiteration %d            A',k);
            feat_bank(cb,fold,s).train_feat = extractFeature(dataTrain_f.x,featureN); 
            feat_bank(cb,fold,s).test_feat = extractFeature(dataTest_f.x,featureN);
            feat_bank(cb,fold,s).valid_feat = extractFeature(dataValid_f.x,featureN);
            
            feat_bank(cb,fold,s).lb_train = dataTrain.y;  
            feat_bank(cb,fold,s).lb_test = dataTest.y; 
            feat_bank(cb,fold,s).lb_valid = dataValid.y; 

         FeatS{cb}=num2str(chn_temp);
        % fb=fb+1;
         %end%frequency loop
         fprintf('\n folding no: %d for subject: %d \n',fold ,s)
     end%fold loop end
      cb=cb+1;
    end%chn loop
     fprintf('\n done for subject: %d \n',s);
end%subject loop
disp('Done for all the subjects. Now saving!!')
save feat_fus_log_var_win_val_chn feat_bank FeatS flow fhigh fSpan chn winsize winhop featureN nfold cspPair%classifier   feat_fus_log_var, feat_fus_log_var_win
disp('saved')
%use the following line to directly use fusion. if particular fusion is needed  use "Cal_Fus_res_sub_specific_val_custom'

 Cal_Fus_res_sub_specific_val_chn
%Cal_Fus_res_sub_specific_val_custom %for all bands no algorithm 