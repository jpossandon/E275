% E275
% Basic TF analysis aligned to stimulus
% - Simple TF charts
% - Selection fo peak frequencies at theta, alpha and beta bands
% - GlM analysis per frequency

%%
% TFR
% sge               = str2num(getenv('SGE_TASK_ID'));
clear
% Analysis parameters
p.times_tflock              = [1000 1500];
p.analysis_type             = {'ICAem'}; %'plain' / 'ICAe' / 'ICAm' / 'ICAem' 
p.bsl                       = [-.75 -.25]; 
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
p.cfgTFR.toi                = (-p.times_tflock(1):50:p.times_tflock(2))/1000;	

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

[trls.trlLU,eventstrlLU]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==1'},p.times_tflock);            
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
bands = [10 15;16 21;22 27];
plot_times  = [-.5 1.2 .1];
for b = 1:size(bands,1)
 
    band   = bands(b,:);
    % load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid '_tfr_stim_' p.analysis_type{at}],'TFRallt_LU','TFRallt_LC','TFRallt_RU','TFRallt_RC','cfg_eeg','p')
    fh = plot_topos_TFR(cfg_eeg,TFRallt_LU.(p.analysis_type{at}),plot_times,band,p.bsl,p.collim,['Stim LU ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimLU_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')
    fh = plot_topos_TFR(cfg_eeg,TFRallt_LC.(p.analysis_type{at}),plot_times,band,p.bsl,p.collim,['Stim LC ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimLC_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')
    fh = plot_topos_TFR(cfg_eeg,TFRallt_RU.(p.analysis_type{at}),plot_times,band,p.bsl,p.collim,['Stim RU ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimRU_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')
    fh = plot_topos_TFR(cfg_eeg,TFRallt_RC.(p.analysis_type{at}),plot_times,band,p.bsl,p.collim,['Stim RC ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimRC_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')


% and the diferrence
    cfgr                = [];
    cfgr.baseline       = p.bsl;
    cfgr.baselinetype   = 'relative';
    collim              = [-.5 .5]
    [freq1]             = ft_freqbaseline(cfgr, TFRallt_LU.(p.analysis_type{at}));
    [freq2]             = ft_freqbaseline(cfgr, TFRallt_LC.(p.analysis_type{at}));
    LUvsC               = freq1;
    LUvsC.powspctrm     = freq1.powspctrm-freq2.powspctrm;
    fh = plot_topos_TFR(cfg_eeg,LUvsC,plot_times,band,[],collim,['Stim L UvsC ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimLUvsC_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')

    [freq1]             = ft_freqbaseline(cfgr, TFRallt_RU.(p.analysis_type{at}));
    [freq2]             = ft_freqbaseline(cfgr, TFRallt_RC.(p.analysis_type{at}));
    RUvsC               = freq1;
    RUvsC.powspctrm     = freq1.powspctrm-freq2.powspctrm;
    fh = plot_topos_TFR(cfg_eeg,RUvsC,plot_times,band,[],collim,['Stim R UvsC ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimRUvsC_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')

end
%%
% Locked to stimulus, mirrored channels
% for at = 1:length(p.analysis_type)
at                  = 1;
p.cfgTFR.keeptrials = 'yes';
mirindx             = mirrindex(TFRallt_LU.(p.analysis_type{1}).label,[cfg_eeg.expfolder '/channels/mirror_chans']); 

[TFRallt_LU] = getTFRsfromtrl({cfg_eeg},{trls.trlLU},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
TFRallt_LU.(p.analysis_type{at}) = TFRallt_LU.(p.analysis_type{at}).powspctrm(:,mirindx,:,:);
[TFRallt_RU] = getTFRsfromtrl({cfg_eeg},{trls.trlRU},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
[TFRallt_LC] = getTFRsfromtrl({cfg_eeg},{trls.trlLC},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
TFRallt_LC.(p.analysis_type{at}) = TFRallt_LC.(p.analysis_type{at}).powspctrm(:,mirindx,:,:);
[TFRallt_RC] = getTFRsfromtrl({cfg_eeg},{trls.trlRC},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);

cfgs = [];
cfgs.parameter = 'powspctrm';
TFRallt_U    = ft_appendfreq(cfgs, TFRallt_RU.(p.analysis_type{1}),TFRallt_LU.(p.analysis_type{1}));
TFRallt_C    = ft_appendfreq(cfgs, TFRallt_RC.(p.analysis_type{1}),TFRallt_LC.(p.analysis_type{1}));

TFRallt_U.(p.analysis_type{at})   = ft_freqdescriptives([], TFRallt_U.(p.analysis_type{at}));
TFRallt_C.(p.analysis_type{at})   = ft_freqdescriptives([], TFRallt_C.(p.analysis_type{at}));


% save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid '_tfr_mirr_stim_' p.analysis_type{at}],'TFRallt_U','TFRallt_C','cfg_eeg','p')

%%
for b = 1:size(bands,1)
 
    band   = bands(b,:);
    % Uncross and cross (Right stimulation and Left mirrored) alpha
    fh = plot_topos_TFR(cfg_eeg,TFRallt_U.(p.analysis_type{at}),plot_times,band,p.bsl,p.collim,['Stim U ' (p.analysis_type{at})  sprintf(' %d-%d Hz',band(1),band(2))]);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimU_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')
    fh = plot_topos_TFR(cfg_eeg,TFRallt_C.(p.analysis_type{at}),plot_times,band,p.bsl,p.collim,['Stim C ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimC_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')

    cfgr                = [];
    cfgr.baseline       = p.bsl;
    cfgr.baselinetype   = 'relative';
    collim              = [-.5 .5]
    [freq1]             = ft_freqbaseline(cfgr, TFRallt_U.(p.analysis_type{at}));
    [freq2]             = ft_freqbaseline(cfgr, TFRallt_C.(p.analysis_type{at}));
    UvsC                = freq1;
    UvsC.powspctrm      = freq1.powspctrm-freq2.powspctrm;
    UvsC.cumtapcnt      = cat(1,TFRallt_U.(p.analysis_type{at}).cumtapcnt,TFRallt_C.(p.analysis_type{at}).cumtapcnt);
    fh = plot_topos_TFR(cfg_eeg,UvsC,plot_times,band,[],collim,['Stim UvsC ' (p.analysis_type{at}) sprintf(' %d-%d Hz',band(1),band(2))]);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/' cfg_eeg.sujid sprintf('_StimUvsC_%dto%dHz_',band(1),band(2)) p.analysis_type{at}],'fig')
end


%% 
load(cfg_eeg.chanfile)
cfgp            = [];
cfgp.showlabels = 'no'; 
cfgp.fontsize   = 12; 
cfgp.elec       = elec;
cfgp.interactive    = 'yes';
% cfgp.trials     =4
  cfgp.baseline       = p.bsl;
  cfgp.baselinetype   = 'relative';
% cfgp.ylim           = [0 40];
% cfgp.xlim           = [-.5 0]
%  cfgp.zlim           = [.5 1.5]
data =UvsC);
% data.powspLFRallt_LU.ICAemUvsCa.powspctrm)

figure
ft_multiplotTFR(cfgp,data)
% 
% 
 %%
% % plotting of single trials
% at  = 1;
% p.cfgTFR.keeptrials = 'yes';
% [TFRallt_LU,toelim] = getTFRsfromtrl({cfg_eeg},{trls.trlLU},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
% 
% goodtrl = trls.trlLU(setdiff(1:size(trls.trlLU,1),toelim{1}),:);
% %%
% cfgs = [];
% cfgs.elec = elec;
% cfgs.channel = {'FC4','C4','CP4','FC6','C6','CP6'};
% % cfgs.channel = {'Fp2'};
%  cfgs.baseline       = p.bsl;
%   cfgs.baselinetype   = 'relative';
% %    cfgs.zlim           = [.5 1.5]
% %  cfgs.trials     = 4
% data =TFRallt_LU.ICAem;
% % data.powspLFRallt_LU.ICAemUvsCa.powspctrm)
% 
% figure
% ft_singleplotTFR(cfgs,data),hold on
% for t = 1:size(goodtrl,1)
%     tstim = goodtrl(t,1)-goodtrl(t,3);
%  [trl,events]            = define_event(cfg_eeg,eyedata,2,{'&start',sprintf('>%d',tstim);...
%      '&start',sprintf('<%d',tstim+2000)},p.times_tflock);%{-2,2,'start',sprintf('<%d',t)}{-1,1,'dur','>100'}
%  if ~isempty(events)
%     vline([events.start-tstim]/1000)   
%  end
% end
% % vline([events.start-tstim]/1000)   
% % vline([events.end-tstim]/1000) 
