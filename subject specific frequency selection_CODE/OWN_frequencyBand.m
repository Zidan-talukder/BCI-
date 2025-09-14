clear all; close all; clc;

startEpoch=0.5;
endEpoch=4.8;

order=4;%order of the butterworth filter
%frequency parameters
flow=8; fhigh=25;
fHop=4; 
fSpan=4;

clssifier = 'LDA';
featureN= 'log_Var';
%featureN= 'log_Var_Win';
nfold = 5;%folding size
resvf=[]; restf=[];resv=[]; rest=[]; Valid=[]; Test=[]; 
%parameters for time window selection.
%only selected on "log_Var_Win" and "katz_Win"
global winsize winhop; 
winsize=3.6;
winhop=0.2;

cspPair=3;
fb=1;

% fprintf('TLFE: SE=%1.1f, EE=%1.1f, Ch=%s, Ord=%d, L=%d, H=%d, feature=%s,  Classif=%s winsize=%1.1f winhop=%1.1f \n'...
% ,startEpoch,endEpoch, num2str(chn),order,flow,fhigh, featureN, clssifier, winsize, winhop);

for flow= flow:fHop:fhigh
    
    low=flow;
    high=low+fSpan;
    load BCI_C4D1.mat
    nbSubjects = length(raw_dataTrain);
    fprintf('\n\n         Frequency Band_%d: %d Hz to %d Hz\n\n',fb,low,high);
    for s=1:nbSubjects
        dataTrainS = raw_dataTrain{s};

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
             

            %----------Butterfilter-----------

            
                dataTrain_f = eegButterFilter(dataTrain, low, high, order);
                dataTest_f = eegButterFilter(dataTest, low, high, order);
                dataValid_f = eegButterFilter(dataValid, low, high, order);

                  %-----CSP----------
                [dataTrain_f.x, dataTest_f.x,dataValid_f.x] = MC_CSP_val(dataTrain_f,dataTest_f,dataValid_f,cspPair);
               
                %----feature extraction-------
                dataTrain_f.x = extractFeature(dataTrain_f.x,featureN); 
                dataTest_f.x = extractFeature(dataTest_f.x,featureN);
                dataValid_f.x = extractFeature(dataValid_f.x,featureN);
                
                  %----ML Model---------
               
                [resV resT] = my_LDA_val(dataTrain_f.x,dataTrain.y,...
                dataValid_f.x,dataValid.y,...
                dataTest_f.x ,dataTest.y);
            resvf(fold)=resV; restf(fold)=resT;

             
         end%fold 
         resv(s) = mean(resvf); 
         rest(s) = mean(restf);
         
         
         
%   fprintf('\n For subject: %d \n',s);
%          fprintf('Test result:');disp(resv(s))
%          fprintf('validation result:');disp(rest(s))
    end%subject 
    
%     Valid(fb)= mean(resv);
%     Test(fb)= mean(rest);
    Valid= mean(resv);
    Test= mean(rest);
    fprintf('Test result:');disp(resv)
    fprintf('validation result:');disp(rest)
    fprintf('All subject per frequecny band Avarage Test result:'); disp(Test)
    fprintf('All subject per frequency band Avarage Validation result:'); disp(Valid)
    fb=fb+1;
end %frequency 
% fprintf('\nOver all Test result: %2.2f \n', mean(Valid)); 
% fprintf('Over all Validation result: %2.2f', mean(Test));