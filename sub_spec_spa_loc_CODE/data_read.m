 function [raw_dataTrain ] = data_read(startEpoch,endEpoch)


addpath ('J:\Lectures\BCI\EEG_Data_BCI_comp\BCI_IV_DS_1') %E:\_Research_EEG\_data\BCI_IV_DS_1

filenames1 = ['BCICIV_Calib_ds1a.mat'; % 100hz
              'BCICIV_Calib_ds1b.mat';
              'BCICIV_Calib_ds1c.mat';
              'BCICIV_Calib_ds1d.mat';
              'BCICIV_Calib_ds1e.mat';
              'BCICIV_Calib_ds1f.mat';
              'BCICIV_Calib_ds1g.mat'];         
         
%  filenames2= ['E\BCICIV_eval_ds1a.mat'; % 100hz
%               'E\BCICIV_eval_ds1g.mat'];  
%          
% trueLabelsFiles =['true_labels\BCICIV_eval_ds1a_1000Hz_true_y.mat'; %1000hz
%                   'true_labels\BCICIV_eval_ds1g_1000Hz_true_y.mat'];

nbSubjects = size(filenames1,1); raw_dataTrain = cell(nbSubjects,1); 

%startEpoch=0.5; endEpoch=4.5;  % !!! assuming real cue is in mrk.pos, if it is fixation cross then replace .5 > 2.5 and 2.5 >4.5
                          
              
for s=1:nbSubjects
    %load
    load(filenames1(s,:));     cnt= 0.1*double(cnt); y= mrk.y;  fs=nfo.fs;   cues = mrk.pos;
    
   % max(max(cnt))
   % min(min(cnt))
    %Assign
    raw_dataTrain{s}.sf = fs;  
    raw_dataTrain{s}.c = nfo.clab;    
    raw_dataTrain{s}.x_val = nfo.xpos;    
    raw_dataTrain{s}.y_val = nfo.ypos;
    
    %     % >>>> Artifact removing 
    %     cnt = remove_Artf2(cnt,fs); 
    
    %Data trials for two major classes  1, -1               
    for trial=1:size(y,2)
        i1= (cues(trial) + round(startEpoch*fs)); i2=(cues(trial) + round(endEpoch*fs))-1;   epoch = cnt(i1:i2,:);   %size(epoch)
        raw_dataTrain{s}.x(:,:,trial) = epoch;          
    end

    % Rearranging dimensions: channel, Samples, Trials
    raw_dataTrain{s}.x = permute(raw_dataTrain{s}.x,[2,1,3]);
    
    %Labels
    i1=find(y==-1);  i2=find(y==1);     y(i1)=1;y(i2)=2;    raw_dataTrain{s}.y= y;   
end %subject


rmpath ('J:\Lectures\BCI\EEG_Data_BCI_comp\BCI_IV_DS_1') %E:\_Research_EEG\_data\BCI_IV_DS_1

save BCI_C4D1.mat raw_dataTrain