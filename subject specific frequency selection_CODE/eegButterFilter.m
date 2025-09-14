function EEGData = eegButterFilter(EEGData, low, high, order)

% nbSamples = size(EEGData.x,2);
nbChannels = size(EEGData.x,1);
nbTrials = size(EEGData.x,3);


%designing the butterworth band-pass filter 
lowFreq = low * (2/EEGData.sf);
highFreq = high * (2/EEGData.sf);
[B A] = butter(order, [lowFreq highFreq]);

%filtering all channels in this frequency band, for the training data
for i=1:nbTrials %all trials
    for j=1:nbChannels %all channels
        EEGData.x(j,:,i) = filter(B,A,EEGData.x(j,:,i));
    end
    
end














   