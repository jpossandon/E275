% E275
% Basic TF analysis aligned to stimulus
% - Simple TF charts
% - Selection fo peak frequencies at theta, alpha and beta bands
% - GlM analysis per frequency

%%
% TFR
% sge               = str2num(getenv('SGE_TASK_ID'));
clear
for tk = 5; % subject number

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
    p.cfgTFR.taper              = 'hanning';
    % p.cfgTFR.width              = 5; 
    p.cfgTFR.output             = 'pow';	
    % p.cfgTFR.foi                = 4:2:35;	
    % p.cfgTFR.t_ftimwin          = .512*ones(1,length(p.cfgTFR.foi));
    p.cfgTFR.toi                = (-p.times_tflock(1):20:p.times_tflock(2))/1000;	

    p.cfgTFR.foi               = 4:1:100;	

    p.cfgTFR.t_ftimwin          = 4./p.cfgTFR.foi;
    p.cfgTFR.tapsmofrq          = 0.5*p.cfgTFR.foi;
    plottp(p.cfgTFR)


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
    
    % Locked to stimulus
    at  = 1;
    mkdir([cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/'])

    [TFR_LU] = getTFRsfromtrl({cfg_eeg},{trls.trlLU},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
    [TFR_RU] = getTFRsfromtrl({cfg_eeg},{trls.trlRU},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);

    [TFR_LC] = getTFRsfromtrl({cfg_eeg},{trls.trlLC},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
    [TFR_RC] = getTFRsfromtrl({cfg_eeg},{trls.trlRC},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);

    [TFR_IM] = getTFRsfromtrl({cfg_eeg},{trls.image},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);

%      mirroring left stimulation data to make contra/ipsi plots
    mirindx         = mirrindex(TFR_LU.(p.analysis_type{1}).label,[cfg_eeg.expfolder '/channels/mirror_chans']); 
    TFR_LUmirr      = TFR_LU;
    TFR_LCmirr      = TFR_LC;
    TFR_LUmirr.(p.analysis_type{at}).powspctrm = TFR_LU.(p.analysis_type{at}).powspctrm(:,mirindx,:,:);
    TFR_LCmirr.(p.analysis_type{at}).powspctrm = TFR_LC.(p.analysis_type{at}).powspctrm(:,mirindx,:,:);

    cfgs            = [];
    cfgs.parameter  = 'powspctrm';
    TFR_U.(p.analysis_type{1})           = ft_appendfreq(cfgs, TFR_RU.(p.analysis_type{1}),TFR_LUmirr.(p.analysis_type{1})); % ERASEME: there was an error here apeenof TFR.RU with TFR.LU instead of TFR.LUmirr
    TFR_C.(p.analysis_type{1})           = ft_appendfreq(cfgs, TFR_RC.(p.analysis_type{1}),TFR_LCmirr.(p.analysis_type{1})); %SAME

    
    fieldstoav      = {'LU','RU','LC','RC','IM','U','C'};
    for f = 1:length(fieldstoav)
    TFRav.(fieldstoav{f}).(p.analysis_type{1}) = ft_freqdescriptives([], eval(['TFR_' fieldstoav{f} '.(p.analysis_type{1})']));
    end
    save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid '_tfr_stim_' p.analysis_type{at}],'TFRav','cfg_eeg','p')

%     cfg.output     = 'fourier';
%     [freq]          = ft_freqanalysis(cfg, data);
%             
%     cfgcoh              = [];
%     cfgcoh.method       = 'coh';
%     allcoh(subj,stim)   = ft_connectivityanalysis(cfgcoh,freq);
%             
%     cfgcoh              = [];
%     cfgcoh.method       = 'coh';
%     cfgcoh.complex      = 'imag';
%     allcohim(subj,stim) = ft_connectivityanalysis(cfgcoh,freq);
%             
%     cfgcoh              = [];
%     cfgcoh.method       = 'wpli_debiased';
%     cfgcoh.jackknife    = 'yes';
%     allwpli(subj,stim)  = ft_connectivityanalysis(cfgcoh,freq);
%             
end

%%
% grand averages
at                  = 1;
p.analysis_type     = {'ICAem'}; %'plain' / 'ICAe' / 'ICAm' / 'ICAem' 
cfgr                = [];
p.bsl               = [-.75 -.25]; 
cfgr.baseline       = p.bsl;
cfgr.baselinetype   = 'db';
for tk = 1:5; % subject number
    if ismac    
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),'analysisname','stimlockTFR','expfolder','/Users/jossando/trabajo/E275/'); % this is just to being able to do analysis at work and with my laptop
    else
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),'analysisname','stimlockTFR');
    end
    load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid '_tfr_stim_' p.analysis_type{at}],'TFRav','cfg_eeg','p')
    fTFR    = fields(TFRav);
    for ff=1:length(fTFR)
        faux(tk,ff) = ft_freqbaseline(cfgr,TFRav.(fTFR{ff}).(p.analysis_type{1}));
    end
end

for ff=1:length(fTFR)
    str_GA = 'GA.(fTFR{ff}) = ft_freqgrandaverage([]'
    for ss = 1:size(faux(:,ff),1)
        str_GA = [str_GA, ',faux(', num2str(ss), ',ff)'];
    end
    str_GA = [str_GA,');'];
    eval(str_GA)
end
%%
[freq1]             = ft_freqbaseline(cfgr,TFR_U.ICAem);
[freq2]             = ft_freqbaseline(cfgr, TFR_C.ICAem);

%%
load(cfg_eeg.chanfile)
statUC = freqpermBT(freq1,freq2,elec);
%%
freq1av   = ft_freqdescriptives([], freq1);
freq2av   = ft_freqdescriptives([], freq2);

cfgs            = [];
cfgs.parameter  = 'powspctrm';
cfgs.operation  = 'subtract';
difffreq       = ft_math(cfgs,GA.U,GA.C);
% difffreq.mask   = statUC.mask;
%%
load(cfg_eeg.chanfile)
cfgp            = [];
cfgp.showlabels = 'no'; 
cfgp.fontsize   = 12; 
cfgp.elec       = elec;
cfgp.interactive    = 'yes';
% cfgp.trials     =4
%         cfgp.baseline       = p.bsl;
%         cfgp.baselinetype   = 'db';
% cfgp.ylim           = [0 40];
 cfgp.xlim           = [-.75 1.25];
%       cfgp.zlim           = [-1 1];
%     cfgp.maskparameter = 'mask';
%       cfgp.maskalpha = .3
data = GA.IM;

figure,ft_multiplotTFR(cfgp,data)

%%
% Comparisons stat
cfgr                = [];
cfgr.baseline       = p.bsl;
cfgr.baselinetype   = 'db';
[freq1]             = ft_freqbaseline(cfgr, TFR.RU.(p.analysis_type{at}));
[freq2]             = ft_freqbaseline(cfgr, TFR.RC.(p.analysis_type{at}));
    
% load(cfg_eeg.chanfile)
% statLR = freqpermBT(freq1,freq2,elec)
