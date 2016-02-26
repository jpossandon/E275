% E275
% Basic TF analysis aligned to stimulus
% - Simple TF charts
% - Selection fo peak frequencies at theta, alpha and beta bands
% - GlM analysis per frequency

%%
% TFR
% sge               = str2num(getenv('SGE_TASK_ID'));

% Analysis parameters
p.times_tflock              = [1000 2500];
p.analysis_type             = {'ICAem'}; %'plain' / 'ICAe' / 'ICAm' / 'ICAem' 
p.bsl                       = [-.5 0]; 
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
p.cfgTFR.t_ftimwin          = .5*ones(1,length(p.cfgTFR.foi))
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
                                        'analysisname','stimlockTFR');       % single experiment/session parameters 
   
mkdir([cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/'])
load([cfg_eeg.eyeanalysisfolder cfg_eeg.filename 'eye.mat'])                         

[trls.trlLU,events]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==1'},p.times_tflock);            
[trls.trlRU,events]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==2'},p.times_tflock);            
[trls.trlLC,events]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==3'},p.times_tflock);            
[trls.trlRC,events]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==4'},p.times_tflock);            
[trls.image,events]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==96'},p.times_tflock);  
%%
% Locked to stimulus
% for at = 1:length(p.analysis_type)
at  = 1;
mkdir([cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/'])

[TFRallt_LU] = getTFRsfromtrl({cfg_eeg},{trls.trlLU},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
[TFRallt_RU] = getTFRsfromtrl({cfg_eeg},{trls.trlRU},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
[TFRallt_LC] = getTFRsfromtrl({cfg_eeg},{trls.trlLC},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
[TFRallt_RC] = getTFRsfromtrl({cfg_eeg},{trls.trlRC},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
[TFRallt_im] = getTFRsfromtrl({cfg_eeg},{trls.image},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid '_tfr_stim_' p.analysis_type{at}],'TFRallt_LU','TFRallt_LC','TFRallt_RU','TFRallt_RC','TFRallt_im','cfg_eeg','p')

%%
% Topoplots by frequency band

plot_times  = [-.6 2 .1];
band   = [15 20];
% load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid '_tfr_stim_' p.analysis_type{at}],'TFRallt_LU','TFRallt_LC','TFRallt_RU','TFRallt_RC','cfg_eeg','p')
fh = plot_topos_TFR(cfg_eeg,TFRallt_LU.(p.analysis_type{at}),plot_times,band,p.bsl,p.collim,['Stim LU ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimLU_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')
fh = plot_topos_TFR(cfg_eeg,TFRallt_LC.(p.analysis_type{at}),plot_times,band,p.bsl,p.collim,['Stim LC ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimLU_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')
fh = plot_topos_TFR(cfg_eeg,TFRallt_RU.(p.analysis_type{at}),plot_times,band,p.bsl,p.collim,['Stim RU ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimLU_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')
fh = plot_topos_TFR(cfg_eeg,TFRallt_RC.(p.analysis_type{at}),plot_times,band,p.bsl,p.collim,['Stim RC ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimLU_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')

%%
% and the diferrence
cfgr                = [];
cfgr.baseline       = [-.5 0];
cfgr.baselinetype   = 'relative';
collim              = [-.5 .5]
[freq1]             = ft_freqbaseline(cfgr, TFRallt_LU.(p.analysis_type{at}));
[freq2]             = ft_freqbaseline(cfgr, TFRallt_LC.(p.analysis_type{at}));
LUvsC               = freq1;
LUvsC.powspctrm     = freq1.powspctrm-freq2.powspctrm;
fh = plot_topos_TFR(cfg_eeg,LUvsC,plot_times,band,[],collim,['Stim L UvsC ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);

[freq1]             = ft_freqbaseline(cfgr, TFRallt_RU.(p.analysis_type{at}));
[freq2]             = ft_freqbaseline(cfgr, TFRallt_RC.(p.analysis_type{at}));
RUvsC               = freq1;
RUvsC.powspctrm     = freq1.powspctrm-freq2.powspctrm;
fh = plot_topos_TFR(cfg_eeg,RUvsC,plot_times,band,[],collim,['Stim R UvsC ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);


%%
% Locked to stimulus, mirrored channels
% for at = 1:length(p.analysis_type)
at  = 1;
p.cfgTFR.keeptrials = 'yes';
[TFRallt_LU] = getTFRsfromtrl({cfg_eeg},{trls.trlLU},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
[TFRallt_RU] = getTFRsfromtrl({cfg_eeg},{trls.trlRU},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
[TFRallt_LC] = getTFRsfromtrl({cfg_eeg},{trls.trlLC},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
[TFRallt_RC] = getTFRsfromtrl({cfg_eeg},{trls.trlRC},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);

mirindx         = mirrindex(TFRallt_LU.(p.analysis_type{1}).label,[cfg_eeg.expfolder '/channels/mirror_chans']); 
   
TFRallt_U    = TFRallt_RU;
TFRallt_U.(p.analysis_type{at}).powspctrm = cat(1,TFRallt_U.(p.analysis_type{at}).powspctrm,TFRallt_LU.(p.analysis_type{at}).powspctrm(:,mirindx,:,:));    
TFRallt_U.(p.analysis_type{at}).cumtapcnt = cat(1,TFRallt_U.(p.analysis_type{at}).cumtapcnt,TFRallt_LU.(p.analysis_type{at}).cumtapcnt);    

TFRallt_C    = TFRallt_RC;
TFRallt_C.(p.analysis_type{at}).powspctrm = cat(1,TFRallt_C.(p.analysis_type{at}).powspctrm,TFRallt_LC.(p.analysis_type{at}).powspctrm(:,mirindx,:,:));    
TFRallt_C.(p.analysis_type{at}).cumtapcnt = cat(1,TFRallt_C.(p.analysis_type{at}).cumtapcnt,TFRallt_LC.(p.analysis_type{at}).cumtapcnt);    

TFRallt_U.(p.analysis_type{at})   = ft_freqdescriptives([], TFRallt_U.(p.analysis_type{at}));
TFRallt_C.(p.analysis_type{at})   = ft_freqdescriptives([], TFRallt_C.(p.analysis_type{at}));

% save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid '_tfr_mirr_stim_' p.analysis_type{at}],'TFRallt_U','TFRallt_C','cfg_eeg','p')

%%
% Uncross minus cross (Right stimulation and Left mirrored) alpha
fh = plot_topos_TFR(cfg_eeg,TFRallt_U.(p.analysis_type{at}),plot_times,band,p.bsl,p.collim,['Stim U ' (p.analysis_type{at})  sprintf(' %d-%d Hz',band(1),band(2))]);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimU_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')
fh = plot_topos_TFR(cfg_eeg,TFRallt_C.(p.analysis_type{at}),plot_times,band,p.bsl,p.collim,['Stim C ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimC_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')

cfgr                = [];
cfgr.baseline       = [-.5 0];
cfgr.baselinetype   = 'relative';
collim              = [-.5 .5]
[freq1]             = ft_freqbaseline(cfgr, TFRallt_U.(p.analysis_type{at}));
[freq2]             = ft_freqbaseline(cfgr, TFRallt_C.(p.analysis_type{at}));
UvsC                = freq1;
UvsC.powspctrm      = freq1.powspctrm-freq2.powspctrm;
UvsC.cumtapcnt      = cat(1,TFRallt_U.(p.analysis_type{at}).cumtapcnt,TFRallt_C.(p.analysis_type{at}).cumtapcnt);
fh = plot_topos_TFR(cfg_eeg,UvsC,plot_times,band,[],collim,['Stim UvsC ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);

%%
% Uncross minus cross (Right stimulation and Left mirrored) beta
fh = plot_topos_TFR(cfg_eeg,TFRallt_U.(p.analysis_type{at}),plot_times,band,p.bsl,p.collim,['Stim U ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimU_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')
fh = plot_topos_TFR(cfg_eeg,TFRallt_C.(p.analysis_type{at}),plot_times,band,p.bsl,p.collim,['Stim C ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimU_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')

cfgr                = [];
cfgr.baseline       = [-1.5 0];
cfgr.baselinetype   = 'relative';
[freq1]             = ft_freqbaseline(cfgr, TFRallt_U.(p.analysis_type{at}));
[freq2]             = ft_freqbaseline(cfgr, TFRallt_C.(p.analysis_type{at}));
UvsC                = freq1;
UvsC.powspctrm      = freq1.powspctrm-freq2.powspctrm;
UvsC.cumtapcnt      = cat(1,TFRallt_U.(p.analysis_type{at}).cumtapcnt,TFRallt_C.(p.analysis_type{at}).cumtapcnt);
fh = plot_topos_TFR(cfg_eeg,UvsC,[-.1 .6 .02],[18 25],[],[-1 1],['Stim UvsC ' (p.analysis_type{at}) 'beta']);

%% 
load(cfg_eeg.chanfile)
cfgp            = [];
cfgp.showlabels = 'no'; 
cfgp.fontsize   = 12; 
cfgp.elec       = elec;
cfgp.interactive    = 'yes';

  cfgp.baseline       = [-.5 0];
  cfgp.baselinetype   = 'relative';
% cfgp.ylim           = [0 40];
% cfgp.xlim           = [-.5 0]
 cfgp.zlim           = [.5 1.5]
data =TFRallt_LU.ICAem;
% data.powspLFRallt_LU.ICAemUvsCa.powspctrm)

figure
ft_multiplotTFR(cfgp,data)