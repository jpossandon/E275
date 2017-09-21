%%
clear
E275_params                                             % E275
subjectsCEM     = {'al','vb','pk','gs','jg','jm','hd'};   % CEM
load('/Users/jossando/trabajo/osna_database/alleyedatatouch.mat','data')                      % touch  
subjectsTouch   = unique(data.subject);

sge         = 1;
binsiz      = 20;
edges       = 0:binsiz:2000;
xticks      = [25 50 100 200 400 800 inf];
yticks      = [1 5 10 20 50 80 90 95 99]/100;
edges1      = -.5:.05:1.5;
edges2      = -.02:.0005:0;
edges1NT    = 0:.5:30;
edges2NT    = 0:binsiz:1000;
figure
set(gcf,'Position',[40 241 1186 464])
duos    = [];

for s = 1:length(p.subj)+length(subjectsTouch)+length(subjectsCEM)
    
    if s < length(p.subj)+length(subjectsTouch)+1
        % data from E275
        if s < length(p.subj)+1
            tk = p.subj(s);
            cfg_eeg 	= eeg_etParams_E275('sujid',sprintf('s%02d',tk),...
                            'expfolder','/Users/jossando/trabajo/E275/'); 

            filename    = sprintf('s%02d',tk);
            cfg_eeg     = eeg_etParams_E275(cfg_eeg,...
                                                    'filename',filename);    % single experiment/session parameters 

            load([cfg_eeg.eyeanalysisfolder cfg_eeg.filename 'eye.mat'])            % eyedata   
            eyedata.events.posinix = (eyedata.events.posinix-960)/45;             
            eyedata.events.posiniy = (eyedata.events.posiniy-540)/45;             % E275 screen 1920x1080 45 pix/deg  
            eyedata.events.posendx = (eyedata.events.posendx-960)/45; 
            eyedata.events.posendy = (eyedata.events.posendy-540)/45; 
        else
            eyedata.events = struct_select(data,{'subject'},{['==' num2str(subjectsTouch(s-length(p.subj)))]},2);
            eyedata.events.posinix = (eyedata.events.posinix-640)/45;             % Touch screen 1280x960 45 pix/deg
            eyedata.events.posiniy = (eyedata.events.posiniy-480)/45;             %
            eyedata.events.posendx = (eyedata.events.posendx-640)/45; 
            eyedata.events.posendy = (eyedata.events.posendy-480)/45; 
        end
        if isfield(eyedata.events,'blockstart')
        bstartindx = find(diff(eyedata.events.blockstart));
        else
            bstartindx = [];
        end
        indxremove = [find(diff(eyedata.events.trial)),find(diff(eyedata.events.trial))+1,find(eyedata.events.type==1 & eyedata.events.dur<50),...
                        find(eyedata.events.type==3),find(eyedata.events.type==3)-1,...
                        find(eyedata.events.type==3)-2,find(eyedata.events.type==3)+1,...
                        bstartindx(2:2:end),bstartindx(2:2:end)+1,...
                        find(eyedata.events.posendx<-15 | eyedata.events.posendx>15 | eyedata.events.posinix<-15 | eyedata.events.posinix>15),...
                        find(eyedata.events.posendy<-10 | eyedata.events.posendy>10 | eyedata.events.posiniy<-10 | eyedata.events.posiniy>10),...
                        find(eyedata.events.amp>4000 | (eyedata.events.amp==0 & eyedata.events.type==2))]; % remove events around trial change and around blinks
        indxremove = sort(unique([indxremove,[1 length(eyedata.events.dur)]]));
        indxremove(indxremove<1 | indxremove>length(eyedata.events.dur)) = [];
        eyedata.events = struct_elim(eyedata.events,indxremove,2,0);
        
    
    else
        % data from CEM
        cfg             = eeg_etParams_CEM('expfolder','/Users/jossando/trabajo/CEM/','sujid',subjectsCEM{s-length(p.subj)-length(subjectsTouch)});    % in rayuela
        cfg             = eeg_etParams_CEM(cfg,...
                                    'analysisname','freeviewing',...
                                    'task_id','fv');            
        load(cfg.masterfile)                 
        tasks = find(strcmp(exp.tasks_done.task_id,cfg.task_id));
        for e = tasks                     

              cfg             = eeg_etParams_CEM(cfg,...                                
                                                    'filename',exp.tasks_done.filename{e},...                                      
                                                    'EDFname',exp.tasks_done.filename{e},...
                                                    'event',[exp.tasks_done.filename{e} '.vmrk'],...
                                                    'clean_name','final');       % single experiment/session parameters 
            load([cfg.eyeanalysisfolder cfg.EDFname 'eyemore'])
            
            eyedata.events.posinix = (eyedata.events.posinix-640)/41;             % cem screen 1920x1080 41 pix/deg but images are only 1280x960 and this data is already corrected
            eyedata.events.posiniy = (eyedata.events.posiniy-480)/41; 
            eyedata.events.posendx = (eyedata.events.posendx-640)/41; 
            eyedata.events.posendy = (eyedata.events.posendy-480)/41; 
            indxremove = [find(diff(eyedata.events.trial)),find(diff(eyedata.events.trial))+1,find(eyedata.events.type==1 & eyedata.events.dur<50),...
                        find(eyedata.events.type==3),find(eyedata.events.type==3)-1,...
                        find(eyedata.events.type==3)-2,find(eyedata.events.type==3)+1,...
                        find(eyedata.events.posendx<-15 | eyedata.events.posendx>15 | eyedata.events.posinix<-15 | eyedata.events.posinix>15),...
                        find(eyedata.events.posendy<-10 | eyedata.events.posendy>10 | eyedata.events.posiniy<-10 | eyedata.events.posiniy>10),...
                        find(eyedata.events.amp>4000 | (eyedata.events.amp==0 & eyedata.events.type==2))]; % remove events around trial change and around blinks
            indxremove = sort(unique([indxremove,[1 length(eyedata.events.dur)]]));
            indxremove(indxremove<1 | indxremove>length(eyedata.events.dur)) = [];
            eyedata.events = struct_elim(eyedata.events,indxremove,2,0);
            struct_new = struct_up('eyedata.events',eyedata.events,2);
        end
        eyedata.events = struct_new;
        eyedata.events = struct_elim(eyedata.events,indxremove,2,0);
        
    end
    
    % fixation duration histogram
    auxdurs     = eyedata.events.dur(eyedata.events.type==1);
    [n]         = histc(auxdurs,edges);
    subplot(2,2,1), hold on
    plot(edges+binsiz/2,n/sum(n),'Color',[.7 .7 .7])
    
    % reciprocal plots are difficult to plot with an xaxis with reciprocal
    % latency (1/rt) that show as labels the actual latency in ms and that
    % increased from left to right. This is because the reciptrocal of
    % latency is bigger number with shorter RT, so naturally the shorter RT
    % are to the right of the plot and because of the change from teh
    % reciprocal number (1/rt) to the RT. So we need to artifially invert
    % the plot adding a minus to the x-axis
    % Similarly the probit yaxis is obtained by taking the standarized
    % inversed of the cumulative distribution
    % plot(-1./(edges+binsiz/2),norminv(cumsum((n)/sum(n)),0,1),'.-','Color',[.7 .7 .7])
    
    sauxdurs = sort(auxdurs);
    subplot(2,2,2),hold on
    % alternatively we can plot all fixations
    plot(-1./sauxdurs,norminv([1:length(sauxdurs)]./length(sauxdurs),0,1),'.','Color',[.7 .7 .7])
%   
    durs{sge}  = auxdurs;             % all data for average plot              
    
    % saccades main sequence (loglog pv/amplitude)
    auxamp     = eyedata.events.amp(eyedata.events.type==2);
    auxpv      = eyedata.events.pv(eyedata.events.type==2);
    X           = [ones(length(auxamp),1) log10(auxamp')];      % the regression matrix
    b(:,sge)    = X\log10(auxpv');                              % coefficients with the log peak velocity as dependent variable
    
    subplot(2,2,3, 'XScale', 'log', 'YScale', 'log'),hold on
    h           = plot(auxamp,auxpv,'.','Color',[.9 .9 .9],'MarkerSize',.5);
    uistack(h,'bottom')
    plot(linspace(.1,100,25),10.^([ones(25,1),log10(linspace(.1,100,25)')]*b(:,sge)),'Color',[1 .7 .7])
    axis([.1 100 10 1000])
    
    % data for fixationDur-saccadeAmpl analysis
    indxduo     = find(eyedata.events.start(2:end)-eyedata.events.end(1:end-1)<5 &...
        eyedata.events.type(2:end)==2 & eyedata.events.type(1:end-1)==1);
    indxduo(end)=[];
    auxdurs     = eyedata.events.dur(indxduo);
    auxamp      = eyedata.events.amp(indxduo+1);
    auxxyini   = [eyedata.events.posinix(indxduo+1);eyedata.events.posiniy(indxduo+1)];
    auxxyend   = [eyedata.events.posendx(indxduo+1);eyedata.events.posendy(indxduo+1)];
    duos        = [duos;[auxdurs',auxamp',auxxyini',auxxyend']];

    [counts(:,:,sge) indxs]    = bihist(log10(auxamp),-1./auxdurs,edges1,edges2,0);
    [countsNT(:,:,sge) indxsNT]  = bihist(auxamp,auxdurs,edges1NT,edges2NT,0);
    
%     if s > length(p.subj)+1
%         for e = 1:size(indxs,1)
%             for m = 1:size(indxs,2)
%             salMean(e,m,sge) =  mean(auxsal(indxs{e,m}));
%             empsalMean(e,m,sge) =  mean(auxemp(indxs{e,m}));
%             end
%         end
%     end
    sge         = sge+1;
end



auxdurs     = cell2mat(durs);
    [n]         = histc(auxdurs,edges);
    subplot(2,2,1), hold on
    plot(edges+binsiz/2,n/sum(n),'Color',[1 0 0],'LineWidth',2)
    xlim([0 1000])
    title('Fixation Dur')
   
    subplot(2,2,2),hold on
      %plot(-1./(edges+binsiz/2),norminv(cumsum((n)/sum(n)),0,1),'.-','Color',[1 0 0],'LineWidth',2,'MarkerSize',12)
    sauxdurs = sort(auxdurs);
    plot(-1./sauxdurs,norminv([1:length(sauxdurs)]./length(sauxdurs),0,1),'.-','Color',[1 0 0],'MarkerSize',12)
    set(gca,'XTick',-1./xticks,'XTickLabels',xticks,'YTick',norminv(yticks),'YTicklabels',yticks*100)
    axis([-.04 0 -2.327 2.327])
    grid
    title('Fixation Dur Reciprobit')
    
      subplot(2,2,3)
    mean(b,2)
    plot(linspace(.1,100,25),10.^([ones(25,1),log10(linspace(.1,100,25)')]* mean(b,2)),'k','LineWidth',2)
    axis([.1 100 10 1000])
    title('Saccades main sequence')
    
    subplot(2,2,4)
    %%
    figure(1),hold on, title('Avg movement vectors FROM position')
    figure(2),hold on, title('Avg movement vectors TO position')
    
    for x = -15:14
        for y = -10:9
            indxBin = duos(:,3)>x & duos(:,3)<x+1 & duos(:,4)>y & duos(:,4)<y+1;
            indxBinEnd = duos(:,5)>x & duos(:,5)<x+1 & duos(:,6)>y & duos(:,6)<y+1;
            
            meanV(x+16,y+11,:) = [mean(duos(indxBin,5)-duos(indxBin,3)),mean(duos(indxBin,6)-duos(indxBin,4))];
            auxamp = abs(complex(duos(indxBin,5)-duos(indxBin,3),duos(indxBin,6)-duos(indxBin,4)));
            meannormV(x+16,y+11,:) = [mean((duos(indxBin,5)-duos(indxBin,3))./auxamp),mean((duos(indxBin,6)-duos(indxBin,4))./auxamp)];
            medianDur(x+16,y+11) = median(duos(indxBin,1));
            medianAmp(x+16,y+11) = median(duos(indxBin,2));
            nnn(x+16,y+11,:) = sum(indxBin);
            figure(1)
            quiver(x+.5,y+.5,meanV(x+16,y+11,1),meanV(x+16,y+11,2),0,'Color',[nnn(x+16,y+11,:)/3700 0 0],'MaxHeadSize',.4)
            quiver(x+.5,y+.5,meannormV(x+16,y+11,1),meannormV(x+16,y+11,2),0,'b','MaxHeadSize',1)
        
            meanVEnd(x+16,y+11,:) = [mean(duos(indxBinEnd,5)-duos(indxBinEnd,3)),mean(duos(indxBinEnd,6)-duos(indxBinEnd,4))];
            auxampEnd = abs(complex(duos(indxBinEnd,5)-duos(indxBinEnd,3),duos(indxBinEnd,6)-duos(indxBinEnd,4)));
            meannormVEnd(x+16,y+11,:) = [mean((duos(indxBinEnd,5)-duos(indxBinEnd,3))./auxampEnd),mean((duos(indxBinEnd,6)-duos(indxBinEnd,4))./auxampEnd)];
            medianDurEnd(x+16,y+11) = median(duos(indxBinEnd,1));
            medianAmpEnd(x+16,y+11) = median(duos(indxBinEnd,2));
            nnnEnd(x+16,y+11,:) = sum(indxBinEnd);
            
            figure(2)
            quiver(x+.5,y+.5,meanVEnd(x+16,y+11,1),meanVEnd(x+16,y+11,2),0,'Color',[nnnEnd(x+16,y+11,:)/3700 0 0],'MaxHeadSize',.4)
            quiver(x+.5,y+.5,meannormVEnd(x+16,y+11,1),meannormVEnd(x+16,y+11,2),0,'b','MaxHeadSize',1)
        
        
        end
    end
%     figure,surf(medianDur)
%     figure,surf(medianAmp)

    %%
    % fixation duration / saccade amplitude plot
    
    % log amplitude vs inverse duration
    figure
    subplot(2,3,1)
    normCounts = sum(counts,3)./sum(counts(:));
    normCounts(normCounts<.00005) = NaN;
    auxpcolor                   = nan(size(normCounts)+1);
    auxpcolor(1:end-1,1:end-1)  = normCounts;
    cmap        = cmocean('ice');
    pcolor(edges2,edges1,log10(auxpcolor))
%     set(gca,'XTick',-1./[50 100 125 200 250 500 1000],'XTickLabels',[50 100 125 200 250 500 1000],...
%     'YTick',[-.5 -.3 0 .4 .7 1 1.2 1.4 1.5],'YTickLabels',round(10.^[-.5 -.3 0 .4 .7 1 1.2 1.4 1.5],1))
shading flat    
set(gca,'XTick',-.02:.002:0,'XTickLabels',round(-1./[-.02:.002:0]),...
     'YTick',-.4:.1:1.6,'YTickLabels',round(10.^[-.4:.1:1.6],1))
xlim([-.012 0 ])
axis square
%     colormap(cmap)
%     colorbar
    title('actual')
    
    % amplitude vs duration
    subplot(2,3,4)
    normCountsNT = sum(countsNT,3)./sum(countsNT(:));
    normCountsNT(normCounts<.00005) = NaN;
    auxpcolor                   = nan(size(normCountsNT)+1);
    auxpcolor(1:end-1,1:end-1)  = normCountsNT;
    cmap        = cmocean('ice');
    pcolor(edges2NT,edges1NT,log10(auxpcolor))
    shading flat    
    set(gca,'XTick',0:100:1000,...
     'YTick',0:5:30)
    axis square
    title('actual')
    
    % simulation data hipothesis no dependence
    for e = 1:100
        countsR(:,:,e) =bihist(log10(duos(randsample(size(duos,1),size(duos,1)),2)),-1./duos(:,1),edges1,edges2,0);
        countsR(:,:,e) =countsR(:,:,e)./sum(sum(countsR(:,:,e)));
        countsRNT(:,:,e) =bihist(duos(randsample(size(duos,1),size(duos,1)),2),duos(:,1),edges1NT,edges2NT,0);
        countsRNT(:,:,e) =countsRNT(:,:,e)./sum(sum(countsRNT(:,:,e)));
        e
    end
    
    
    subplot(2,3,2)
    normCountsR = mean(countsR,3);
    normCountsR(normCountsR<.00005) = NaN;
    auxpcolor                   = nan(size(normCountsR)+1);
    auxpcolor(1:end-1,1:end-1)  = normCountsR;
    cmap        = cmocean('ice');
    pcolor(edges2,edges1,log10(auxpcolor))
    shading flat    
    set(gca,'XTick',-.02:.002:0,'XTickLabels',round(-1./[-.02:.002:0]),...
     'YTick',-.4:.1:1.6,'YTickLabels',round(10.^[-.4:.1:1.6],1))
    xlim([-.012 0 ])
    axis square
    title('random')
    
    subplot(2,3,5)
    normCountsRNT = mean(countsRNT,3);
    normCountsRNT(normCountsR<.00005) = NaN;
    auxpcolor                   = nan(size(normCountsRNT)+1);
    auxpcolor(1:end-1,1:end-1)  = normCountsRNT;
    cmap        = cmocean('ice');
    pcolor(edges2NT,edges1NT,log10(auxpcolor))
    shading flat    
    set(gca,'XTick',0:100:1000,...
     'YTick',0:5:30)
    axis square
    title('random')
    
    subplot(2,3,3)
    normCountsdiff = normCounts-normCountsR;
    auxpcolor                   = nan(size(normCountsdiff)+1);
    auxpcolor(1:end-1,1:end-1)  = normCountsdiff;
    pcolor(edges2,edges1,auxpcolor)
    shading flat    
    set(gca,'XTick',-.02:.002:0,'XTickLabels',round(-1./[-.02:.002:0]),...
     'YTick',-.4:.1:1.6,'YTickLabels',round(10.^[-.4:.1:1.6],1))
    xlim([-.012 0 ])
    axis square
    title('random')
    caxis([-3e-4 3e-4])
    
    subplot(2,3,6)
    normCountsdiff = normCountsNT-normCountsRNT;
    auxpcolor                   = nan(size(normCountsdiff)+1);
    auxpcolor(1:end-1,1:end-1)  = normCountsdiff;
    pcolor(edges2NT,edges1NT,auxpcolor)
    shading flat  
    set(gca,'XTick',0:100:1000,...
     'YTick',0:5:30)
   
    axis square
    title('random')
    caxis([-3e-4 3e-4])