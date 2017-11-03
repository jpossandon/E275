[trls.LU,events.LU]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==1'},p.times);            
[trls.RU,events.RU]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==2'},p.times);
if tk<6
[trls.LC,events.LC]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==3'},p.times);            
[trls.RC,events.RC]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==4'},p.times);            
else
[trls.LC,events.LC]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==5'},p.times);            
[trls.RC,events.RC]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==6'},p.times);            
end    
[trls.events.image]             = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==96'},p.times);  
   
[trls.fix,events.fix] = define_event(cfg_eeg,eyedata,1,{'&origstart','>0';'&origstart','<8000'},...
                p.times,{-1,1,'origstart','>0';-1,1,'dur','>350'}); 
   
                                trls.left                      = [trls.LU;trls.LC];
trls.right                     = [trls.RU;trls.RC];
trls.all                       = [trls.left;trls.right];

p.trls_stim                    = {'LU','LC','RU','RC','image','left','right','all'};
p.trls_glm                     = '{trls.left;trls.right}';   

for ee = 1:4
    auxt            = events.(p.trls_stim{ee}).time;
    auxtrl          = events.(p.trls_stim{ee}).trial;
    poscovabs.(p.trls_stim{ee}) = [];
    for tt = 1:length(auxt)
        [~,evpre]     = define_event(cfg_eeg,eyedata,1,{'&start',sprintf('<%d',auxt(tt));...
            '&end',sprintf('>%d',auxt(tt));...
            '&trial',sprintf('==%d',auxtrl(tt))},p.times); % this is for
        
        if isempty(evpre) % in case event occurs during a saccade
             [~,evpre]     = define_event(cfg_eeg,eyedata,1,{'&start',sprintf('<%d',auxt(tt));...
             '&trial',sprintf('==%d',auxtrl(tt))},p.times,{+2,1,'start',sprintf('>%d',auxt(tt))}); % this is for
        end
            [~,evafter]     = define_event(cfg_eeg,eyedata,1,{'&start',sprintf('>%d',auxt(tt)+100);...
                '&start',sprintf('<%d',auxt(tt)+1100);...
                '&trial',sprintf('==%d',auxtrl(tt))},p.times);
           
        if ~isempty(evafter) && ~isempty(evpre)
            evafter.posx = evafter.posx-evpre.posx(1);    % so pos is in relationship to pre stimulation position
            poscovabs.(p.trls_stim{ee}) = [poscovabs.(p.trls_stim{ee}),(sum(evafter.posx<0)-sum(evafter.posx>0))/length(evafter.posx)];
        else
            poscovabs.(p.trls_stim{ee}) = [poscovabs.(p.trls_stim{ee}),NaN];%or NaN
        end
            %alternatively
%         poscovrel.(p.trls_stim{ee}) = (sum(evafter.pos<0)-sum(evafter.posx>p.siz(1)/2))/length(evafter.posx);
    end  
end
covs.covariate_cross           = {{[-1*ones(1,size(trls.LU,1)),ones(1,size(trls.LC,1))]};...
                                    {[-1*ones(1,size(trls.RU,1)),ones(1,size(trls.RC,1))]}};
covs.covariate_bias           = {{[poscovabs.LU,poscovabs.LC]};...
                                    {[poscovabs.RU,poscovabs.RC]}};

p.covariates                   = eval(p.model_cov);
p.trls                         = eval(p.trls_glm);
%     trls.trl_right                     = [trls.trl40;trls.trl50];
%     trls.trl_all                       = [trls.trl_left;trls.trl_right];
%     p.trls_im = {'trl10','trl20','trl30','trl40','trl50','trl_left','trl_right','trl_all'};
%   
% 
%     elimt = [];
%     for t = 1:length(events.trial)
%         [trl,eve]                 = define_event(cfg_eeg,eyedata,2,{'trial',['== ' num2str(events.trial(t))];'origstart','>-400';'origstart','<150'},...
%                                             [100 100]);
%         if ~isempty(trl)
%             elimt = [elimt;t];
%         end
%     end
%     trls.trl10(elimt,:) = [];
%     
%     [trls.trl20,events]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==20'},p.times_imlock);            
%     
%     elimt = [];
%     for t = 1:length(events.trial)
%         [trl,eve]                 = define_event(cfg_eeg,eyedata,2,{'trial',['== ' num2str(events.trial(t))];'origstart','>-400';'origstart','<150'},...
%                                             [100 100]);
%         if ~isempty(trl)
%             elimt = [elimt;t];
%         end
%     end
%     trls.trl20(elimt,:) = [];
%     
%     [trls.trl30,events]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==30'},p.times_imlock);            
%     
%      elimt = [];
%     for t = 1:length(events.trial)
%         [trl,eve]                 = define_event(cfg_eeg,eyedata,2,{'trial',['== ' num2str(events.trial(t))];'origstart','>-400';'origstart','<150'},...
%                                             [100 100]);
%         if ~isempty(trl)
%             elimt = [elimt;t];
%         end
%     end
%     trls.trl30(elimt,:) = [];
%     
%     [trls.trl40,events]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==40'},p.times_imlock);            
%     
%      elimt = [];
%     for t = 1:length(events.trial)
%         [trl,eve]                 = define_event(cfg_eeg,eyedata,2,{'trial',['== ' num2str(events.trial(t))];'origstart','>-400';'origstart','<150'},...
%                                             [100 100]);
%         if ~isempty(trl)
%             elimt = [elimt;t];
%         end
%     end
%     trls.trl40(elimt,:) = [];
%     
%     [trls.trl50,events]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==50'},p.times_imlock);            
%     
%      elimt = [];
%     for t = 1:length(events.trial)
%         [trl,eve]                 = define_event(cfg_eeg,eyedata,2,{'trial',['== ' num2str(events.trial(t))];'origstart','>-400';'origstart','<150'},...
%                                             [100 100]);
%         if ~isempty(trl)
%             elimt = [elimt;t];
%         end
%     end
%     trls.trl50(elimt,:) = [];
%     
%     trls.trl_left                      = [trls.trl20;trls.trl30];
%     trls.trl_right                     = [trls.trl40;trls.trl50];
%     trls.trl_all                       = [trls.trl_left;trls.trl_right];
%     p.trls_im = {'trl10','trl20','trl30','trl40','trl50','trl_left','trl_right','trl_all'};
%     % firs erp figures
