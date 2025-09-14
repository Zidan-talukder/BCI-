function features1 =feat_log_Var(Data)
 
nbTrials = size(Data,3);

%% Log-Variance
for t=1:nbTrials
   
    for i=1:size(Data,1) % channel
        %var(Data(i,:,t),0,1)
        
        features1(t,i) = log(var(Data(i,:,t)));
        
%         feat(i) = var(Data(i,:,t));   %variance   
    end
    
%     feat = feat/sum(feat); % normalization
%     features1(t,:) = log(feat); % log transform

end

%% Log-Variance Normalized
% for t=1:nbTrials
%    
%     for i=1:size(Data,1) % channel
%         %var(Data(i,:,t),0,1)
%         
% %         features1(t,i) = log(var(Data(i,:,t)));
%         
%         feat(i) = var(Data(i,:,t));   %variance   
%     end
%     
%     feat = feat/sum(feat); % normalization
%     features1(t,:) = log(feat); % log transform
% 
% end


% 
% function features1 = feat_log_Var_ref(Data)
%  
% nbTrials = size(Data,3);
% sf=100; i1=round(sf*0.3); i2=round(sf*0.5);
% for t=1:nbTrials
%    
%     for c=1:size(Data,1) % channel
%         %var(Data(i,:,t),0,1)
%         features1(t,c) = log(var(Data(c,i2:end,t)))-log(var(Data(c,1:i1,t)));
%       
%     end  
% 
% end