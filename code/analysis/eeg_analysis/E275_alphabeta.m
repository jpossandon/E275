%%
% (1) TF locked to image appearance, stats agains baseline
% (2) TF locked to saccade end (after all and quantiles previous fixation
% duration), stats agains baseline
% (3)TF locked to tactile, stats against baseline
% Absolute and relative (within and to pre image appearance)

% (4) visual alpha/beta ROI identified from (1) statistics
% (5) tactile alpha/beta ROI identified from (3) statistics
% trimmed mean + bootstrap CI for 1-3 at 4-5 ROIS

clear
E275_params                                 % basic experimental parameters               % 
fmodel                      = 12;            % wich glm model
E275_models 
%%
% TFR


for tk = p.subj; % subject number
tic
     
    cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),'expfolder','/Users/jossando/trabajo/E275/'); % this is just to being able to do analysis at work and with my laptop
   

    filename                = sprintf('s%02d',tk);
    cfg_eeg                 = eeg_etParams_E275(cfg_eeg,...
                                            'filename',filename,...
                                            'EDFname',filename,...
                                            'event',[filename '.vmrk'],...
                                            'clean_name','final',...
                                            'analysisname','comparisonTFR');       % single experiment/session parameters 

    mkdir([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr'])
    load([cfg_eeg.eyeanalysisfolder cfg_eeg.filename 'eye.mat'])                         

    E275_base_trl_event_def_comparison                                       % trial configuration  
 
    % Locked to stimulus
    at  = 1;
    mkdir([cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/'])

    for e = 1:length(p.trls_stim)
         [aux,toelim]= getTFRsfromtrl({cfg_eeg},{trls.(p.trls_stim{e})},p.bsl,p.rref,p.analysis_type{at},p.keep,p.cfgTFR);
%         aux.ICAem.toelim = toelim;
%          eval(['TFR_' p.trls_stim{e} '=aux;'])
         TFR.(p.trls_stim{e}).(p.analysis_type{at}) = ft_freqdescriptives([],aux.ICAem);
         TFR.(p.trls_stim{e}).(p.analysis_type{at}).powspctrm = squeeze(trimmean(aux.ICAem.powspctrm,20));
         TFR.(p.trls_stim{e}).(p.analysis_type{at}).N = size(aux.ICAem.powspctrm,1);
         TFR.(p.trls_stim{e}).(p.analysis_type{at}).origN = size(trls.(p.trls_stim{e}),1);
         TFRind.(p.trls_stim{e}).(p.analysis_type{at}) = TFR.(p.trls_stim{e}).(p.analysis_type{at});
         TFRind.(p.trls_stim{e}).(p.analysis_type{at}).powspctrm = ...
             squeeze(trimmean((sqrt(aux.ICAem.powspctrm)-repmat(mean(sqrt(aux.ICAem.powspctrm)),[size(aux.ICAem.powspctrm,1),1,1,1])).^2,20));
         clear aux
    end,toc
    save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid p.analysisname],'TFR','TFRind','cfg_eeg','p')            
end

%%
%%
% grand averages
at                  = 1;
p.analysis_type     = {'ICAem'}; %'plain' / 'ICAe' / 'ICAm' / 'ICAem' 
cfgr                = [];
p.bsl               = [-.6 -.3]; 
cfgr.baseline       = p.bsl;
cfgr.baselinetype   = 'relative';
subj=1;
for tk = p.subj
    cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),'analysisname','comparisonTFR','expfolder','/Users/jossando/trabajo/E275/'); % this is just to being able to do analysis at work and with my laptop
    load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/'  cfg_eeg.sujid p.analysisname],'TFR','TFRind')
    fTFR    = fields(TFR);
     for ff=1:length(fTFR)
%         faux(subj,ff) = ft_freqbaseline(cfgr,TFR.(fTFR{ff}).(p.analysis_type{1}));
        faux(subj,ff) = TFR.(fTFR{ff}).(p.analysis_type{1});
        fauxInd(subj,ff) = TFRind.(fTFR{ff}).(p.analysis_type{1});
     end
    subj=subj+1;
end
cfgga = [];
cfgga.keepindividual = 'yes';
for ff=1:length(fTFR)
    str_GA = 'GA.(fTFR{ff}) = ft_freqgrandaverage(cfgga';
    str_GAind = 'GAind.(fTFR{ff}) = ft_freqgrandaverage(cfgga';
    for ss = 1:size(faux(:,ff),1)
        str_GA = [str_GA, ',faux(', num2str(ss), ',ff)'];
        str_GAind = [str_GAind, ',fauxInd(', num2str(ss), ',ff)'];
    end
    str_GA = [str_GA,');'];
    eval(str_GA)
    str_GAind = [str_GAind,');'];
    eval(str_GAind)
end

%%
rois            = {{'F5','FC3','FC5'},{'F6','FC4','FC6'},{'C3','C5','CP3','CP5'},{'C4','C6','CP4','CP6'},...
                    {'P3','P5','PO3','PO7'},{'P4','P6','PO4','PO8'},{'POz','Oz','O1','O2'}};
roisLabels      = {'FrontoCentral-Left','FrontoCentral-Right','CentroParietal-Left','CentroParietal-Right','Parietal-Left','ParietalRight','Occipital'};
freqBands       = [9 13;14 18;19 23];
bandLabels      = {'alpha','alpha-beta','beta'};
fTFR            = fields(GA);
cmap1            = cbrewer('qual','Set1',9);
cmap2            = cbrewer('qual','Pastel1',9);
GAaux          = GA;
for r = 1:length(rois)
    for fb = 1:length(freqBands)
        fh=figure;
        for cond = 1:length(fTFR)
        
            auxCh     = find(ismember(GAaux.(fTFR{cond}).label,rois{r}));
            auxFreq   = find(GAaux.(fTFR{cond}).freq>=freqBands(fb,1) & GAaux.(fTFR{cond}).freq<=freqBands(fb,2));
            auxdata   = squeeze(mean(mean(sqrt(GAaux.(fTFR{cond}).powspctrm(:,auxCh,auxFreq,:)),2),3)); % amplitude spectra
%             tmean     = @(x) trimmean(x,20);
%             CIauxdata =bootci(1000,tmean,auxdata);
%               jbfill(GAaux.(fTFR{cond}).time,CIauxdata(2,:),CIauxdata(1,:),cmap1(cond,:),cmap2(cond,:),1,.6);
             jbfill(GAaux.(fTFR{cond}).time,trimmean(auxdata,20)+std(auxdata)./sqrt(size(auxdata,1)),...
                 trimmean(auxdata,20)-std(auxdata)./sqrt(size(auxdata,1)),cmap1(cond,:),cmap2(cond,:),1,.6);
            hold on
            h(cond) = plot(GAaux.(fTFR{cond}).time,trimmean(auxdata,20),'Color',cmap1(cond,:),'LineWidth',2);
        end
        legend(h,fTFR)
        title([roisLabels{r} ' ' bandLabels{fb}])
        tightfig
        doimage(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/'],'png',[datestr(now,'ddmmyy') roisLabels{r} '_' bandLabels{fb} 'SEM'],1)
    
    end
end

%%
load(cfg_eeg.chanfile)
cfgp            = [];
cfgp.showlabels = 'no'; 
cfgp.fontsize   = 12; 
cfgp.elec       = elec;
cfgp.interactive    = 'yes';
% cfgp.trials     =4
%              cfgp.baseline       = p.bsl;
%              cfgp.baselinetype   = 'db';
% % cfgp.ylim           = [0 40];
%  cfgp.xlim           = [-.75 1.25];

data = TFR.fix.ICAem;
% 
 figure,ft_multiplotTFR(cfgp,data)

