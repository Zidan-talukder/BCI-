function [Train_Mat, Test_Mat] = W_saved(train_data,test_data,W) % eegdata: sample x channel x trial


ntrain_data = permute(train_data.x, [2 1 3]);
nbTrials = size(ntrain_data,3);
for t=1:nbTrials
    Train_Mat(:,:,t) = W * ntrain_data(:,:,t);
end
ntest_data = permute(test_data.x, [2 1 3]);
nbTrials1 = size(ntest_data,3);
for a = 1: nbTrials1
    Test_Mat(:,:,a) = W * ntest_data(:,:,a);
end
