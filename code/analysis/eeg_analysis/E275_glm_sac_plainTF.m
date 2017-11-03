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
                                            'analysisname','saclockTFRplain');    % single experiment/session parameters 
   
     load([cfg_eeg.eyeanalysisfolder cfg_eeg.filename 'eye.mat'])            % eyedata               
   [trl,events]         = define_event(cfg_eeg,eyedata,2,{'&origstart','>0'},...
                            [1000 400],{1,1,'origstart','>0';-1,1,'origstart','>0';-1,1,'dur','>400'}); 
     
    saccade             = {trl};
    eyecent             = {(events.posendx(2:3:end)-events.posinix(2:3:end))/45};
    scrcent             = {(events.posendx(2:3:end)-960)/45};   
    eyecenty            = {(events.posendy(2:3:end)-events.posiniy(2:3:end))/45};
    scrcenty            = {(events.posendy(2:3:end)-540)/45}; 
    cfgs                = {cfg_eeg};
        
    cfgTFR.channel      = 'all';	
    cfgTFR.keeptrials   = 'yes';	                
    cfgTFR.method       = 'tfr';
    cfgTFR.width        = 4; 
    cfgTFR.output       = 'pow';	
    cfgTFR.foi          = 5:1:40;
    cfgTFR.toi          = (-700:10:100)/1000;
    cfgTFR.pad          = 2*2000/1000;    
    p.bsl               = [-.4 -.3];
    p.reref             = 'yes';
    p.analysis_type     = {'ICAem'};
    p.keep              = 'yes';
    at =1;
    
    [TFR_all toelim]    = getTFRsfromtrl(cfgs,saccade,p.bsl,p.reref,p.analysis_type{at},p.keep,cfgTFR);
   
    p.bsl               = [-.4 -.3];
    p.reref             = 'yes';
    p.analysis_typ      = 'ICAem';
    p.analysisname      = 'saccade_eyeheadTFR';
%     p.interact          = [1 2];
    p.coeff             = {'const','eyex','headx','eyey','heady','eyex*headx','eyey*heady'};
    keep                = 'yes';
    
    eyevalues   = [];     scrvalues     = [];
    eyevaluesy  = [];     scrvaluesy    = [];

    for ip = 1:size(saccade,2) % sessions
        eyevalues       = [eyevalues;eyecent{ip}(setdiff(1:length(eyecent{ip}),toelim{ip}))'];
        scrvalues       = [scrvalues;scrcent{ip}(setdiff(1:length(scrcent{ip}),toelim{ip}))'];
        eyevaluesy      = [eyevaluesy;eyecenty{ip}(setdiff(1:length(eyecenty{ip}),toelim{ip}))'];
        scrvaluesy      = [scrvaluesy;scrcenty{ip}(setdiff(1:length(scrcenty{ip}),toelim{ip}))'];
    end
    XY = sign([eyevalues,scrvalues,eyevaluesy,scrvaluesy,eyevalues.*scrvalues,eyevaluesy.*scrvaluesy]);
   
    sacall(sge).eyex    = eyevalues';
    sacall(sge).headx   = scrvalues';
    sacall(sge).eyey    = eyevaluesy';
    sacall(sge).heady   = scrvaluesy';
    
%     freqsbands          = [9 14;15 20;21 26];
%     bandslabel          = {'alpha','lowbeta','highbeta'};
%     cfgr.baseline       = p.bsl;
%     cfgr.baselinetype   = 'relative';
    
    meanVals            = repmat(nanmean(TFR_all.(p.analysis_type{1}).powspctrm, 4), [1 1 1 size(TFR_all.(p.analysis_type{1}).powspctrm,4)]);             % complete trial normalization
    TFR_all.(p.analysis_type{1}).powspctrm = TFR_all.(p.analysis_type{1}).powspctrm./meanVals;
    
    % baseline coorects
    indxbsl             = TFR_all.(p.analysis_type{1}).time >= p.bsl(1) & TFR_all.(p.analysis_type{1}).time <= p.bsl(2);
    meanVals            = repmat(nanmean(TFR_all.(p.analysis_type{1}).powspctrm(:,:,:,indxbsl), 4), [1 1 1 size(TFR_all.(p.analysis_type{1}).powspctrm,4)]);             % complete trial normalization
    TFR_all.(p.analysis_type{1}).powspctrm = TFR_all.(p.analysis_type{1}).powspctrm-meanVals;
    
    clear meanVals
    load(cfgs{1}.chanfile)
    for fb = 1:size(TFR_all.(p.analysis_type{1}).freq,2)
        Y                   = squeeze(TFR_all.(p.analysis_type{at}).powspctrm(:,:,fb,:));
        [B,Bt,STATS,T]      = regntcfe(Y,XY,1,'effect',elec,0);
        modelos(sge).B(:,:,:,fb)      = B;
        modelos(sge).Bt(:,:,:,fb)     = Bt;
        modelos(sge).STATS(:,:,:,fb)  = STATS;
        modelos(sge).TCFE(:,:,:,fb)   = T;
        modelos(sge).n      = size(Y,1);
        modelos(sge).time   = TFR_all.(p.analysis_type{at}).time;
        
    end
    if sge == 1
    	stimB = modelos(sge).B;
    else
    	stimB = cat(5,stimB,modelos(sge).B);
    end
%     for fb = 1:size(freqsbands,1)
%         indxfreqs           = find(TFR_all.(p.analysis_type{1}).freq>freqsbands(fb,1) & TFR_all.(p.analysis_type{1}).freq<freqsbands(fb,2));
%         Y                   = squeeze(nanmean(TFR_all.(p.analysis_type{at}).powspctrm(:,:,indxfreqs,:),3));
%         load(cfgs{1}.chanfile) 
%         [B,Bt,STATS,T]      = regntcfe(Y,XY,1,'effect',elec,0);
%         modelos.(bandslabel{fb})(sge).B      = B;
%         modelos.(bandslabel{fb})(sge).Bt     = Bt;
%         modelos.(bandslabel{fb})(sge).STATS  = STATS;
%         modelos.(bandslabel{fb})(sge).TCFE   = T;
%         modelos.(bandslabel{fb})(sge).n      = size(Y,1);
%         modelos.(bandslabel{fb})(sge).time   = TFR_all.(p.analysis_type{at}).time;
%         if sge == 1
%             stimB.(bandslabel{fb}) = B;
%         else
%             stimB.(bandslabel{fb}) = cat(4,stimB.(bandslabel{fb}),B);
%         end
%     end
    TFRav.(p.analysis_type{1})(sge) = ft_freqdescriptives([], TFR_all.(p.analysis_type{1}));
     sprintf('\n\n\n**********\nSubject %d \n**********\n\n\n',sge)
    sge = sge +1;
end
save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/TFR/glm_' p.analysisname],'modelos','TFRav','sacall','p')

%%
% here load and create stimB
% and make a new regmodel2ndstat that makes the analysis in 3-d

if ~exist('stimB')
    E275_params 
    stimB = [];
    cfg_eeg             = eeg_etParams_E275('analysisname','saclockTFRplain');    % single experiment/session parameters 
    p.analysisname      = 'saccade_eyeheadTFR'; 
    load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/TFR/glm_' p.analysisname],'modelos','TFRav')
    for sge = 1:length(modelos)
        if sge == 1
            stimB = modelos(sge).B;
        else
            stimB = cat(5,stimB,modelos(sge).B);
        end
    end
    tiempos = modelos(1).time;
    freqs   = TFRav.ICAem.freq;
end
clear modelos TFRav
load(cfg_eeg.chanfile)
result  = regmodel2ndstat3D(stimB,tiempos,freqs,elec,2000,'signpermT','cluster');
save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/TFR/glm_' p.analysisname],'result','-append')

%%
p.interval = [-.7 .02 .01];

for b=1:size(result.B,2)
   
    sclus = find([result.clusters(b).posclusters.prob_abs] < .05);
    if ~isempty(sclus)
        
end

%%
E275_glm_stim_betaplots

%%
figure,
plot([sacall.headx],[sacall.eyex],'.')
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
    
 %%
 %%
% grand averages
cfgga = [];
cfgga.keepindividual = 'no';
 load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/TFR/glm_' p.analysisname],'TFRav')

    str_GA = 'GA = ft_freqgrandaverage(cfgga';
    for ss = 1:size(TFRav.ICAem,2)
        str_GA = [str_GA, ',TFRav.ICAem(', num2str(ss), ')'];
    end
    str_GA = [str_GA,');'];
     eval(str_GA)
     clear TFRav
 GAbeta = GA;
% mirindx         = mirrindex(GA.LU.label,[cfg_eeg.expfolder '/channels/mirror_chans']); 
% for ff=1:length(fTFR)
%     GAhm.(fTFR{ff}) = GA.(fTFR{ff});
%     GAhm.(fTFR{ff}).powspctrm = GAhm.(fTFR{ff}).powspctrm-GAhm.(fTFR{ff}).powspctrm(:,mirindx,:,:);
% end

%%

  GAbeta.powspctrm = permute(squeeze(mean(result.B(:,4,:,:,:),5)),[1,3,2])
load(cfg_eeg.chanfile)
cfgp            = [];
cfgp.showlabels = 'no'; 
cfgp.fontsize   = 12; 
cfgp.elec       = elec;
cfgp.interactive    = 'yes';
cfgp.xlim = [-.6 -.05];
%   cfgp.baseline       = p.bsl ; = [
%   cfgp.baselinetype   = 'db';

     figure
      ft_multiplotTFR(cfgp,GAbeta)
%  cfgp.comment = 'no'
%      figure,ft_topoplotTFR(cfgp,data)