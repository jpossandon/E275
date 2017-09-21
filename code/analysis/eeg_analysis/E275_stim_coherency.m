clear
E275_params                                 % basic experimental parameters               % 
fmodel                      = 13;            % wich glm model
E275_models 

%%
% coherence test
% this is with already the imaginary coherence values, contrasting
% conditions and permuting signs
cfg_eeg     = eeg_etParams_E275('expfolder','/Users/jossando/trabajo/E275/',...
        'analysisname','stimlockTFR');
load(cfg_eeg.chanfile)
elec        = bineigh(elec);
alfa        = .01;%/ nchoosek(64,2);

bands           = {'alpha','beta'};
fieldstoav      = {'LU','RU','LC','RC'};
contrasts       = [1 2;3 4;1 3;2 4];
contrastLabels  = {'LUvsRU','LCvsRC','LUvsLC','RUvsRC'};
npermute        = 250;
for bb = 1:length(bands)
	subj = 1;
    for tk = p.subj; % subject number
        cfg_eeg     = eeg_etParams_E275(cfg_eeg,'sujid',sprintf('s%02d',tk)); % this is just to being able to do analysis at work and with my laptop
        load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid p.analysisname],'cohim')            
        for ff = 1:length(fieldstoav)
            allcohim.(bands{bb}).(fieldstoav{ff}).coherency(subj,:,:) = cohim.(bands{bb}).(fieldstoav{ff}).cohspctrm;
            allcohim.(bands{bb}).(fieldstoav{ff}).time = cohim.(bands{bb}).(fieldstoav{ff}).time;
        end
        subj = subj+1;
    end
end

%%

for bb = 1:length(bands)
    for ff = 1:length(fieldstoav)
        auxcoherency = squeeze(mean( allcohim.(bands{bb}).(fieldstoav{ff}).coherency));
        allcohim.(bands{bb}).(fieldstoav{ff}).imcoh = imag(auxcoherency);
        auxfimcoherency             = imag(auxcoherency./abs(auxcoherency).*atanh(abs(auxcoherency))); % calculation os fisher z transformed cohrency
        anlstdCohy                  = (1-abs(auxcoherency).^2).*atanh(abs(auxcoherency)).^2./abs(auxcoherency).^2; % SEM for cohreency
        anlstdCohy                  = sqrt(1./2./size(allcohim.(bands{bb}).(fieldstoav{ff}).coherency,1).*(anlstdCohy.*cos(angle(auxcoherency)).^2+sin(angle(auxcoherency)).^2));
        allcohim.(bands{bb}).(fieldstoav{ff}).pvalue = normcdf(abs(auxfimcoherency./anlstdCohy),0,1,'upper');
    end
end

%%
    

% plot all subject im cohrency by condition and differences
  
load('/Users/jossando/trabajo/E275/channels/chanlocseasycapM1E275.mat')
load(cfg_eeg.chanfile)
load('/Users/jossando/trabajo/CEM/code/auxiliar/cmapjp','cmap')
prepareTopoConnect
elec            = bineigh(elec);
labelcmbYo      = elec.label(elec.bi.chan_comb);
elec            = bineigh(elec);
    
% This gives a sign to correct imcoh values so + mean left to right and 
% (-) means right to left (e.g. a positive imcoh value in which the first 
% channel is to the right that the left is transformed to a negative value), 
% the first - sign is there because my structure of channels combination, 
% from which i get the electrodes positions, has the columns inverted with
%respect to the outputs of connectivity functions from fieldtrip
invIcoh         = -(sign(xpos(elec.bi.chan_comb(:,2))'-xpos(elec.bi.chan_comb(:,1))')); 
invIcoh(invIcoh==0) = 1;
alfa            = .05;%/ nchoosek(76,2);
collim          =[-.7 .7];
ncmap           = 21;
cmap3           = cbrewer('div','RdYlBu',ncmap);
bandslabel      = {'alpha','beta'};
fieldstoav      = {'LU','RU','LC','RC'};
contrasts       = [1 2;3 4;1 3;2 4];
contrastLabels  = {'LvsR','LcvsRc','LvsLc','RvsRc'};  
tiempos         = -.08:.02:.7;
icohPlotThres   = .1;
    % plots per condition
    %%
for ff = 1:4
    for bb =1:2
    	data = allcohim.(bands{bb}).(fieldstoav{ff});
        [h, crit_p, adj_ci_cvrg,adj_p]=fdr_bh(data.pvalue(:));
        data.pvalue = reshape(adj_p,size(data.pvalue));
        data.cohspctrm = data.imcoh.*repmat(invIcoh,1,size(data.imcoh,2)); % chnage icoh sign according to left-right convention
        fh = figure;
        set(fh,'Position',[1 5 1280 700]);
        for tt = 1:length(tiempos)
            subplot(5,8,tt)
            topoplot(zeros(length(chanlocs),1),chanlocs,'maplimits',collim,'colormap',cmap,'whitebk','on','shading','interp','electrodes','on');
            hold on
            indxT   = find(round(data.time,2)>=tiempos(tt),1,'first');
            indxBi  = find(data.pvalue(:,indxT)<alfa);
            if ~isempty(indxBi)
                icohVal = data.cohspctrm(indxBi,indxT);
                icohVal(abs(icohVal)>icohPlotThres) = sign(icohVal(abs(icohVal)>icohPlotThres)).*icohPlotThres;  % this is for the color scale capped at icohPlotThres
                for ia = 1:length(indxBi)
                    cval = cmap3(round(icohVal(ia)./.1*10)+11,:);
                    plot([xpos(elec.bi.chan_comb(indxBi(ia),1))',xpos(elec.bi.chan_comb(indxBi(ia),2))']',...
                        [ypos(elec.bi.chan_comb(indxBi(ia),1))',ypos(elec.bi.chan_comb(indxBi(ia),2))']',...
                        'Color',cval,'LineWidth',1)
                end

            end
            title(sprintf(' t %2.2f',tiempos(tt)))
            hold on
        end
        [ax,h]=suplabel(['Imcoh ' bands{bb} ' ' fieldstoav{ff} ' All Subj'], 't',[.075 .1 .9 .87]);
        tightfig
        doimage(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/imcoh_figures/'],'png',[datestr(now,'ddmmyy') '_all_imcoh_' bands{bb} '_' fieldstoav{ff}],1)

    end
end
