function feat = extractFeature(data,featureN)
switch featureN   % =  log_Var, log_Var_Wavedec, katz, katz_Wavedec, higuchi, higuchi_Wavedec, RMS, MAV, Eng, Ent, fft
    case 'log_Var';
        feat = feat_log_Var(data);
    case 'log_Var_Win';
        feat = feat_log_Var_Win(data);
    case 'log_Var_Wavedec'
        feat = feat_Log_Var_Wavedec(data);
    case 'katz'
        feat = feat_katz(data);
    case 'katz_Wavedec'
        feat = feat_Katz_Wavedec(data);
    case 'higuchi'
        feat = feat_higuchi(data);
    case 'higuchi_Wavedec'
        feat = feat_Higuchi_Wavedec(data);
    case 'RMS'
        feat = feat_RMS(data);
    case 'MAV'
        feat = feat_MAV(data);
    case 'Eng'
        feat = feat_Eng(data);
    case 'Ent'
        feat = feat_Ent(data);
    case 'fft'
        feat = feat_fft(data);    
end

