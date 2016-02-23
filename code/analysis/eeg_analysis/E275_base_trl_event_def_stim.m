[trls.trlLU,events]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==1'},p.times_imlock);            
[trls.trlRU,events]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==2'},p.times_imlock);            
[trls.trlLC,events]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==3'},p.times_imlock);            
[trls.trlRC,events]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==4'},p.times_imlock);            

trls.trl_left                      = [trls.trlLU;trls.trlLC];
trls.trl_right                     = [trls.trlRU;trls.trlRC];
trls.trl_all                       = [trls.trl_left;trls.trl_right];
p.trls_stim                        = {'trlLU','trlLC','trlRU','trlRC','trl_left','trl_right','trl_all'};

covs.covariate_cross                = {{[-1*ones(1,size(trls.trlLU,1)),ones(1,size(trls.trlLC,1))]};{[-1*ones(1,size(trls.trlRU,1)),ones(1,size(trls.trlRC,1))]}};
   
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
