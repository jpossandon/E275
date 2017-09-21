%clean_path
%sge               = str2num(getenv('SGE_TASK_ID'));
%%
clear
E275_params 
stimB = [];
% p.subj = p.subj(p.subj>2)
sge = 1;
for tk = p.subj
    if ismac    
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),...
            'expfolder','/Users/jossando/trabajo/E275/'); % this is just to being able to do analysis at work and with my laptop
    else
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk));
    end
    
    filename                = sprintf('s%02d',tk);
    cfg_eeg                 = eeg_etParams_E275(cfg_eeg,...
                                            'filename',filename,...
                                            'EDFname',filename,...
                                            'event',[filename '.vmrk'],...
                                            'clean_name','final',...
                                            'analysisname','saclock');    % single experiment/session parameters 
   
    load([cfg_eeg.eyeanalysisfolder cfg_eeg.filename 'eye.mat'])            % eyedata               
% load([cfg.analysisfolder cfg.analysisname '/' cfg.sujid '_comp_sel'],'ICA_match')

% ERP analysis interval locked to target appearance and saccade start

   [trl,events] = define_event(cfg_eeg,eyedata,2,{'&origstart','>0'},...
                [800 100],{1,1,'origstart','>0';-1,1,'origstart','>0';-1,1,'dur','>400'}); 
     
    saccade        = {trl};
    eyecent     = {(events.posendx(2:3:end)-events.posinix(2:3:end))/45};
    scrcent     = {(events.posendx(2:3:end)-960)/45};   
    eyecenty     = {(events.posendy(2:3:end)-events.posiniy(2:3:end))/45};
    scrcenty     = {(events.posendy(2:3:end)-540)/45}; 
    cfgs = {cfg_eeg};
        
    p.bsl           = [-.4 -.3];
    p.reref         = 'yes';
    p.analysis_typ  = 'ICAem';
    p.analysisname  = 'saccade_eyehead';
    p.interact      = [1 2];
    p.coeff         = {'const','eyex','headx','eyey','heady','eyex*headx','eyey*heady'};
    keep            = 'yes';
    [ERPall,toelim] = getERPsfromtrl(cfgs,saccade,p.bsl,p.reref,p.analysis_typ,keep);
    Y               = ERPall.(p.analysis_typ).trial;

    eyevalues = [];     scrvalues = [];
    eyevaluesy = [];     scrvaluesy = [];

    for ip = 1:size(saccade,2) % sessions
        eyevalues = [eyevalues;eyecent{ip}(setdiff(1:length(eyecent{ip}),toelim{ip}))'];
        scrvalues = [scrvalues;scrcent{ip}(setdiff(1:length(scrcent{ip}),toelim{ip}))'];
        eyevaluesy = [eyevaluesy;eyecenty{ip}(setdiff(1:length(eyecenty{ip}),toelim{ip}))'];
        scrvaluesy = [scrvaluesy;scrcenty{ip}(setdiff(1:length(scrcenty{ip}),toelim{ip}))'];
    end
   
    sacall(sge).eyex = eyevalues';
    sacall(sge).headx = scrvalues';
    sacall(sge).eyey = eyevaluesy';
    sacall(sge).heady = scrvaluesy';
%     sacall(sge).amp = ampvalues';
    XY = sign([eyevalues,scrvalues,eyevaluesy,scrvaluesy,eyevalues.*scrvalues,eyevaluesy.*scrvaluesy]);
    load(cfgs{1}.chanfile) 
    [B,Bt,STATS,T] = regntcfe(Y,XY,1,'effect',elec,0);
    modelos(sge).B            = B;
    modelos(sge).Bt           = Bt;
    modelos(sge).STATS        = STATS;
    modelos(sge).TCFE         = T;
    modelos(sge).n            = size(Y,1);
    modelos(sge).time         = ERPall.ICAem.time;

    stimB = cat(4,stimB,modelos(sge).B);
    sge = sge +1;
end
result = regmodel2ndstat(stimB,modelos(1).time,elec,2000,'signpermT','cluster');
save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/ERP/glm_' p.analysisname],'result','modelos')

%%
p.interval = [-.7 .02 .01];
E275_glm_stim_betaplots

%%
figure,
plot([sacall.head],[sacall.eye],'.')
xlabel('End point in head coordinates')
ylabel('End point in eye coordinates')
box off
hline(0)
vline(0)
axis([-30 30 -30 30])
% stat.time = result.clusters(1).time;
% r2.time  = result.clusters(1).time;
% stats = [modelos.STATS];
% r2.avg    = squeeze(mean(stats(:,1:7:end,:),2));
% r2.n      = 6;
% fh = plot_stat(cfg_eeg,stat,r2,[],p.interval,[0 3],.05,sprintf('r2'),1);
    
 