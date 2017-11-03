% GLM result plots
mkdir([cfg_eeg.analysisfolder cfg_eeg.analysisname '/' p.analysisname '/figures/' datestr(now,'ddmmyy')])
for b=1:size(result.B,2)
    betas.dof   = 1;
    betas.n     = size(stimB,4);
    betas.avg   = squeeze(median(stimB(:,b,:,:),4));
    betas.time  = result.clusters(1).time;
    
    % topoplot across time according to p.interval with significant
    % clusters
    collim      =[-6*std(betas.avg(:)) 6*std(betas.avg(:))]; 
    fh = plot_stat(cfg_eeg,result.clusters(b),betas,[],p.interval,collim,.05,sprintf('Beta:%s',p.coeff{b}),1);
    doimage(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/' p.analysisname '/figures/' datestr(now,'ddmmyy') '/'],'png',[ datestr(now,'ddmmyy') '_' model '__' p.coeff{b}],1)
    
    % same but instead of voltage values, colorscale indicate the amount of
    % subjects that have positive or negative values at a given
    % time/electrode
    
%     betas.avg   = sum(sign(stimB(:,b,:,:)),4);
%     collim      =[-max(abs(betas.avg(:))) max(abs(betas.avg(:)))];
%     fh = plot_stat(cfg_eeg,result.clusters(b),betas,[],p.interval,collim,.05,sprintf('Beta:%s',p.coeff{b}),1);
%     doimage(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/' p.analysisname '/figures/' datestr(now,'ddmmyy') '/'],'png',[ datestr(now,'ddmmyy')  '_sign_glm_' model '__' p.coeff{b}],1)
%     
    % Individual plots of significant clusters, with the most
    % representative topgraphy and the complete timeseries, for all
    % subjects and the average across siginficant subjects and channels,
    % highlited when it is significant
    
%     if b>1
        for pn = {'pos','neg'}
            for cc = 1:length(result.clusters(b).([pn{1} 'clusters']))
                if result.clusters(b).([pn{1} 'clusters'])(cc).prob_abs<.05
                   auxlm = result.clusters(b).([pn{1} 'clusterslabelmat'])==cc;
                   chnls = find(sum(auxlm,2));
                   tts   = find(sum(auxlm));
                   [~,maxtts] = max(abs(sum(betas.avg(chnls,tts))));
                   [~,maxch] = max(abs(sum(betas.avg(chnls,tts),2)));
                   maxtts    =tts(maxtts);
                   maxch    =chnls(maxch);
                   fh =figure;
                    subplot(1,4,1)
                   plot_stat(cfg_eeg,result.clusters(b),betas,[],[result.clusters(b).time(maxtts) result.clusters(b).time(maxtts)+.01 .01],collim,.05,sprintf('Beta:%s',p.coeff{b}),0);
                   subplot(1,4,2:4)
                   hold on
                    
                   plot(result.clusters(b).time,squeeze(mean(stimB(chnls,b,:,:),1)),'Color',[.9 .9 .9])
                   hline(0,'k:')
                   vline(0,'k:')
                   plot(result.clusters(b).time,squeeze(mean(mean(stimB(chnls,b,:,:)),4)),'Color',[1 .8 .8],'Linewidth',3)
                   plot(result.clusters(b).time(tts),squeeze(mean(mean(stimB(chnls,b,tts,:)),4)),'Color',[1 0 0],'Linewidth',3)
                   plot(result.clusters(b).time(maxtts),squeeze(mean(mean(stimB(chnls,b,maxtts,:)),4)),'.k','MarkerSize',11)
                   text(result.clusters(b).time(tts(round(length(tts)/2))),...
                     squeeze(mean(mean(stimB(chnls,b,tts(round(length(tts)/2)),:)),4))+.3,...
                     sprintf('p-value: %1.4f',result.clusters(b).([pn{1} 'clusters'])(cc).prob_abs),'FontSize',12)
                   box off
                   set(gcf,'Position',[360 473 786 225],'Color',[1 1 1])
                   tightfig
                   doimage(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/' p.analysisname '/figures/' datestr(now,'ddmmyy') '/'],...
                       'png',[datestr(now,'ddmmyy') '_' model '__' p.coeff{b} '_' pn{1} 'cluster' num2str(cc) ],1)
    
                end
            end
        end
%     end
end