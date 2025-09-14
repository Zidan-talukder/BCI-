function [Train_Mat,Test_Mat] = MC_CSP(train_data,test_data,nbFilterPairs)

train_data.x = permute(train_data.x,[2,1,3]);
test_data.x = permute(test_data.x,[2,1,3]);

    nbChannels = size(train_data.x,2);
    nbTrials = size(train_data.x,3);
    classLabels = unique(train_data.y);
    nbClasses = length(classLabels);
    trialCov = zeros(nbChannels,nbChannels,nbTrials);
    for a=1:nbTrials
        E = train_data.x(:,:,a)';
        EE = E * E';
        trialCov(:,:,a) = EE ./ trace(EE);
    end
    clear E;
    clear EE;

    %computing the covariance matrix for each class
    for c=1:nbClasses      
        covMatrices = mean(trialCov(:,:,train_data.y == classLabels(c)),3); 
        covMatrices = covMatrices ./ sum(train_data.y == classLabels(c));
        covMatrices1(c,:,:) = covMatrices;
    end

    % Add ffdiag to path
%     path(path,'ffdiag_pack');

    Pc = ones(1,nbClasses)./nbClasses; % uniform prior over classes

    % Jointly diagonalize covariance matrices
%     disp('Jointly diagonalizing covariance matrices...');
    [V,CD,stat] = ffdiag(shiftdim(covMatrices1,1),eye(nbChannels));
    V = V';

    % Compute mutual information provided by each filter (approximation)
%     disp('Selecting spatial filters with maximum mutual information...');
    for n1 = 1:1:nbChannels,
        w = V(:,n1);
        I(n1) = J_ApproxMI(w,covMatrices1,Pc);
    end
    [dummy(n1,:), iMI] = sort(I,'descend');
%     CSPMatrix = V(:,iMI)';
    Filter = V(:,iMI(1:nbFilterPairs*2))';
    
    
%     Filter = CSPMatrix([1:nbFilterPairs (end-nbFilterPairs+1):end],:);
    
    Train_trials = size(train_data.x,3);
    for t=1:Train_trials      
        Train_Mat(:,:,t) = Filter * train_data.x(:,:,t)';
    end
    

    Test_trials = size(test_data.x,3);    
    for b=1:Test_trials      
        Test_Mat(:,:,b) = Filter * test_data.x(:,:,b)';
    end





