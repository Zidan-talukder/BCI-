function features =feat_log_Var_Win(Data) % Data= Channel x sample x trial
global winsize winhop;
%% THis is a Time Window based LV feature: there are multiple representations

sf= 100; % sampling freq 100hz
% Window size , silde 
cN=size(Data,1); sN=size(Data,2); tN = size(Data,3); % Trial    
wsize=round(winsize*sf); whop=round(winhop*sf); stop=sN-wsize+1;


% for sN=400:10:500
%     wsize=3*100; whop=.3*100; stop=sN-wsize+1;
%     startindx=1:whop:stop; disp(startindx)
%     endindx=startindx+wsize-1;disp(endindx)
% end

features=[];

%% Normal (Catenation) Variances of different windows
% for t=1:tN
%     n=0; feat=[];
%     for c=1:cN %channel
%         for startindx=1:whop:stop  %loop for window            
%             n=n+1;               
%             endindx=startindx+wsize-1;
%             feat(n)=log(var(Data(c,startindx:endindx,t)));
%         end        
%     end  
%     features(t,:)=feat; %size(feat)
% end

%% Mean Max Min of variances across windows%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for t=1:tN 
    n=0; feat=[];
    for c=1:cN % channel
        tf=[]; n=n+1;               
        for startindx=1:whop:stop  %loop for window            
            
            endindx=startindx+wsize-1;
            tf = [tf log(var(Data(c,startindx:endindx,t)))];
            
        end       
        feat = [feat min(tf) ]; % mean(tf)  max(tf) min(tf) std(tf)
    end  
    features(t,:)=feat;
end


%% mix of time& freq variance log(var(fft)) and min of LV
% for t=1:tN
%     n=0; Ffeat=[];Tfeat = [];
%     for c=1:cN %channel
%         tf=[]; 
%         for startindx=1:whop:stop  %loop for window                                      
%             endindx=startindx+wsize-1;
%             
%             Fc = abs(fft(Data(c,startindx:endindx,t))); mi= round((length(Fc)+1)/2);   Fc = Fc(2:mi); 
%             CompFFT= [(Fc(1:10:end)+Fc(2:10:end)+Fc(3:10:end)+Fc(4:10:end)+Fc(5:10:end)+Fc(6:10:end)+Fc(7:10:end)+Fc(8:10:end)+Fc(9:10:end)+Fc(10:10:end))];
%             Ffeat=[Ffeat log(var(CompFFT))];  %  log(var(CompFFT))   CompFFT    CompFFT(2:6)      
%             
%             tf = [tf log(var(Data(c,startindx:endindx,t)))];
%         end                
%         Tfeat = [Tfeat  min(tf) mean(tf)  max(tf) ];
%     end  
%     features(t,:)= [Tfeat Ffeat];
% end


% %%  FFT feat of different windows
% for t=1:tN
%     n=0; feat=[];
%     for c=1:cN %channel
%         for startindx=1:whop:stop  %loop for window            
%                           
%             endindx=startindx+wsize-1;
%             Fc = abs(fft(Data(c,startindx:endindx,t))); mi= round((length(Fc)+1)/2);   Fc = Fc(2:mi); 
%             CompFFT= [(Fc(1:10:end)+Fc(2:10:end)+Fc(3:10:end)+Fc(4:10:end)+Fc(5:10:end)+Fc(6:10:end)+Fc(7:10:end)+Fc(8:10:end)+Fc(9:10:end)+Fc(10:10:end))];
%             %CompFFT = [ CompFFT(1:3:end)+CompFFT(2:3:end)+CompFFT(3:3:end)]; % 3x
%             
%             %plot(CompFFT); title(sprintf('startindx = %d' ,startindx) );   pause            
%             feat=[feat log(var(CompFFT))];  %  log(var(CompFFT))   CompFFT    CompFFT(2:6)      
%             
%         end                
%     end  
%     features(t,:)=feat;
% end

% another version but not so good
% for t=1:tN
%     n=0; feat=[];
%     for c=1:cN %channel
%         Fw = [];
%         for startindx=1:whop:stop  %loop for window            
%                           
%             endindx=startindx+wsize-1;
%             Fc = abs(fft(Data(c,startindx:endindx,t))); mi= round((length(Fc)+1)/2);   Fc = Fc(2:mi); 
%             CompFFT= [(Fc(1:10:end)+Fc(2:10:end)+Fc(3:10:end)+Fc(4:10:end)+Fc(5:10:end)+Fc(6:10:end)+Fc(7:10:end)+Fc(8:10:end)+Fc(9:10:end)+Fc(10:10:end))];
%             %CompFFT = [ CompFFT(1:3:end)+CompFFT(2:3:end)+CompFFT(3:3:end)]; % 3x
%             
%             %plot(CompFFT); title(sprintf('startindx = %d' ,startindx) );   pause            
%             % feat=[feat log(var(CompFFT))];  %  log(var(CompFFT))   CompFFT    CompFFT(2:6)      
%             
%             CompFFT = [ Fc(1:2:end)+Fc(2:2:end)]; % 2x               plot(CompFFT); title(sprintf('startindx = %d' ,startindx) ); size(CompFFT)
%             
%             Fw = [Fw; CompFFT(3:10) ];
%               %Fw = [Fw; log(var(CompFFT)) ];
%         end        
%         feat = [feat  log(var(Fw))]; %  mean(Fw) min(Fw) max(Fw) log(var(Fw))
%     end  
%     features(t,:)=feat;
% end


%% ---------normalized with ref
% os=round(0.5*100)+1; osr=round(0.3*100); % assuming time start from 0 sec of cue
% 
% for t=1:tN
%     n=0; feat=[];
%     for c=1:cN %channel
%         for startindx = os:whop:stop  %loop for window            
%             n=n+1;               
%             endindx=startindx+wsize-1;
%             ref= (var(Data(c,1:osr,t)));
%             feat(n)=(var(Data(i,startindx:endindx,t)))-ref; % - is better than /
%         end        
%     end  
%     features(t,:)=feat;
% end



%% winsize=1; winhop=0.3;  feat = [feat log(var(Fw))  
% SE=0.5, EE=4.5, Ch=, Ord=6, L=9, H=15, Fold=3 CSPpair=4, feat=log_Var_Win, FS:(, 50, 0, LDA, 25) Classif=LDA 
% CSPpairs=1.00 *Avg: (77.42),  Subjects: 78.0 68.5 71.0 79.5 93.5 74.5 77.0   Time: 19.3756
% CSPpairs=3.00 *Avg: (75.92),  Subjects: 74.5 70.0 67.0 79.5 90.5 71.0 79.0   Time: 23.8693

%  Fw = [Fw; log(var(CompFFT)) ]; feat = [feat mean(Fw) min(Fw) max(Fw)  ];
% SE=0.5, EE=4.5, Ch=, Ord=6, L=9, H=15, Fold=3 CSPpair=4, feat=log_Var_Win, FS:(, 50, 0, LDA, 25) Classif=LDA winsize=1.0 winhop=0.3 
% CSPpairs=1.00 *Avg: (83.56),  Subjects: 75.5 78.0 72.5 94.0 97.0 82.0 86.0   Time: 25.6577
% CSPpairs=3.00 *Avg: (84.64),  Subjects: 77.0 75.5 77.0 94.0 97.5 81.0 90.5   Time: 42.4187
% CSPpairs=5.00 *Avg: (84.64),  Subjects: 84.5 76.0 72.0 91.0 96.5 83.5 89.0   Time: 62.8463