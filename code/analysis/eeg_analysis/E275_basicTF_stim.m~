% E275
% Basic TF analysis aligned to stimulus
% - Simple TF charts
% - Selection fo peak frequencies at theta, alpha and beta bands
% - GlM analysis per frequency

%%
% TFR
% sge               = str2num(getenv('SGE_TASK_ID'));

% Analysis parameters
p.times_tflock              = [1500 1500];
p.analysis_type             = {'ICAem'}; %'plain' / 'ICAe' / 'ICAm' / 'ICAem' 
p.bsl                       = [-1.5 0]; 
p.reref                     = 'yes';
p.keep                      = 'no';
p.collim                    = [0 2];
p.cfgTFR.channel            = 'all';	
p.cfgTFR.keeptrial          = 'no';	                
p.cfgTFR.method             = 'wavelet';                
p.cfgTFR.width              = 5; 
p.cfgTFR.output             = 'pow';	
p.cfgTFR.foi                = 1:1:40;	                
p.cfgTFR.toi                = (-p.times_tflock(1):20:p.times_tflock(2))/1000;	

tk                          = 1; % subject number

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

%%
% Locked to stimulus
% for at = 1:length(p.analysis_type)
at  = 1;
mkdir([cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/'])

[TFRallt_LU] = getTFRsfromtrl({cfg_eeg},{trls.trlLU},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
[TFRallt_RU] = getTFRsfromtrl({cfg_eeg},{trls.trlRU},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
[TFRallt_LC] = getTFRsfromtrl({cfg_eeg},{trls.trlLC},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
[TFRallt_RC] = getTFRsfromtrl({cfg_eeg},{trls.trlRC},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid '_tfr_stim_' p.analysis_type{at}],'TFRallt_LU','TFRallt_LC','TFRallt_RU','TFRallt_RC','cfg_eeg','p')

%%
% Topoplots by frequency band
% alfa
load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid '_tfr_stim_' p.analysis_type{at}],'TFRallt_LU','TFRallt_LC','TFRallt_RU','TFRallt_RC','cfg_eeg','p')
fh = plot_topos_TFR(cfg_eeg,TFRallt_LU.(p.analysis_type{at}),[-.1 .4 .02],[9 12],p.bsl,p.collim,['Stim LU ' (p.analysis_type{at}) ' alpha']);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid '_StimLU_alpha' p.analysis_type{at}],'fig')
fh = plot_topos_TFR(cfg_eeg,TFRallt_LC.(p.analysis_type{at}),[-.1 .4 .02],[9 12],p.bsl,p.collim,['Stim LC ' (p.analysis_type{at}) ' alpha']);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid '_StimLC_alpha' p.analysis_type{at}],'fig')
fh = plot_topos_TFR(cfg_eeg,TFRallt_RU.(p.analysis_type{at}),[-.1 .4 .02],[9 12],p.bsl,p.collim,['Stim RU ' (p.analysis_type{at}) ' alpha']);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid '_StimRU_alpha' p.analysis_type{at}],'fig')
fh = plot_topos_TFR(cfg_eeg,TFRallt_RC.(p.analysis_type{at}),[-.1 .4 .02],[9 12],p.bsl,p.collim,['Stim RC ' (p.analysis_type{at}) ' alpha']);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid '_StimRC_alpha' p.analysis_type{at}],'fig')

%%
% and the diferrence
cfgr                = [];
cfgr.baseline       = [-1.5 0];
cfgr.baselinetype   = 'relative';
[freq1]         = ft_freqbaseline(cfgr, TFRallt_LU.(p.analysis_type{at}));
[freq2]         = ft_freqbaseline(cfgr, TFRallt_LC.(p.analysis_type{at}));
LUvsC           = freq1;
LUvsC.powspctrm = freq1.powspctrm-freq2.powspctrm;
fh = plot_topos_TFR(cfg_eeg,LUvsC,[-.1 .4 .02],[9 12],[],[-1 1],['Stim L UvsC ' (p.analysis_type{at}) 'alpha']);

[freq1]         = ft_freqbaseline(cfgr, TFRallt_RU.(p.analysis_type{at}));
[freq2]         = ft_freqbaseline(cfgr, TFRallt_RC.(p.analysis_type{at}));
RUvsC           = freq1;
RUvsC.powspctrm = freq1.powspctrm-freq2.powspctrm;
fh = plot_topos_TFR(cfg_eeg,RUvsC,[-.1 .4 .02],[9 12],[],[-1 1],['Stim R UvsC ' (p.analysis_type{at}) 'alpha']);

%%
% Topoplots by frequency band
% beta
fh = plot_topos_TFR(cfg_eeg,TFRallt_LU.(p.analysis_type{at}),[-.1 .4 .02],[18 25],p.bsl,p.collim,['Stim LU ' (p.analysis_type{at}) ' beta']);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid '_StimLU_beta' p.analysis_type{at}],'fig')
fh = plot_topos_TFR(cfg_eeg,TFRallt_LC.(p.analysis_type{at}),[-.1 .4 .02],[18 25],p.bsl,p.collim,['Stim LC ' (p.analysis_type{at}) ' beta']);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid '_StimLC_beta' p.analysis_type{at}],'fig')
fh = plot_topos_TFR(cfg_eeg,TFRallt_RU.(p.analysis_type{at}),[-.1 .4 .02],[18 25],p.bsl,p.collim,['Stim RU ' (p.analysis_type{at}) ' beta']);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid '_StimRU_beta' p.analysis_type{at}],'fig')
fh = plot_topos_TFR(cfg_eeg,TFRallt_RC.(p.analysis_type{at}),[-.1 .4 .02],[18 25],p.bsl,p.collim,['Stim RC ' (p.analysis_type{at}) ' beta']);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid '_StimRC_beta' p.analysis_type{at}],'fig')

%%
% and the diferrence
fh = plot_topos_TFR(cfg_eeg,LUvsC,[-.1 .4 .02],[18 25],[],[-1 1],['Stim L UvsC ' (p.analysis_type{at}) 'beta']);
fh = plot_topos_TFR(cfg_eeg,RUvsC,[-.1 .4 .02],[18 25],[],[-1 1],['Stim R UvsC ' (p.analysis_type{at}) 'beta']);

%%
% Topoplots by frequency band
% theta
fh = plot_topos_TFR(cfg_eeg,TFRallt_LU.(p.analysis_type{at}),[-.1 .4 .02],[4 7],p.bsl,p.collim,['Stim LU ' (p.analysis_type{at}) ' theta']);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid '_StimLU_theta' p.analysis_type{at}],'fig')
fh = plot_topos_TFR(cfg_eeg,TFRallt_LC.(p.analysis_type{at}),[-.1 .4 .02],[4 7],p.bsl,p.collim,['Stim LC ' (p.analysis_type{at}) ' theta']);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid '_StimLC_theta' p.analysis_type{at}],'fig')
fh = plot_topos_TFR(cfg_eeg,TFRallt_RU.(p.analysis_type{at}),[-.1 .4 .02],[4 7],p.bsl,p.collim,['Stim RU ' (p.analysis_type{at}) ' theta']);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid '_StimRU_theta' p.analysis_type{at}],'fig')
fh = plot_topos_TFR(cfg_eeg,TFRallt_RC.(p.analysis_type{at}),[-.1 .4 .02],[4 7],p.bsl,p.collim,['Stim RC ' (p.analysis_type{at}) ' theta']);
saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid '_StimRC_theta' p.analysis_type{at}],'fig')

%% 
load(cfg_eeg.chanfile)
cfgp            = [];
cfgp.showlabels = 'no'; 
cfgp.fontsize   = 12; 
cfgp.elec       = elec;
% cfgp.elec.chanpos = elec.pnt;
% cfgp.rotate = 0;
cfgp.interactive    = 'yes';
cfgp.baseline       = [-1.5 0];
cfgp.baselinetype   = 'relative';
cfgp.ylim           = [0 40];
% cfgp.xlim           = [-.5 0]
% 
figure
  ft_multiplotTFR(cfgp,TFRallt_RU.(p.analysis_type{at}))