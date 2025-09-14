 function index = index_funct(flow,number)
%index for storing frequency band wise data 
%   Detailed explanation goes here
% low=4; number=4;
% for flow=low:2:10
%     fhigh=flow+6;
    if(flow==number)
        index=flow-3;
    elseif(flow==(number+2))
        index=flow-4;
    elseif(flow==(number+4))
        index=flow-5;        
    elseif(flow==(number+6))
        index=flow-6;     
    elseif(flow==(number+8))
        index=flow-7;
    elseif(flow==(number+10))
        index=flow-8;
    elseif(flow==(number+12))
        index=flow-9;
    end
%     disp(index)
% end

