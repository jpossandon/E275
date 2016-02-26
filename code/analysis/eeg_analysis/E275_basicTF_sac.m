% E275
% Basic TF analysis aligned to saccade
% - Simple TF charts
% - Selection fo peak frequencies at theta, alpha and beta bands
% - GlM analysis per frequency

%%
% TFR
% sge               = str2num(getenv('SGE_TASK_ID'));

% Analysis parameters
p.times_tflock              = [1500 1000];
p.analysis_type             = {'ICAem'}; %'plain' / 'ICAe' / 'ICAm' / 'ICAem' 
p.bsl                       = [-1.5 -1]; 
p.reref                     = 'yes';
p.keep                      = 'no';
p.collim                    = [0 2];
p.cfgTFR.channel            = 'all';	
p.cfgTFR.keeptrials         = 'no';	                
p.cfgTFR.method             = 'mtmconvol';
p.cfgTFR.taper              = 'hanning'
% p.cfgTFR.width              = 5; 
p.cfgTFR.output             = 'pow';	
p.cfgTFR.foi                = 4:1:35;	
p.cfgTFR.t_ftimwin          = .5*ones(1,length(p.cfgTFR.foi));
p.cfgTFR.toi                = (-p.times_tflock(1):20:p.times_tflock(2))/1000;	

tk                          = 2; % subject number

if ismac    
    cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),'expfolder','/Users/jossando/trabajo/E275/'); % this is just to being able to do analysis at work and with my laptop
else
    cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk));
end
    
filename                = sprintf('s%02d',tk);
cfg_eeg                 = eeg_etParams_E275(cfg_eeg,...
                                        'filename',filename,...
                                        'EDFname',filename,...
                                        'event',[filename '.vmrk'],...
                                        'clean_name','final',...
                                        'analysisname','saclockTFR');       % single experiment/session parameters 
   
mkdir([cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/'])
load([cfg_eeg.eyeanalysisfolder cfg_eeg.filename 'eye.mat'])                         

%% 
% trial definitions
stimconds = {'LU','RU','LC','RC'};
for td = 1:4

    [trlstim,events_stim]       = define_event(cfg_eeg,eyedata,'ETtrigger',{'value',sprintf('==%d',td)},p.times_tflock);   
    trlsac                      = [];
    trlsaclat                   = [];
    trlangles                      = [];
    trlendxpos                  = [];
    for t = events_stim.time
        [trl,events]            = define_event(cfg_eeg,eyedata,2,{'&start',sprintf('>%d',t+100);'&start',sprintf('<%d',t+1500)},...
            p.times_tflock,{-2,2,'start',sprintf('<%d',t)});%{-2,2,'start',sprintf('<%d',t)}{-1,1,'dur','>100'}
        if ~isempty(trl)
            trlsac              = [trlsac;trl];
            trlangles           = [trlangles,events.angle(2:2:end)];
            trlsaclat           = [trlsaclat,events.start(2:2:end)-t];
            trlendxpos          = [trlendxpos,events.posendx(2:2:end)-events.posendx(1:2:end)];
        end
    end
    eval(['trls.trl_' stimconds{td} 'sac = trlsac;'])
    eval(['sacpar.lat_' stimconds{td} ' = trlsaclat;'])
    eval(['sacpar.ang_' stimconds{td} ' = trlangles;'])
    eval(['sacpar.endposx_' stimconds{td} ' = trlendxpos;'])
 end
%%

[TFRallt_LUsac] = getTFRsfromtrl({cfg_eeg},{trls.trl_LUsac},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
[TFRallt_LCsac] = getTFRsfromtrl({cfg_eeg},{trls.trl_LCsac},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
[TFRallt_RUsac] = getTFRsfromtrl({cfg_eeg},{trls.trl_RUsac},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
[TFRallt_RCsac] = getTFRsfromtrl({cfg_eeg},{trls.trl_RCsac},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
%%
% Fieldtrip fast plotting
%% 
load(cfg_eeg.chanfile)
cfgp            = [];
cfgp.showlabels = 'no'; 
cfgp.fontsize   = 12; 
cfgp.elec       = elec;
cfgp.interactive    = 'yes';
cfgp.baseline       = p.bsl ;
cfgp.baselinetype   = 'relative';
% cfgp.ylim           = [0 40];
% cfgp.xlim           = [-.5 0]
cfgp.zlim           = [.5 1.5]
data =TFRallt_LCsac.(p.analysis_type{at});
% data.powspLFRallt_LU.ICAemUvsCa.powspctrm)

figure
ft_multiplotTFR(cfgp,data)