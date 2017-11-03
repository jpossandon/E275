% E275
% Basic TF analysis aligned to stimulus
% - Simple TF charts
% - Selection fo peak frequencies at theta, alpha and beta bands
% - GlM analysis per frequency
clear
E275_params                                 % basic experimental parameters               % 
fmodel                      = 13;            % wich glm model
E275_models 
%%
% TFR
% sge               = str2num(getenv('SGE_TASK_ID'));
stimB_alpha = []; stimB_alpha_mirr = [];
stimB_beta = [];  stimB_beta_mirr = [];
for tk = p.subj; % subject number

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

    E275_base_trl_event_def_stim                                        % trial configuration  
    
    cfgcoh              = [];
    cfgcoh.method       = 'coh';
    cfgcoh.complex      = 'complex';
    
    
    % Locked to stimulus
    at  = 1;
    mkdir([cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/TFR_' p.analysis_type{at} '/'])
    freqsbands = [10 13;20 25];
   
    for e = 1:4
         E275_models
         [aux,toelim]= getTFRsfromtrl({cfg_eeg},{trls.(p.trls_stim{e})},p.bsl,p.rref,p.analysis_type{at},p.keep,p.cfgTFR);
        aux.ICAem.toelim = toelim;
%         allcohim = ft_connectivityanalysis(cfgcoh,aux.ICAem);
%         aux.ICAem.powspctrm = aux.ICAem.fourierspctrm.*conj(aux.ICAem.fourierspctrm);
%         aux.ICAem     = rmfield(aux.ICAem,'fourierspctrm');
        eval(['TFR_' p.trls_stim{e} '=aux;'])
        
        p.cfgTFR.output             = 'powandcsd';	
        p.cfgTFR.foi = freqsbands(1,:);
        p.cfgTFR.t_ftimwin          = p.cfgTFR.winsize*ones(1,length(p.cfgTFR.foi));
        p.cfgTFR.tapsmofrq          = ones(1,length(p.cfgTFR.foi));
        [aux,toelim]= getTFRsfromtrl({cfg_eeg},{trls.(p.trls_stim{e})},p.bsl,p.rref,p.analysis_type{at},p.keep,p.cfgTFR);
        cohim.alpha.(p.trls_stim{e}) = ft_connectivityanalysis(cfgcoh,aux.ICAem);
        cohim.alpha.(p.trls_stim{e}).cohspctrm = squeeze(mean(cohim.alpha.(p.trls_stim{e}).cohspctrm,2));
        
        p.cfgTFR.foi = freqsbands(2,:);
        p.cfgTFR.t_ftimwin          = p.cfgTFR.winsize*ones(1,length(p.cfgTFR.foi));
        p.cfgTFR.tapsmofrq          = ones(1,length(p.cfgTFR.foi));
        [aux,toelim]= getTFRsfromtrl({cfg_eeg},{trls.(p.trls_stim{e})},p.bsl,p.rref,p.analysis_type{at},p.keep,p.cfgTFR);
        cohim.beta.(p.trls_stim{e}) = ft_connectivityanalysis(cfgcoh,aux.ICAem);
        cohim.beta.(p.trls_stim{e}).cohspctrm = squeeze(mean(cohim.beta.(p.trls_stim{e}).cohspctrm,2));
    end
%     %      mirroring left stimulation data to make contra/ipsi plots
%     mirindx         = mirrindex(TFR_LU.(p.analysis_type{1}).label,[cfg_eeg.expfolder '/channels/mirror_chans']); 
%     TFR_LUmirr      = TFR_LU;
%     TFR_LCmirr      = TFR_LC;
%     TFR_LUmirr.(p.analysis_type{at}).powspctrm = TFR_LU.(p.analysis_type{at}).powspctrm(:,mirindx,:,:);
%     TFR_LCmirr.(p.analysis_type{at}).powspctrm = TFR_LC.(p.analysis_type{at}).powspctrm(:,mirindx,:,:);
% 
%     cfgs            = [];
%     cfgs.parameter  = 'powspctrm';
%     TFR_U.(p.analysis_type{1})           = ft_appendfreq(cfgs, TFR_RU.(p.analysis_type{1}),TFR_LUmirr.(p.analysis_type{1})); % ERASEME: there was an error here apeenof TFR.RU with TFR.LU instead of TFR.LUmirr
%     TFR_C.(p.analysis_type{1})           = ft_appendfreq(cfgs, TFR_RC.(p.analysis_type{1}),TFR_LCmirr.(p.analysis_type{1})); %SAME
% 
%     
%      fieldstoav      = {'LU','RU','LC','RC','LUmirr','LCmirr','image','U','C'};
     fieldstoav      = {'LU','RU','LC','RC'};
     for f = 1:length(fieldstoav)
     TFRav.(fieldstoav{f}).(p.analysis_type{1}) = ft_freqdescriptives([], eval(['TFR_' fieldstoav{f} '.(p.analysis_type{1})']));
     end
    save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid p.analysisname],'TFRav','cfg_eeg','p','cohim')            
% 
%     % betas for glmb by freq bands
%      freqsbands = [9 14;20 25];
     bandslabel = {'alpha','beta'};
%     
     cfgr.baseline          = p.bsl;
     cfgr.baselinetype      = 'relative';
%     
     for fb = 1:size(freqsbands,1)
         for f = 1:4 
             aux = eval(['TFR_' fieldstoav{f}]);
             indxfreqs                          = find(aux.(p.analysis_type{1}).freq>freqsbands(fb,1) & aux.(p.analysis_type{1}).freq<freqsbands(fb,2));
             aux.(p.analysis_type{1}).trial     = squeeze(nanmean(aux.(p.analysis_type{1}).powspctrm(:,:,indxfreqs,:),3));
             aux.(p.analysis_type{1})           = rmfield(aux.(p.analysis_type{1}),'powspctrm');
             aux.(p.analysis_type{1}).freq      = mean(freqsbands(fb,:));
             aux.(p.analysis_type{1}).dimord    = 'rpt_chan_time';
%              meanVals                           = repmat(nanmean(aux.(p.analysis_type{1}).trial(:,:,[aux.(p.analysis_type{1}).time>p.bsl(1) & aux.(p.analysis_type{1}).time<p.bsl(2)],:), 3), [1 1 size(aux.(p.analysis_type{1}).trial,3) 1]);
               meanVals                           = repmat(nanmean(aux.(p.analysis_type{1}).trial, 3), [1 1 size(aux.(p.analysis_type{1}).trial,3) 1]); % complete trial normalization
             aux.(p.analysis_type{1}).trial     = aux.(p.analysis_type{1}).trial./meanVals;  % relative trial by trial normalization is baised by I need to look more into this
             TFRaux.(bandslabel{fb}).(fieldstoav{f}) = aux;
             aux.(p.analysis_type{1}).avg = squeeze(mean(aux.(p.analysis_type{1}).trial));
%              fh = plot_topos(cfg_eeg, aux.(p.analysis_type{1}),p.interval,[],[-1 1],[filename ' ' bandslabel{fb} ' ' fieldstoav{f}]);
% %             doimage(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/'],'png',[bandslabel{fb} '_' fieldstoav{f}],1)
% %             saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' filename '_' bandslabel{fb} '_' fieldstoav{f}],'fig')
% %             close(fh)
         end
%         
         TFR.(bandslabel{fb})(1) = aux;
         TFR.(bandslabel{fb})(1).(p.analysis_type{1}).trial = cat(1,TFRaux.(bandslabel{fb}).LU.(p.analysis_type{1}).trial,TFRaux.(bandslabel{fb}).LC.(p.analysis_type{1}).trial);
         TFR.(bandslabel{fb})(1).(p.analysis_type{1}).toelim = {[TFRaux.(bandslabel{fb}).LU.(p.analysis_type{1}).toelim{:};size(trls.LU,1)+TFRaux.(bandslabel{fb}).LC.(p.analysis_type{1}).toelim{:}]};
         TFR.(bandslabel{fb})(2) = aux;
         TFR.(bandslabel{fb})(2).(p.analysis_type{1}).trial = cat(1,TFRaux.(bandslabel{fb}).RU.(p.analysis_type{1}).trial,TFRaux.(bandslabel{fb}).RC.(p.analysis_type{1}).trial);
         TFR.(bandslabel{fb})(2).(p.analysis_type{1}).toelim = {[TFRaux.(bandslabel{fb}).RU.(p.analysis_type{1}).toelim{:};size(trls.RU,1)+TFRaux.(bandslabel{fb}).RC.(p.analysis_type{1}).toelim{:}]};
%         
%         
     end
%      p.mirror         = [];
    [modelos_stim]   = regmodelpermutef({cfg_eeg},TFR.alpha,p);
    stimB_alpha      = cat(4,stimB_alpha,modelos_stim.B);
    [modelos_stim]   = regmodelpermutef({cfg_eeg},TFR.beta,p);
    stimB_beta       = cat(4,stimB_beta,modelos_stim.B);
%    
%    p.mirror         = [1 0];
%    [modelos_stim_mirr]   = regmodelpermutef({cfg_eeg},TFR.alpha,p);
%    stimB_alpha_mirr      = cat(4,stimB_alpha_mirr,modelos_stim_mirr.B);
%    [modelos_stim_mirr]   = regmodelpermutef({cfg_eeg},TFR.beta,p);
%    stimB_beta_mirr       = cat(4,stimB_beta_mirr,modelos_stim_mirr.B);
    tiempo = modelos_stim.time';
    save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' datestr(now,'ddmmyy') 'betas_' p.analysisname],'stimB_alpha','stimB_beta','tiempo','cfg_eeg','p')            

end
 
%%
%2nd level analysis glm


% meanVals = repmat(nanmean(stimB_alpha(:,:,[modelos_stim.time>p.bsl(1) & modelos_stim.time<p.bsl(2)],:), 3), [1 1 size(stimB_alpha,3) 1]);
% stimB_alpha = stimB_alpha-meanVals;
% meanVals = repmat(nanmean(stimB_beta(:,:,[modelos_stim.time>p.bsl(1) & modelos_stim.time<p.bsl(2)],:), 3), [1 1 size(stimB_beta,3) 1]);
% stimB_beta = stimB_beta-meanVals;

load(cfg_eeg.chanfile)
result.alpha        = regmodel2ndstat(stimB_alpha,tiempo,elec,2000,'signpermT','cluster');
result.beta         = regmodel2ndstat(stimB_beta,tiempo,elec,2000,'signpermT','cluster');
% result_alpha_mirr   = regmodel2ndstat(stimB_alpha_mirr,tiempo,elec,2000,'signpermT','cluster');
% result_beta_mirr    = regmodel2ndstat(stimB_beta_mirr,tiempo,elec,2000,'signpermT','cluster');
save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' datestr(now,'ddmmyy') '_TFRglm_' p.analysisname],'result','stimB_alpha','stimB_beta','p','cfg_eeg');

%%
p.interval = [-.2 1 .025]
bands = {'alpha','beta'};
for bb = 1:length(bands)
    eval(['stimB  = stimB_' bands{bb} ';'])
    for b=1:size(result.(bands{bb}).B,2)
        betas.dof   = 1;
        betas.n     = size(stimB,4);
        betas.avg   = squeeze(median(stimB(:,b,:,:),4));
        betas.time  = tiempo;
        collim      =[-6*std(betas.avg(:)) 6*std(betas.avg(:))]; 
        fh = plot_stat(cfg_eeg,result.(bands{bb}).clusters(b),betas,[],p.interval,collim,.05,sprintf('Beta:%s',p.coeff{b}),1);
      doimage(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/'],'png',[datestr(now,'ddmmyy') '_' bands{bb} '_glm' p.coeff{b} '_' p.analysisname],1)
%            saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' datestr(now,'ddmmyy') 'glm_' p.coeff{b} '_' p.analysisname],'fig')
    %     close(fh)
    end
end

%%
% grand averages
at                  = 1;
p.analysis_type     = {'ICAem'}; %'plain' / 'ICAe' / 'ICAm' / 'ICAem' 
cfgr                = [];
p.bsl               = [-.44 -.15]; 
cfgr.baseline       = p.bsl;
cfgr.baselinetype   = 'relative';
subj=1;
for tk = p.subj
    if ismac    
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),'analysisname','stimlockTFR','expfolder','/Users/jossando/trabajo/E275/'); % this is just to being able to do analysis at work and with my laptop
    else
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),'analysisname','stimlockTFR');
    end
    load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/'  cfg_eeg.sujid p.analysisname],'TFRav','cfg_eeg','p')
    fTFR    = fields(TFRav);
    for ff=1:length(fTFR)
        faux(subj,ff) = ft_freqbaseline(cfgr,TFRav.(fTFR{ff}).(p.analysis_type{1}));
    end
    subj=subj+1;
end
cfgga = [];
cfgga.keepindividual = 'yes';
for ff=1:length(fTFR)
    str_GA = 'GA.(fTFR{ff}) = ft_freqgrandaverage(cfgga';
    for ss = 1:size(faux(:,ff),1)
        str_GA = [str_GA, ',faux(', num2str(ss), ',ff)'];
    end
    str_GA = [str_GA,');'];
    eval(str_GA)
end

mirindx         = mirrindex(GA.LU.label,[cfg_eeg.expfolder '/channels/mirror_chans']); 
for ff=1:length(fTFR)
    GAhm.(fTFR{ff}) = GA.(fTFR{ff});
    GAhm.(fTFR{ff}).powspctrm = GAhm.(fTFR{ff}).powspctrm-GAhm.(fTFR{ff}).powspctrm(:,mirindx,:,:);
end
%%
%  [freq1]             = ft_freqbaseline(cfgr,GA.ICAem);
%  [freq2]             = ft_freqbaseline(cfgr, TFR_C.ICAem);
% 
% %%
 load(cfg_eeg.chanfile)
statLRu = freqpermWS(GA.LU,GA.RU,elec,1000);
statLRc = freqpermWS(GA.LC,GA.RC,elec,1000);
statL = freqpermWS(GA.LU,GA.LC,elec,1000);
statR = freqpermWS(GA.RU,GA.RC,elec,1000);
%%
% freq1av   = ft_freqdescriptives([], freq1);
% freq2av   = ft_freqdescriptives([], freq2);

cfgs            = [];
cfgs.parameter  = 'powspctrm';
cfgs.operation  = 'subtract';
GA.LUvsLC       = ft_math(cfgs,GA.LU,GA.LC);
GA.RUvsRC       = ft_math(cfgs,GA.RU,GA.RC);
GA.LUvsRU       = ft_math(cfgs,GA.LU,GA.RU);
GA.LCvsRC       = ft_math(cfgs,GA.LC,GA.RC);

GAhm.LUvsLC       = ft_math(cfgs,GAhm.LU,GAhm.LC);
GAhm.RUvsRC       = ft_math(cfgs,GAhm.RU,GAhm.RC);
% difffreq.mask   = statUC.mask;
%%
load(cfg_eeg.chanfile)
cfgp            = [];
cfgp.showlabels = 'no'; 
cfgp.fontsize   = 12; 
cfgp.elec       = elec;
cfgp.interactive    = 'yes';
% cfgp.trials     =4
    cfgp.baseline       = p.bsl;
  cfgp.baselinetype   = 'db';
% cfgp.ylim           = [0 40];
%  cfgp.xlim           = [-.75 1.25];
%          cfgp.zlim           = [-.15 .15]
%     cfgp.maskparameter = 'mask';
%       cfgp.maskalpha = .3
 data = TFRav.LU.ICAem;
% 
figure,ft_multiplotTFR(cfgp,data)
% 

%%
% GA analysis
%GAstd.LU = GA.LU
%GAstd.LU.powspctrm = std(GAstd.LU.powspctrm);

GAlen   = GA;
fTFR    = fields(GA);
for ff=1:length(fTFR)
    data = GA.(fTFR{ff}).powspctrm;
        for suj = 1:size(data,1)
            for freq = 1:size(data,3)
                dsujfreq = squeeze(data(suj,:,freq,:))'-1;                 % -1 if it is relative baseline
                [r,c]    = size(dsujfreq);
                for ssign = 1:2
                    clusaux  = zeros(r+2,c);    % two more rows to find cluster at the begining and end
                    if ssign == 1
                        clusaux(2:end-1,:)  = dsujfreq>0;
                    else
                        clusaux(2:end-1,:)  = dsujfreq<0;
                    end
                    clusaux             = diff(clusaux);   % find start and end of continuous segments of 1s
                    [~,j]               = ind2sub(size(clusaux),find(clusaux==1));
                    [~,jj]              = ind2sub(size(clusaux),find(clusaux==-1));
                    indx_chclus         = [find(clusaux==1)-j+1,find(clusaux==-1)-jj+1-1];
                    for e = 1:size(indx_chclus,1)          % here we give to every cluster (only in the time[rows] dimension)
                        if ssign == 1
                            dsujfreq(indx_chclus(e,1):indx_chclus(e,2)) = indx_chclus(e,2)-indx_chclus(e,1)+1;
                        else
                            dsujfreq(indx_chclus(e,1):indx_chclus(e,2)) = -(indx_chclus(e,2)-indx_chclus(e,1)+1);
                        end
                    end
                    data(suj,:,freq,:) = dsujfreq';
                    
                end
            end
        end
   GAlen.(fTFR{ff}).powspctrm = data;
end

% %%
% % Comparisons stat
% cfgr                = [];
% cfgr.baseline       = p.bsl;
% cfgr.baselinetype   = 'db';
% [freq1]             = ft_freqbaseline(cfgr, TFR.RU.(p.analysis_type{at}));
% [freq2]             = ft_freqbaseline(cfgr, TFR.RC.(p.analysis_type{at}));
%     
% % load(cfg_eeg.chanfile)
% % statLR = freqpermBT(freq1,freq2,elec)
%%
% comparison of subject specifc band responses between 100 and 700 ms
freqsbands  = [9 15;16 20;21 25;26 30];
fbLabel     = {'9-15Hz','16-20Hz','21-25Hz','26:30Hz'};
fTFR        = {'LU','RU','LC','RC'};
times       = [.1 .7 .1]; 

 cfg_eeg                 = eeg_etParams_E275('expfolder','/Users/jossando/trabajo/E275/',...
                                            'analysisname','stimlockTFR');  
load('cmapjp','cmap') 
cmap = [flipud(cbrewer('seq','YlGnBu',128));cbrewer('seq','YlOrRd',128)];

load(cfg_eeg.chanlocs)

    
cfgr                = [];
p.bsl               = [-.44 -.15]; 
cfgr.baseline       = p.bsl;
cfgr.baselinetype   = 'relative';
collim              = [-0 2];
for fb = 3:size(freqsbands,1)
    for ff = 1:length(fTFR)
        fh = figure;
        set(gcf,'Position', [7 31 1920 1100])
        numsp = 1;
        for tk = p.subj;
            cfg_eeg                 = eeg_etParams_E275(cfg_eeg,'sujid',sprintf('s%02d',tk));
            load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid p.analysisname],'TFRav')
            
            data    = ft_freqbaseline(cfgr,TFRav.(fTFR{ff}).(p.analysis_type{1}));
            tiempos = times(1):times(3):times(2)-times(3);
            for t = tiempos
                subplot(16,12,numsp)
                indxsamples    = data.time>=t & data.time<t+times(3);
                indxfrex       = data.freq>=freqsbands(fb,1) & data.freq<=freqsbands(fb,2);
                topoplot(squeeze(mean(mean(data.powspctrm(:,indxfrex,indxsamples),2),3)),...
                    chanlocs,'emarker',{'.','k',5,1},'maplimits',collim,'colormap',cmap,'electrodes','off','headrad',0);
                if numsp<13
                    title(sprintf('%2.3f < t < %2.3f',t,t+times(3)))
                end
                if t==times(1)
                    text(-2,0,cfg_eeg.sujid,'FontWeight','demi','FontSize',12)
                end
                numsp = numsp +1;
            end
        end
        [ax,h]=suplabel(sprintf('%s %s',fbLabel{fb},fTFR{ff}),'t',[.075 .1 .9 .87]);
        tightfig
         doimage(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/'],'png',[datestr(now,'ddmmyy') '_' fTFR{ff} '_' fbLabel{fb} '_ALL'],1)
     
    end
end
%%
% coherence analysis
E275_stim_coh