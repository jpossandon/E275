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
            data.(fieldstoav{ff}).imcoh(subj,:,:,:) = cohim.(bands{bb}).(fieldstoav{ff}).cohspctrm;
        end
        subj = subj+1;
    end
  for cont = 1:4
      for np = 1:npermute+1
        if np == 1
            data1 = data.(fieldstoav{contrasts(cont,1)}).imcoh;
            data2 = data.(fieldstoav{contrasts(cont,2)}).imcoh;
           
        else        %here need to change randomly ...
            data1        = [];
            data2         = [];
            for suj=1:length(p.subj)

                if round(rand(1))
                    data1    = cat(1,data1,data.(fieldstoav{contrasts(cont,1)}).imcoh(suj,:,:,:));
                    data2    = cat(1,data2,data.(fieldstoav{contrasts(cont,2)}).imcoh(suj,:,:,:));
                else
                    data1    = cat(1,data1,data.(fieldstoav{contrasts(cont,2)}).imcoh(suj,:,:,:));
                    data2    = cat(1,data2,data.(fieldstoav{contrasts(cont,1)}).imcoh(suj,:,:,:));
                end
            end
        end
        [h,pp,ci,stats] = ttest(data1,data2,alfa);
        for tt = 1:size(h,4)
            haux(1,:,:) = squeeze(h(:,:,:,tt));
            tstaux(1,:,:) = squeeze(stats.tstat(:,:,:,tt));
            hh(:,:,tt,:) = reshape(haux(sub2ind([76 76],elec.bi.chan_comb(:,1),elec.bi.chan_comb(:,2))),[1 1 size(elec.bi.chan_comb,1)]);
            st(:,:,tt,:) = reshape(tstaux(sub2ind([76 76],elec.bi.chan_comb(:,1),elec.bi.chan_comb(:,2))),[1 1 size(elec.bi.chan_comb,1)]);
            if np == 1
                result.sigcohim     = triu(squeeze(h(:,:,:,tt)));
                result.st           = triu(squeeze(stats.tstat(:,:,:,tt)));
            end
        end
        if np == 1
            result.auxcohim     = squeeze(mean(data1-data2));
            [result.clusters]   = clustereeg(st,hh,elec.bi,size(elec.bi.chan_comb,2),size(h,4));
        else
            [auxcluster]   = clustereeg(st,hh,elec.bi,size(elec.bi.chan_comb,2),size(h,4));
            result.clusters.MAXst(np-1) = auxcluster.MAXst;
            result.clusters.MAXst_noabs(np-1,:) = auxcluster.MAXst_noabs;
        end
        np
      end
      save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/imcoh/' datestr(now,'ddmmyy') '_imcoh_' bands{bb} '_' contrastLabels{cont}],'result');
    end
end

%%
% left versus right coherence
cfg_eeg     = eeg_etParams_E275('expfolder','/Users/jossando/trabajo/E275/',...
        'analysisname','stimlockTFR');
load('/Users/jossando/trabajo/E275/channels/chanlocseasycapM1E275.mat')
load(cfg_eeg.chanfile)
elec        = bineigh(elec);
alfa        = .05;%/ nchoosek(64,2);
load('/Users/jossando/trabajo/CEM/code/auxiliar/cmapjp','cmap')
collim      =[-.7 .7];
% cmap3 = cmap
hfd         = figure;
topoplot(zeros(length(chanlocs),1),chanlocs,'maplimits',collim,'colormap',cmap,'whitebk','on','shading','interp','electrodes','on');
da      = get(gca,'Children');
xpos    = get(da(1),'XData');
ypos    = get(da(1),'YData');
close(hfd)
cmap3           = cbrewer('div','RdYlBu',11);
bands           = {'alpha','beta'};
fieldstoav      = {'LU','RU','LC','RC'};
contrasts       = [1 2;3 4;1 3;2 4];
contrastLabels  = {'LUvsRU','LCvsRC','LUvsLC','RUvsRC'};  
for bb = 1:length(bands)
    subj = 1;
    for tk = p.subj; % subject number
        cfg_eeg     = eeg_etParams_E275(cfg_eeg,'sujid',sprintf('s%02d',tk)); % this is just to being able to do analysis at work and with my laptop
        load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid p.analysisname],'cohim')            
        for ff = 1:length(fieldstoav)
            data.(fieldstoav{ff}).imcoh(subj,:,:,:) = cohim.(bands{bb}).(fieldstoav{ff}).cohspctrm;
        end
        subj = subj+1;
    end
    load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/tfr/' cfg_eeg.sujid p.analysisname],'TFRav')            
       
    tiempo = TFRav.LU.ICAem.time;
    for cont = 1:4
        load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/imcoh/' datestr(now,'ddmmyy') '_imcoh_' bands{bb} '_' contrastLabels{cont}],'result');
   
        fh = figure;
        set(fh,'Position',[1 5 1280 700])
        for tt = 1:size(result.clusters.clus_pos,2)/4
            subplot(7,7,tt)
            topoplot(zeros(length(chanlocs),1),chanlocs,'maplimits',collim,'colormap',cmap,'whitebk','on','shading','interp','electrodes','on');
            title(sprintf(' t %2.2f',tiempo(tt*4-3)))
            hold on
        end
        thresh  = prctile(result.clusters.MAXst_noabs(:),[(alfa/2)*100 (1-alfa/2)*100]);
    
        pc = 1;
        for posc = 1:length(result.clusters.maxt_pos)
            if abs(result.clusters.maxt_pos(posc))>thresh(2)
                cluspval = 2.*sum(result.clusters.MAXst_noabs(:,1)>result.clusters.maxt_pos(posc))./numel(result.clusters.MAXst_noabs(:));
                display(sprintf('Positive cluster %d  Positive cluster pval = %4.4f',posc,cluspval))
                for tt = 1:size(result.clusters.clus_pos,2)/4
                    cv = elec.bi.chan_comb(find(result.clusters.clus_pos(:,tt*4-3) ==posc),:);
                    if ~isempty(cv)
                        for ia = 1:size(cv,1)
        %                      cval = cmap3(1+round((1/3/2+auxcohim(ch,cv(ia))).*3.*(size(cmap3,1)-1)),:);
                              cval = cmap3(pc,:);
                               subplot(7,7,tt)
                            plot([xpos(cv(ia,1)) xpos(cv(ia,2))],[ypos(cv(ia,1)) ypos(cv(ia,2))],'Color',cval,'LineWidth',1)
                        end
                    end
                end
                pc = pc+1;
            end
         end
    
          nc = 1;
         for negc = 1:length(result.clusters.maxt_neg)
            if result.clusters.maxt_neg(negc)<thresh(1)
                cluspval = 2.*sum(result.clusters.MAXst_noabs(:,2)<result.clusters.maxt_neg(negc))./numel(result.clusters.MAXst_noabs(:));
                display(sprintf('Negative cluster %d  Negative cluster pval = %4.4f',negc,cluspval))
                for tt = 1:size(result.clusters.clus_neg,2)/4
                     cv = elec.bi.chan_comb(find(result.clusters.clus_neg(:,tt*4-3) ==negc),:);
    %                  tt
                    if ~isempty(cv)
                        for ia = 1:size(cv,1)
        %                      cval = cmap3(1+round((1/3/2+auxcohim(ch,cv(ia))).*3.*(size(cmap3,1)-1)),:);
                              cval = cmap3(end-nc,:);
                               subplot(7,7,tt)
                            plot([xpos(cv(ia,1)) xpos(cv(ia,2))],[ypos(cv(ia,1)) ypos(cv(ia,2))],'Color',cval,'LineWidth',1)
                        end
                    end
                end
                nc = nc+1;
            end
         end
        nc=1;
        [ax,h]=suplabel(['Imcoh ' bands{bb} ' ' contrastLabels{cont}], 't',[.075 .1 .9 .87]);
        tightfig
        doimage(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/imcoh/figures/'],'png',[datestr(now,'ddmmyy') '_imcoh_' bands{bb} '_' contrastLabels{cont}],1)
    
    end 
    
%     title(leglab)close all
end
