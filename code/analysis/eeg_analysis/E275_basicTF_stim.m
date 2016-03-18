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
p.keep                      = 'yes';
p.collim                    = [0 2];
p.cfgTFR.channel            = 'all';	
p.cfgTFR.keeptrials         = 'yes';	                
p.cfgTFR.method             = 'mtmconvol';
p.cfgTFR.taper              = 'hanning'
% p.cfgTFR.width              = 5; 
p.cfgTFR.output             = 'pow';	
p.cfgTFR.foi                = 4:2:35;	
p.cfgTFR.t_ftimwin          = .512*ones(1,length(p.cfgTFR.foi))
p.cfgTFR.toi                = (-p.times_tflock(1):50:p.times_tflock(2))/1000;	

tk                          = 4; % subject number

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

[TFRallt_L] = getTFRsfromtrl({cfg_eeg},{[trls.trlLU;trls.trlLC]},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
[TFRallt_R] = getTFRsfromtrl({cfg_eeg},{[trls.trlRU;trls.trlRC]},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);


% [TFRallt_im] = getTFRsfromtrl({cfg_eeg},{trls.image},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
% save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid '_tfr_stim_' p.analysis_type{at}],'TFRallt_LU','TFRallt_LC','TFRallt_RU','TFRallt_RC','TFRallt_im','cfg_eeg','p')

%%
% Comparisons stat
cfgr                = [];
cfgr.baseline       = p.bsl;
cfgr.baselinetype   = 'db';
[freq1]             = ft_freqbaseline(cfgr, TFRallt_L.(p.analysis_type{at}));
[freq2]             = ft_freqbaseline(cfgr, TFRallt_R.(p.analysis_type{at}));
    
load(cfg_eeg.chanfile)
statLR = freqpermBT(freq1,freq2,elec)

%%
mirindx             = mirrindex(TFRallt_LU.(p.analysis_type{1}).label,[cfg_eeg.expfolder '/channels/mirror_chans']); 
TFRallt_LUmirr.(p.analysis_type{at}) = TFRallt_LU.(p.analysis_type{at}).powspctrm(:,mirindx,:,:);
TFRallt_LCmirr.(p.analysis_type{at}) = TFRallt_LC.(p.analysis_type{at}).powspctrm(:,mirindx,:,:);

cfgs = [];
cfgs.parameter = 'powspctrm';
TFRallt_U    = ft_appendfreq(cfgs, TFRallt_RU.(p.analysis_type{1}),TFRallt_LUmirr.(p.analysis_type{1})); % ERASEME: there was an error here apeenof TFRallt_RU with TFRallt_LU instead of TFRallt_LUmirr
TFRallt_C    = ft_appendfreq(cfgs, TFRallt_RC.(p.analysis_type{1}),TFRallt_LCmirr.(p.analysis_type{1})); %SAME

[freq1]             = ft_freqbaseline(cfgr,TFRallt_U);
[freq2]             = ft_freqbaseline(cfgr, TFRallt_C);

load(cfg_eeg.chanfile)
statUC = freqpermBT(freq1,freq2,elec)
%%
freq1av   = ft_freqdescriptives([], freq1);
freq2av   = ft_freqdescriptives([], freq2);

cfgs            = [];
cfgs.parameter  = 'powspctrm';
cfgs.operation  = 'subtract';
difffreq       = ft_math(cfgs,freq1av,freq2av);
difffreq.mask   = statUC.mask;
%%
load(cfg_eeg.chanfile)
cfgp            = [];
cfgp.showlabels = 'no'; 
cfgp.fontsize   = 12; 
cfgp.elec       = elec;
cfgp.interactive    = 'yes';
% cfgp.trials     =4
%   cfgp.baseline       = p.bsl;
%   cfgp.baselinetype   = 'relative';
% cfgp.ylim           = [0 40];
% cfgp.xlim           = [-.5 0]
%   cfgp.zlim           = [-4 4]
    cfgp.maskparameter = 'mask';
      cfgp.maskalpha = .3
data = difffreq;

figure
ft_multiplotTFR(cfgp,data)
