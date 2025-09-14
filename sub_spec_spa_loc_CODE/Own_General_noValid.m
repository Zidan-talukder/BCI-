clear all; close all; clc;
%chn = {[]};
%type 19 + all chn
% chn = {[];[17:24];[25:33];[34:41];[1:16 18:23 28:30];[36:39 42:47 49:59];[10 11 17:19 26 27];[11 12 18:20 27 28 26]};
%type 19
%  chn = {[17:24];[25:33];[34:41];[1:16 18:23 28:30];[36:39 42:47 49:59];[10 11 17:19 26 27];[11 12 18:20 27 28 26]};
% type 25 +all
 chn = {[];[1:16 18:23 28:30];[36:39 42:59];[10:48]};
startEpoch=0.5;
endEpoch=4.8;

order=4;%order of the butterworth filter
%frequency parameters
flow=6; fhigh=16;

clssifier = 'LDA';
featureN= 'log_Var_Win';%log_Var, log_Var_Win, log_Var_Wavedec, katz, katz_Wavedec, higuchi, higuchi_Wavedec, MAV, RMS,  Eng, Ent, fft, katz_Win; ';%

nfold = 5;%if want to split data set in 50% train and test, set nfold=2 and place value 5 in the place of nfold for 5 fold validation.

%parameters for time window selection.
%only selected on "log_Var_Win" and "katz_Win"
global winsize winhop; 
winsize=3.6;
winhop=0.2;

cspPair=2;
restf=[];rest=[];Test=[];
% resvf=[]; resv=[];  Valid=[]; 

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
        
     %folding loop
     for fold = 1:nfold   %fold=1:5 
%         
         dataTrainf= dataTrainS;
         dataTestf.y = dataTrainf.y(fold:nfold:end);
         dataTestf.x = dataTrainf.x(:,:,fold:nfold:end);
         dataTestf.sf = dataTrainf.sf; 
         dataTrainf.y(fold:nfold:end)=[]; 
         dataTrainf.x(:,:,fold:nfold:end)=[];        
         %for validation set
         si=fold;
        if(fold==nfold) si=1; end
           %if(fold==5) si=1; end

         
%          dataValid.y = dataTrain.y(si:(nfold-1):end);
%          dataValid.x = dataTrain.x(:,:,si:(nfold-1):end);
%          dataValid.sf = dataTrain.sf; 
%          dataTrain.y(si:(nfold-1):end)=[]; 
%          dataTrain.x(:,:,si:(nfold-1):end)=[];         
%        % disp('Train Test Divided ...'); 



         
        %frequency selection
        low = flow; high=fhigh;
        dataTrain = eegButterFilter(dataTrainf, low, high, order);
        dataTest = eegButterFilter(dataTestf, low, high, order);
%         dataValid = eegButterFilter(dataValid, low, high, order);
                       
        %"cb" working as channel bank
        %LOOP for testing subject specific performance across multiple channel-Band selection      
        count = 1;
        for cb=1:size(chn,1)
             dataTrain_cb = dataTrain;
             dataTest_cb = dataTest; 
             %dataValid_cb = dataValid;
             chn1=chn{[cb]}; 
%              chn_temp=chn(cb,:);
             if (isempty(chn1))
               chn_temp = chn1 ;
               FeatS{count}='all channels';
               count=count+1; 
             else
                chn_temp=chn1; %%%%%%%(chn_nonZero,:)
                dataTrain_cb.x = dataTrain.x(chn_temp,:,:);
                dataTest_cb.x = dataTest.x(chn_temp,:,:);
%                 dataValid_cb.x = dataValid.x(chn_temp,:,:);
                %FeatS{count}=num2str(chn_temp)

                count=count+1; 
             end %channel check

             
            %fprintf('\n channel band %d= %s\n', cb,num2str(chn_temp));
            
                %%--------CSP--------------------%% 
%             [dataTrain_cb.x, dataTest_cb.x,dataValid_cb.x] = MC_CSP_val(dataTrain_cb,dataTest_cb,dataValid_cb,cspPair);
                [dataTrain_cb.x, dataTest_cb.x] = MC_CSP(dataTrain_cb,dataTest_cb,cspPair);

                              %----feature extraction-------
                dataTrain_cb.x = extractFeature(dataTrain_cb.x,featureN); 
                dataTest_cb.x = extractFeature(dataTest_cb.x,featureN);
%                 dataValid_cb.x = extractFeature(dataValid_cb.x,featureN);


                    %----ML Model---------
               
%           [resV resT] = my_LDA_val(dataTrain_cb.x,dataTrain_cb.y,...
%           dataValid_cb.x,dataValid_cb.y,...
%                 dataTest_cb.x ,dataTest_cb.y);

              [resT] = my_LDA(dataTrain_cb.x,dataTrain_cb.y,dataTest_cb.x ,dataTest_cb.y);
              restf(cb)=resT;
              %               resvf(cb)=resV ;  


%           FeatS{count}=num2str(chn_temp)
% %           pause
%           count=count+1; 
        end %channel bank loop
%           fprintf('\n folding no: %d for subject: %d \n',fold ,s)
%          resv(fold) = mean(resvf);
         rest(fold) = mean(restf);
     end  %fold loop end
     
     
%     Valid(s)= mean(resv);
    Test(s)= mean(rest);
     fprintf('\n Done for subject: %d \n',s);
     fprintf(' Test result:'); disp(mean(rest))
     %fprintf(' Validation result:'); disp(mean(restf))  
  
end%subject loop
fprintf('\n Test result for all subjects:'); disp(Test)
%fprintf('\n Validation result for all subjects:'); disp(Valid) 
fprintf('\n Over all Average Test result: %2.2f\n', mean(Test))
%fprintf('\n Over all Avarage Validation result: %2.2f\n', mean(Valid))