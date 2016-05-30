% E275
% Basic TF analysis aligned to saccade
% - Simple TF charts
% - Selection fo peak frequencies at theta, alpha and beta bands
% - GlM analysis per frequency

%%
% TFR
% sge               = str2num(getenv('SGE_TASK_ID'));
clear
% Analysis parameters
p.times_tflock              = [1000 1000];
p.analysis_type             = {'ICAem'}; %'plain' / 'ICAe' / 'ICAm' / 'ICAem' 
p.bsl                       = [-1 -.5]; 
p.reref                     = 'yes';
p.keep                      = 'no';
p.collim                    = [0 2];
p.cfgTFR.channel            = 'all';	
p.cfgTFR.keeptrials         = 'no';	                
p.cfgTFR.method             = 'mtmconvol';
% p.cfgTFR.taper              = 'hanning'
% p.cfgTFR.width              = 5; 
p.cfgTFR.pad                = 3;
p.cfgTFR.output             = 'pow';	
p.cfgTFR.foi                = 4:2:110;	

p.cfgTFR.t_ftimwin          = 3./p.cfgTFR.foi;
p.cfgTFR.tapsmofrq          = 0.5*p.cfgTFR.foi;
plottp(p.cfgTFR)

% p.cfgTFR.t_ftimwin          = .5*ones(1,length(p.cfgTFR.foi));
p.cfgTFR.toi                = (-p.times_tflock(1):20:p.times_tflock(2))/1000;	
%%
for tk = 1:6; % subject number

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


    % trial definitions
    stimconds = {'LU','RU','LC','RC'};
    for td = 1:4
        if td>2 && tk>5
            tdd = td+2;
        else
            tdd = td;
        end
        [trlstim,events_stim]       = define_event(cfg_eeg,eyedata,'ETtrigger',{'value',sprintf('==%d',tdd)},p.times_tflock);   
        trlsac                      = [];
        trlsaclat                   = [];
        trlangles                      = [];
        trlendxpos                  = [];
        for t = events_stim.time
            [trl,events]            = define_event(cfg_eeg,eyedata,2,{'&start',sprintf('>%d',t+100);'&start',sprintf('<%d',t+500)},...
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
     [trls.trl_sacR,events]            = define_event(cfg_eeg,eyedata,2,{'&angle','<45';'&angle','>-45';'dur','>15';'amp','>1'},p.times_tflock)
     [trls.trl_sacL,events]            = define_event(cfg_eeg,eyedata,2,{'|angle','>45';'|angle','<-45';'dur','>15';'amp','>1'},p.times_tflock)

    at=1
    [TFR_LUsac] = getTFRsfromtrl({cfg_eeg},{trls.trl_LUsac},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
    [TFR_LCsac] = getTFRsfromtrl({cfg_eeg},{trls.trl_LCsac},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
    [TFR_RUsac] = getTFRsfromtrl({cfg_eeg},{trls.trl_RUsac},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
    [TFR_RCsac] = getTFRsfromtrl({cfg_eeg},{trls.trl_RCsac},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
     [TFR_Lsac] = getTFRsfromtrl({cfg_eeg},{trls.trl_sacL},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
     [TFR_Rsac] = getTFRsfromtrl({cfg_eeg},{trls.trl_sacR},p.bsl,p.reref,p.analysis_type{at},p.keep,p.cfgTFR);
    fieldstoav      = {'LU','RU','LC','RC','L','R'};
    for f = 1:4%length(fieldstoav)
        TFRav.(fieldstoav{f}).(p.analysis_type{1}) = ft_freqdescriptives([], eval(['TFR_' fieldstoav{f} 'sac.(p.analysis_type{1})']));
    end
    save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid '_tfr_sac_' p.analysis_type{at}],'TFRav','cfg_eeg','p')
end

%%
% grand averages
at                  = 1;
p.analysis_type     = {'ICAem'}; %'plain' / 'ICAe' / 'ICAm' / 'ICAem' 
cfgr                = [];
p.bsl               = [-1 -.5]; 
cfgr.baseline       = p.bsl;
cfgr.baselinetype   = 'db';
for tk = 1:5; % subject number
    if ismac    
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),'analysisname','saclockTFR','expfolder','/Users/jossando/trabajo/E275/'); % this is just to being able to do analysis at work and with my laptop
    else
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),'analysisname','saclockTFR');
    end
    load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid '_tfr_sac_' p.analysis_type{at}],'TFRav','cfg_eeg','p')
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
cfgr                = [];
cfgr.baseline       = p.bsl;
cfgr.baselinetype   = 'db';
[freq1]             = ft_freqbaseline(cfgr, TFRallt_Lsac.(p.analysis_type{at}));
[freq2]             = ft_freqbaseline(cfgr, TFRallt_Rsac.(p.analysis_type{at}));

%%
freq1           = GA.RU;
freq2          = GA.RC;
cfgs            = [];
cfgs.parameter  = 'powspctrm';
cfgs.operation  = 'subtract';
difffreq        = ft_math(cfgs,freq1,freq2);


%%
% Fieldtrip fast plotting
 
load(cfg_eeg.chanfile)
cfgp            = [];
cfgp.showlabels = 'no'; 
cfgp.fontsize   = 12; 
cfgp.elec       = elec;
cfgp.interactive    = 'yes';
%   cfgp.baseline       = p.bsl ;
%   cfgp.baselinetype   = 'db';
% cfgp.trials     = 51:70
       cfgp.ylim           = [10 18];
       cfgp.xlim           = [.2 .4];
% cfgp.zlim           = [.7 1.2]
    cfgp.zlim           = [-2 2];
%   data =TFRallt_RCsac.(p.analysis_type{at});
  data = GA.LU;
% data.powspLFRallt_LU.ICAemUvsCa.powspctrm)

%      figure
%      ft_multiplotTFR(cfgp,data)
 cfgp.comment = 'no'
     figure,ft_topoplotTFR(cfgp,data)