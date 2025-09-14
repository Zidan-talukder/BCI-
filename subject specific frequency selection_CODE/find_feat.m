function feat_train = find_feat(input,train_data)
if isequal(input,'MAV')
    feat_train = feat_MAV(train_data);
elseif  isequal(input,'LV')
    feat_train = feat_log_Var(train_data);
elseif isequal(input,'Katz')
    feat_train = feat_katz(train_data);
elseif isequal(input,'Eng')
    feat_train = feat_Eng(train_data);
elseif isequal(input,'Ent')
    feat_train = feat_Ent(train_data);
elseif isequal(input,'RMS')
    feat_train = feat_RMS(train_data);
elseif isequal(input,'Higuchi')
    feat_train = feat_higuchi(train_data);
end