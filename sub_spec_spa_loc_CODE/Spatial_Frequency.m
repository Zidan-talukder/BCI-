clear all; close all; clc;
%type 28
chn = {[3:5 10:12 17:20 25:28 34:37 42:44 49:51];[8 9 14:16 21:24 30:33 38:41 46:48 53:55];[1 2 4:8 11:15 19:22 27:31 36:39 43:47 50:54 56:59]};
%frequency parameters
flow=4; fhigh=16;
fHop=2; fSpan=6;

startEpoch=0.5;
endEpoch=4.8;

order=4; %order of the butterworth filter

clssifier = 'LDA';
featureN= 'log_Var_Win';
nfold = 5;%folding size

%parameters for time window selection.
%only selected on "log_Var_Win" and "katz_Win"
global winsize winhop; 
winsize=3.6;
winhop=0.2;

cspPair=2;


fprintf('fbcsp: SE=%1.1f, EE=%1.1f, Ord=%d, L=%d, H=%d, feature=%s,  Classif=%s winsize=%1.1f winhop=%1.1f \n'...
    ,startEpoch,endEpoch, order,flow,fhigh, featureN, clssifier, winsize, winhop);

load BCI_C4D1.mat %BCI_C4D1; %BCI_C4D1_allsub_4s; %BCI_C4D1;%   BCI_C4D1_sub1267_4s; %select the saved version created on data read. 
nbSubjects = length(raw_dataTrain);

for s=1:nbSubjects
    dataTrainS = raw_dataTrain{s};


    %sorting data classwise
     Lb = dataTrainS.y; ind_c1 = find(Lb==1); ind_c2 = find(Lb==2);
     dataTrainS.x =dataTrainS.x(:,:,[ind_c1 ind_c2]);   
     dataTrainS.y =dataTrainS.y([ind_c1 ind_c2]);
     count = 1;
     
     %channel Bank Loop
  for cb=1:size(chn,1)
             dataTrain_CB= dataTrainS;

             chn1=chn{[cb]}; 
%              chn_temp=chn(cb,:);
             if (isempty(chn1))
               chn_temp = chn1
               
               FeatS{count}='all channels'
               count=count+1; 
             else
                chn_temp=chn1; %%%%%%%(chn_nonZero,:)
                dataTrain_CB.x = dataTrainS.x(chn_temp,:,:);

                count=count+1; 
             end %channel check
      
     %folding loop
     for fold = 1:nfold
         dataTrain = dataTrain_CB;
         dataTest.y = dataTrain.y(fold:nfold:end);
         dataTest.x = dataTrain.x(:,:,fold:nfold:end);
         dataTest.sf = dataTrain.sf; 
         dataTrain.y(fold:nfold:end)=[]; 
         dataTrain.x(:,:,fold:nfold:end)=[];        
         %for validation set
         si=fold;
         if(fold==nfold) si=1; end
         
         dataValid.y = dataTrain.y(si:(nfold-1):end);
         dataValid.x = dataTrain.x(:,:,si:(nfold-1):end);
         dataValid.sf = dataTrain.sf; 
         dataTrain.y(si:(nfold-1):end)=[]; 
         dataTrain.x(:,:,si:(nfold-1):end)=[];         
        % disp('Train Test Divided ...'); 

       %frequency loop
            fb=1; %fb= frequency band
       for  low = flow:fHop:fhigh   % this freq loop for testing subject specific performance across multiple frequency band 
            high=low+fSpan;
         
        
        
            dataTrain = eegButterFilter(dataTrain, low, high, order);
            dataTest = eegButterFilter(dataTest, low, high, order);
            dataValid = eegButterFilter(dataValid, low, high, order);
                       

            
            %%--------CSP--------------------%% 
            [dataTrain_cb.x, dataTest_cb.x,dataValid_cb.x] = MC_CSP_val(dataTrain,dataTest,dataValid,cspPair);
              
            %----feature extraction-------
           
            feat_bank(cb,fold,fb,s).train_feat = extractFeature(dataTrain_cb.x,featureN); 
            feat_bank(cb,fold,fb,s).test_feat = extractFeature(dataTest_cb.x,featureN);
            feat_bank(cb,fold,fb,s).valid_feat = extractFeature(dataValid_cb.x,featureN);
            
            feat_bank(cb,fold,fb,s).lb_train = dataTrain.y;  
            feat_bank(cb,fold,fb,s).lb_test = dataTest.y; 
            feat_bank(cb,fold,fb,s).lb_valid = dataValid.y;
          
             Feat_fb{fb}=num2str(low);
%             fb=fb+1;
        end   %frequency loop
        
            fprintf('\n folding no: %d for subject: %d \n',fold ,s)
      end %fold loop 
        
           fprintf('\n Channel Bank no: %d for subject: %d \n',cb ,s)
         
            Feat_cb{count}=num2str(chn_temp);        
%            count=count+1; 
   end %channel bank loop
     
           fprintf('\n done for subject: %d \n',s);  
  
end %subject loop
disp('Done for all the subjects. Now saving!!')
save feat_spatial_frequency feat_bank Feat_fb Feat_cb flow fhigh fSpan chn winsize winhop featureN nfold cspPair%classifier   feat_fus_log_var, feat_fus_log_var_win
disp('saved')