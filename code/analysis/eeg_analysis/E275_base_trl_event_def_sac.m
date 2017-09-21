clear trls sacpar
     
     cfgs = {cfg_eeg};
stimconds = {'LU','RU','LC','RC'};
for td=1:4
    if td<3 || tk<6
        tg = td;
    else
        tg = td+2;
    end

    [trlstim,events_stim]       = define_event(cfg_eeg,eyedata,'ETtrigger',{'value',sprintf('==%d',tg)},p.times);   
    trlsac      = [];   eyecent     = [];
    scrcent     = [];   latency     = [];
    for t = events_stim.time
        [trl,events]            = define_event(cfg_eeg,eyedata,2,{'&start',sprintf('>%d',t+100);...
                                    '&start',sprintf('<%d',t+1000)},p.times);
        if ~isempty(trl)
            trlsac              = [trlsac;trl];
            eyecent             = [eyecent,(events.posendx-events.posinix)/45];
            scrcent             = [scrcent,(events.posendx-960)/45];
            latency             = [latency,events.start-t];
        end
        clear trl
        
    end
    eval(['trls.' stimconds{td} '= trlsac;'])
    eval(['sac.eyecent_' stimconds{td} ' = eyecent;'])
    eval(['sac.scrcent_' stimconds{td} ' = scrcent;'])
    eval(['sac.latency_' stimconds{td} ' = latency;'])
end       
% p.trls_stim                        = {'L','R','LUsacL','LUsacR','RUsacL','RUsacR','LCsacL','LCsacR','RCsacL','RCsacR'};
trls.left                       = [trls.LU;trls.LC];
trls.right                      = [trls.RU;trls.RC];
p.trls_glm                      = '{trls.left;trls.right}';  

covs.covariate_eye           = {{[sac.eyecent_LU, sac.eyecent_LC]};...
                                    {[sac.eyecent_RU, sac.eyecent_RC]}};
covs.covariate_head           = {{[sac.scrcent_LU, sac.scrcent_LC]};...
                                    {[sac.scrcent_RU, sac.scrcent_RC]}};
covs.covariate_cross           = {{[-1*ones(1,size(trls.LU,1)),ones(1,size(trls.LC,1))]};...
                                     {[-1*ones(1,size(trls.RU,1)),ones(1,size(trls.RC,1))]}};
                                
p.covariates                   = eval(p.model_cov);
p.trls                         = eval(p.trls_glm);                                

% 
% 
% % [trls.L,events]            = define_event(cfg_eeg,eyedata,2,{'|angle','>135';'|angle','<-135';'&dur','>10';'dur','<100'},...
% %             p.times);
% % [trls.R,events]            = define_event(cfg_eeg,eyedata,2,{'&angle','>-45';'&angle','<45';'&dur','>10';'dur','<100'},...
% %             p.times);
% % [trls.L_nost,events]            = define_event(cfg_eeg,eyedata,2,{'|angle','>135';'|angle','<-135';'&dur','>10';'dur','<100';'latestim','==0'},...
% %             p.times);
% % [trls.R_nost,events]            = define_event(cfg_eeg,eyedata,2,{'&angle','>-45';'&angle','<45';'&dur','>10';'dur','<100';'latestim','==0'},...
% %             p.times);
% stimconds = {'LU','RU','LC','RC'};
% 
% for td=1:4
%     if td<3 || tk<6
%         tg = td;
%     else
%         tg = td+2;
%     end
% 
%     [trlstim,events_stim]       = define_event(cfg_eeg,eyedata,'ETtrigger',{'value',sprintf('==%d',tg)},p.times);   
%     trlsacL                     = [];   trlsacR                     = [];
%     trlsaclatL                  = [];   trlsaclatR                  = [];
%     trlanglesL                  = [];   trlanglesR                  = [];
%     for t = events_stim.time
%         [trl,events]            = define_event(cfg_eeg,eyedata,2,{'&start',sprintf('>%d',t+100);'&start',sprintf('<%d',t+700);'|angle','>135';'|angle','<-135';'&posinix','>560';'&posinix','<960'},...
%             p.times);
%         if ~isempty(trl)
%             trlsacL              = [trlsacL;trl];
%             trlanglesL           = [trlanglesL,events.angle(1:1:end)];
%             trlsaclatL           = [trlsaclatL,events.start(1:1:end)-t];
%         end
%         clear trl
%         [trl,events]            = define_event(cfg_eeg,eyedata,2,{'&start',sprintf('>%d',t+100);'&start',sprintf('<%d',t+700);'&angle','>-45';'&angle','<45';'&posinix','>560';'&posinix','<960'},...
%             p.times);
%         if ~isempty(trl)
%             trlsacR              = [trlsacR;trl];
%             trlanglesR           = [trlanglesR,events.angle(1:1:end)];
%             trlsaclatR           = [trlsaclatR,events.start(1:1:end)-t];
%         end
%         clear trl
%     end
%     for direc = {'L','R'}
%         eval(['trls.' stimconds{td} 'sac' direc{:} '= trlsac' direc{:} ';'])
%         eval(['sacpar.lat_' stimconds{td} 'sac' direc{:} ' = trlsaclat' direc{:} ';'])
%         eval(['sacpar.ang_' stimconds{td} 'sac' direc{:} ' = trlangles' direc{:} ';'])
%     end
% end       
% % p.trls_stim                        = {'L','R','LUsacL','LUsacR','RUsacL','RUsacR','LCsacL','LCsacR','RCsacL','RCsacR'};
% trls.left                       = [trls.LUsacL;trls.RUsacL;trls.LCsacL;trls.RCsacL];
% trls.right                      = [trls.LUsacR;trls.RUsacR;trls.LCsacR;trls.RCsacR];
% p.trls_glm                      = '{trls.left;trls.right}';  
% 
% covs.covariate_cross           = {{[-1*ones(1,size(trls.LUsacL,1)),-1*ones(1,size(trls.RUsacL,1)),ones(1,size(trls.LCsacL,1)),ones(1,size(trls.RCsacL,1))]};...
%                                     {[-1*ones(1,size(trls.LUsacR,1)),-1*ones(1,size(trls.RUsacR,1)),ones(1,size(trls.LCsacR,1)),ones(1,size(trls.RCsacR,1))]}};
% covs.covariate_stimLR         = {{[ones(1,size(trls.LUsacL,1)),-1*ones(1,size(trls.RUsacL,1)),ones(1,size(trls.LCsacL,1)),-1.*ones(1,size(trls.RCsacL,1))]};...
%                                     {[ones(1,size(trls.LUsacR,1)),-1*ones(1,size(trls.RUsacR,1)),ones(1,size(trls.LCsacR,1)),-1.*ones(1,size(trls.RCsacR,1))]}};
%      
% p.covariates                   = eval(p.model_cov);
% p.trls                         = eval(p.trls_glm);                                
% 
