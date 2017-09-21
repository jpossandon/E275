%%
clear
sname    = 'allsubjects_all_signpermT';
ver = 1;
late = 0;


path = '/Users/jossando/trabajo/E275/analysis/';

if ver ==1
    load([path 'model2nd_' sname],'result')
else
    load([path 'model2ndY_' sname],'result')
end
allb        = result.allb;
subjects    = result.subjects;
%     subjects = [result.subjects1,result.subjects2];
tiempos     = result.times;

labels = {'constant','Cross','Left','Right','CrossxL','CrossxR','PosCov'}

% CT = cbrewer('qual','Set1',8);
% colors = mat2cell([0 0 0;CT],ones(9,1),3)';
colors = [0 0 0; 226/255 31/255 31/255; 57/255 127/255 185/255; 16/255 128/255 64/255];

%%
% constant and cross factor
% change last value of jbfill for transparency changes when producing final
% figuere
figure, hold on
if ver ==1
 set(gcf,'Position',[560 441 130 200]) %horizontal
else
 set(gcf,'Position',[560 441 200 120]) % verical
end
jbfill(tiempos,[squeeze(mean(allb(2,:,:),2))+squeeze(std(allb(2,:,:),1,2))./sqrt(length(subjects))]',...
    [squeeze(mean(allb(2,:,:),2))-squeeze(std(allb(2,:,:),1,2))./sqrt(length(subjects))]',[1 .6 .2],[1 .45 0],1,.6);
hold on
signclus2 = sort([find(result.TFCEstat(2).negclusterslabelmat),find(result.TFCEstat(2).posclusterslabelmat)]);

if late==1
    jbfill(tiempos,[squeeze(mean(allb(1,:,:),2))+squeeze(std(allb(1,:,:),1,2))./sqrt(length(subjects))]',...
    [squeeze(mean(allb(1,:,:),2))-squeeze(std(allb(1,:,:),1,2))./sqrt(length(subjects))]',[.4 .4 .4],[.62 .62 .62],1,.6);

else
    jbfill(tiempos,[squeeze(mean(allb(1,:,:),2))+squeeze(std(allb(1,:,:),1,2))./sqrt(length(subjects))]',...
    [squeeze(mean(allb(1,:,:),2))-squeeze(std(allb(1,:,:),1,2))./sqrt(length(subjects))]',[.4 .4 .4],[.62 .62 .62],1,.6);
end
hold on
signclus1 = sort([find(result.TFCEstat(1).negclusterslabelmat),find(result.TFCEstat(1).posclusterslabelmat)]);

if late==1
h(1) = plot(tiempos,squeeze(mean(allb(1,:,:),2)),'LineWidth',1,'Color',[.4 .4 .4]);

else
h(1) = plot(tiempos,squeeze(mean(allb(1,:,:),2)),'LineWidth',1,'Color',[.4 .4 .4]);
end
h(2) = plot(tiempos,squeeze(mean(allb(2,:,:),2)),'LineWidth',1,'Color',[1 .6 .2]);

if ~isempty(signclus1)
h(1) = plot(tiempos(signclus1),squeeze(mean(allb(1,:,signclus1),2)),'Marker','.','LineStyle','none','LineWidth',7,'Color',[.4 .4 .4]);
end
if ~isempty(signclus2)
h(2) = plot(tiempos(signclus2),squeeze(mean(allb(2,:,signclus2),2)),'Marker','.','LineStyle','none','LineWidth',7,'Color',[1 .6 .2]);
end

line([0 tiempos(end)],[0 0],'LineStyle','--','Color',[0 0 0])
% legend(h,{'NoStim/NoCross (Const)','Cross'})
if ver ==1
view([90 90])
end
ylim([-45.6*2-3.64 45.6*2])
if late ==0
    xlim([-15 1500])
else
    xlim([-15 1500])
end

clear h
if ver ==1
    if late ==0
        set(gca,'Position',[0.13 0.11 0.6 0.815],'Layer','top','Fontsize',9,'YTick',-45.6*2:45.6:45.6*2,'yTickLabel',-2:1:2,'XTick',0:250:1500,'XTickLabel',{'0' '' '0.5' '' '1' '' '1.5'},'YaxisLocation','right','Xaxislocation','bottom')
    else
        set(gca,'Position',[0.13 0.11 0.6 0.815],'Layer','top','Fontsize',9,'YTick',-45.6*2:45.6:45.6*2,'yTickLabel',-2:1:2,'XTick',0:250:1500,'XTickLabel',{'0' '' '0.5' '' '1' '' '1.5'},'YaxisLocation','right','Xaxislocation','bottom')
    end
else
    set(gca,'Position',[0.11 0.13 0.815 0.6],'Fontsize',9,'Layer','top','YTick',-45.6*2:45.6:45.6*2,'yTickLabel',-2:1:2,'XTick',0:250:1500,'XTickLabel',{'0' '' '0.5' '' '1' '' '1.5'},'Xaxislocation','bottom')
end
% plot p-values
if ver ==1
    axes('position',[0.73 0.11 0.2 0.815])
else
    axes('position',[0.11 0.73 0.815 0.2])
end

data1 = result.pval(:,1,1);
data1(data1==0) = .0001;
plot(tiempos,log10(data1),'LineWidth',1,'Color',[0 0 0]);
hold on
box off
data2 = result.pval(:,1,2);
data2(data2==0) = .0001;

plot(tiempos,log10(data2),'LineWidth',1,'Color',[0.8 0.4 0]);
line([0 tiempos(end)],[log10(.05) log10(.05)],'LineStyle','--','Color',[0 0 0])
if ver ==1 
    view([-90 -90])
end
if late ==0
    xlim([-15 1500])
else
    xlim([-15 1500])
end
ylim([-4.1 0.1])
if ver ==1
    if late == 0
        set(gca,'Layer','top','Fontsize',9,'YTickLabel',[.0001,.001,.01,.1,1],'YTick',[-4,-3,-2,-1,0],'XTick',0:250:1500,'XTickLabel',{'' '' '' '' '' '' ''},'YaxisLocation','left','Xaxislocation','top')
    else
        set(gca,'Layer','top','Fontsize',9,'YTickLabel',[.0001,.001,.01,.1,1],'YTick',[-4,-3,-2,-1,0],'XTick',0:250:1500,'XTickLabel',{'' '' '' '' '' '' ''},'YaxisLocation','left','Xaxislocation','top')
    end
else
   
    set(gca,'Fontsize',9,'YTickLabel',[.0001,.01,.1,1],'YTick',[-4,-3,-2,-1,0],'XTick',0:250:1500,'XTickLabel',{'' '' '' '' '' '' ''},'YaxisLocation','right','Xaxislocation','top')
end





doimage(gcf,[path, 'eyedata/figures/'],'png',[datestr(now,'ddmmyy') 'nostim_cross_' result.name],1)


%%
% left and right (no bi anymore)
figure, hold on
if ver ==1
    set(gcf,'Position',[560 441 130 200]) %vertical
else
    set(gcf,'Position',[560 441 200 120]) % verical
end

jbfill(tiempos,[squeeze(mean(allb(3,:,:),2))+squeeze(std(allb(3,:,:),1,2))./sqrt(length(subjects))]',...
    [squeeze(mean(allb(3,:,:),2))-squeeze(std(allb(3,:,:),1,2))./sqrt(length(subjects))]',colors(2,:),colors(2,:)+.05,1,.6);
hold on

jbfill(tiempos,[squeeze(mean(allb(4,:,:),2))+squeeze(std(allb(4,:,:),1,2))./sqrt(length(subjects))]',...
    [squeeze(mean(allb(4,:,:),2))-squeeze(std(allb(4,:,:),1,2))./sqrt(length(subjects))]',colors(3,:),colors(3,:)+.05,1,.6);
hold on

h(1) = plot(tiempos,squeeze(mean(allb(3,:,:),2)),'LineWidth',1,'Color',colors(2,:));
h(2) = plot(tiempos,squeeze(mean(allb(4,:,:),2)),'LineWidth',1,'Color',colors(3,:));

signclus3 = sort([find(result.TFCEstat(3).negclusterslabelmat),find(result.TFCEstat(3).posclusterslabelmat)]);
if ~isempty(signclus3)
    h(1) = plot(tiempos(signclus3),squeeze(mean(allb(3,:,signclus3),2)),'Marker','.','LineStyle','none','LineWidth',7,'Color',colors(2,:));
end
signclus4 = sort([find(result.TFCEstat(4).negclusterslabelmat),find(result.TFCEstat(4).posclusterslabelmat)]);
if ~isempty(signclus4)
    h(2) = plot(tiempos(signclus4),squeeze(mean(allb(4,:,signclus4),2)),'Marker','.','LineStyle','none','LineWidth',7,'Color',colors(3,:));
end

line([0 tiempos(end)],[0 0],'LineStyle','--','Color',[0 0 0])
% box on
% legend(h,{'Left','Right','Bilateral'})
if ver ==1
    view([90 90])
end
ylim([-45.6*2-3.64 45.6*2])
if late ==0
    xlim([-15 1500])
else
    xlim([-15 1500])
end

clear h
if ver ==1
    if late ==0
        set(gca,'Position',[0.13 0.11 0.6 0.815],'Layer','top','Fontsize',9,'YTick',-45.6*2:45.6:45.6*2,'yTickLabel',-2:1:2,'XTick',0:250:1500,'XTickLabel',{'0' '' '0.5' '' '1' '' '1.5'},'YaxisLocation','right','Xaxislocation','bottom')
    else
        set(gca,'Position',[0.13 0.11 0.6 0.815],'Layer','top','Fontsize',9,'YTick',-45.6*2:45.6:45.6*2,'yTickLabel',-2:1:2,'XTick',0:250:1500,'XTickLabel',{'0' '' '0.5' '' '1' '' '1.5'},'YaxisLocation','right','Xaxislocation','bottom')
    end
else
    set(gca,'Position',[0.11 0.13 0.815 0.6],'Fontsize',9,'Layer','top','YTick',-45.6*2:45.6:45.6*2,'yTickLabel',-2:1:2,'XTick',0:250:1500,'XTickLabel',{'0' '' '0.5' '' '1' '' '1.5'},'Xaxislocation','bottom')
end
% plot p-values
if ver ==1
    axes('position',[0.73 0.11 0.2 0.815])
else
    axes('position',[0.11 0.73 0.815 0.2])
end
data1 = result.pval(:,1,3);
data1(data1==0) = .001;
plot(tiempos,log10(data1),'LineWidth',1,'Color',colors(2,:));
hold on
box off
data2 = result.pval(:,1,4);
data2(data2==0) = .0001;
plot(tiempos,log10(data2),'LineWidth',1,'Color',colors(3,:));

line([0 tiempos(end)],[log10(.05) log10(.05)],'LineStyle','--','Color',[0 0 0])
if ver ==1
    view([-90 -90])
end
if late ==0
    xlim([-15 1500])
else
    xlim([-15 1500])
end
ylim([-4.1 0.1])
if ver ==1
    if late == 0
        set(gca,'Layer','top','Fontsize',9,'YTickLabel',[.0001,.001,.01,.1,1],'YTick',[-4,-3,-2,-1,0],'XTick',0:250:1500,'XTickLabel',{'' '' '' '' '' '' ''},'YaxisLocation','left','Xaxislocation','top')
    else
        set(gca,'Layer','top','Fontsize',9,'YTickLabel',[.0001,.001,.01,.1,1],'YTick',[-4,-3,-2,-1,0],'XTick',0:250:1500,'XTickLabel',{'' '' '' '' '' '' ''},'YaxisLocation','left','Xaxislocation','top')
    end
else
    set(gca,'Fontsize',9,'YTickLabel',[.0001,.01,.1,1],'YTick',[-4,-3,-2,-1,0],'XTick',0:250:1500,'XTickLabel',{'' '' '' '' '' '' ''},'YaxisLocation','right','Xaxislocation','top')
end

doimage(gcf,[path, 'eyedata/figures/'],'png',[datestr(now,'ddmmyy') 'left_right_' result.name],1)

%%
% left right interaction with cross
figure, hold on
if ver ==1
    set(gcf,'Position',[560 441 130 200])
else
    set(gcf,'Position',[560 441 200 120]) % verical
end

    
% for e = 1:length(subjects)
%      plot(tiempos,squeeze(allb(6,:(e),:)),'LineWidth',1,'Color',[1 .8 .8]); %left condition in dummy coding
%      plot(tiempos,squeeze(allb(7,:(e),:)),'LineWidth',1,'Color',[0.8 0.8 1]); % right condition in dummy coding
%       plot(tiempos,squeeze(allb(8,:(e),:)),'LineWidth',1,'Color',[0.8 0.8 .89]); % bilateral condition in dummy coding
% end
jbfill(tiempos,[squeeze(mean(allb(5,:,:),2))+squeeze(std(allb(5,:,:),1,2))./sqrt(length(subjects))]',...
    [squeeze(mean(allb(5,:,:),2))-squeeze(std(allb(5,:,:),1,2))./sqrt(length(subjects))]',colors(2,:),colors(2,:)+.05,1,.6);
hold on
jbfill(tiempos,[squeeze(mean(allb(6,:,:),2))+squeeze(std(allb(6,:,:),1,2))./sqrt(length(subjects))]',...
    [squeeze(mean(allb(6,:,:),2))-squeeze(std(allb(6,:,:),1,2))./sqrt(length(subjects))]',colors(3,:),colors(3,:)+.05,1,.6);
hold on


h(1) = plot(tiempos,squeeze(mean(allb(5,:,:),2)),'LineWidth',1,'Color',colors(2,:));
h(2) = plot(tiempos,squeeze(mean(allb(6,:,:),2)),'LineWidth',1,'Color',colors(3,:));

signclus5 = sort([find(result.TFCEstat(5).negclusterslabelmat),find(result.TFCEstat(5).posclusterslabelmat)]);
if ~isempty(signclus5)
h(1) = plot(tiempos(signclus5),squeeze(mean(allb(5,:,signclus5),2)),'Marker','.','LineStyle','none','LineWidth',7,'Color',colors(2,:));
end
signclus6 = sort([find(result.TFCEstat(6).negclusterslabelmat),find(result.TFCEstat(6).posclusterslabelmat)]);
if ~isempty(signclus6)
h(2) = plot(tiempos(signclus6),squeeze(mean(allb(6,:,signclus6),2)),'Marker','.','LineStyle','none','LineWidth',7,'Color',colors(3,:));
end

line([0 tiempos(end)],[0 0],'LineStyle','--','Color',[0 0 0])
 view([90 90]) 
ylim([-45.6*2-3.64 45.6*2])
if late ==0
    xlim([-15 1500])
else
    xlim([-15 1500])
end

clear h
if ver ==1
    if late ==0
        set(gca,'Position',[0.13 0.11 0.6 0.815],'Layer','top','Fontsize',9,'YTick',-45.6*2:45.6:45.6*2,'yTickLabel',-2:1:2,'XTick',0:250:1500,'XTickLabel',{'0' '' '0.5' '' '1' '' '1.5'},'YaxisLocation','right','Xaxislocation','bottom')
    else
        set(gca,'Position',[0.13 0.11 0.6 0.815],'Layer','top','Fontsize',9,'YTick',-45.6*2:45.6:45.6*2,'yTickLabel',-2:1:2,'XTick',0:250:1500,'XTickLabel',{'0' '' '0.5' '' '1' '' '1.5'},'YaxisLocation','right','Xaxislocation','bottom')
    end
else
    set(gca,'Position',[0.11 0.13 0.815 0.6],'Fontsize',9,'Layer','top','YTick',-45.6*2:45.6:45.6*2,'yTickLabel',-2:1:2,'XTick',0:250:1500,'XTickLabel',{'0' '' '0.5' '' '1' '' '1.5'},'Xaxislocation','bottom')
end
% plot p-values
axes('position',[0.73 0.11 0.2 0.815])
data1 = result.pval(:,1,5);
data1(data1==0) = .001;
plot(tiempos,log10(data1),'LineWidth',1,'Color',colors(2,:));
hold on
box off
data2 = result.pval(:,1,6);
data2(data2==0) = .0001;
plot(tiempos,log10(data2),'LineWidth',1,'Color',colors(3,:));


line([0 tiempos(end)],[log10(.05) log10(.05)],'LineStyle','--','Color',[0 0 0])
view([-90 -90])
if late ==0
    xlim([-15 1500])
else
    xlim([-15 1500])
end
ylim([-4.1 0.1])
if ver ==1
    if late == 0
        set(gca,'Layer','top','Fontsize',9,'YTickLabel',[.0001,.001,.01,.1,1],'YTick',[-4,-3,-2,-1,0],'XTick',0:250:1500,'XTickLabel',{'' '' '' '' '' '' ''},'YaxisLocation','left','Xaxislocation','top')
    else
        set(gca,'Layer','top','Fontsize',9,'YTickLabel',[.0001,.001,.01,.1,1],'YTick',[-4,-3,-2,-1,0],'XTick',0:250:1500,'XTickLabel',{'' '' '' '' '' '' ''},'YaxisLocation','left','Xaxislocation','top')
    end
else
    set(gca,'Fontsize',9,'YTickLabel',[.001,.01,.1,1],'YTick',[-3,-2,-1,0],'XTick',0:500:3000,'XTickLabel',{'' '' '' '' '' '' ''},'YaxisLocation','right','Xaxislocation','top')
end


doimage(gcf,[path, 'eyedata/figures/'],'png',[datestr(now,'ddmmyy')  'left_right_cross' result.name],1)

%%
% starting position covariate
figure, hold on
set(gcf,'Position',[560 441 130 200])
% for e = 1:length(subjects)
%        plot(tiempos,squeeze(allb(9,subjects(e),:)),'LineWidth',1,'Color',[1 .89 .8]); % covariate
% end
hold on
jbfill(tiempos,[squeeze(mean(allb(7,:,:),2))+squeeze(std(allb(7,:,:),1,2))./sqrt(length(subjects))]',...
    [squeeze(mean(allb(7,:,:),2))-squeeze(std(allb(7,:,:),1,2))./sqrt(length(subjects))]',[.4 .4 .4],[.62 .62 .62],1,.6);
hold on
signclus7 = sort([find(result.TFCEstat(7).negclusterslabelmat),find(result.TFCEstat(7).posclusterslabelmat)]);

h(1) = plot(tiempos,squeeze(mean(allb(7,:,:),2)),'LineWidth',1,'Color',[.4 .4 .4]);
hold on
if ~isempty(signclus7)
h(1) = plot(tiempos(signclus7),squeeze(mean(allb(7,:,signclus7),2)),'Marker','.','LineStyle','none','LineWidth',7,'Color',[.4 .4 .4]);
end

line([0 tiempos(end)],[0 0],'LineStyle','--','Color',[0 0 0])
% legend(h,{'cova'})
view([90 90])
ylim([-1 1])
if late ==0
    xlim([-15 1500])
else
    xlim([-15 1500])
end

clear h
if ver ==1
    if late ==0
        set(gca,'Position',[0.13 0.11 0.6 0.815],'Layer','top','Fontsize',9,'YTick',-45.6*2:45.6:45.6*2,'yTickLabel',-2:1:2,'XTick',0:250:1500,'XTickLabel',{'0' '' '0.5' '' '1' '' '1.5'},'YaxisLocation','right','Xaxislocation','bottom')
    else
        set(gca,'Position',[0.13 0.11 0.6 0.815],'Layer','top','Fontsize',9,'YTick',-45.6*2:45.6:45.6*2,'yTickLabel',-2:1:2,'XTick',0:250:1500,'XTickLabel',{'0' '' '0.5' '' '1' '' '1.5'},'YaxisLocation','right','Xaxislocation','bottom')
    end
else
    set(gca,'Position',[0.11 0.13 0.815 0.6],'Fontsize',9,'Layer','top','YTick',-45.6*2:45.6:45.6*2,'yTickLabel',-2:1:2,'XTick',0:250:1500,'XTickLabel',{'0' '' '0.5' '' '1' '' '1.5'},'Xaxislocation','bottom')
end

% plot p-values
axes('position',[0.73 0.11 0.2 0.815])
data1 = result.pval(:,1,7);
data1(data1==0) = .0001;
plot(tiempos,log10(data1),'LineWidth',1,'Color',[0 0 0]);
hold on
box off

line([0 tiempos(end)],[log10(.05) log10(.05)],'LineStyle','--','Color',[.4 .4 .4])
view([-90 -90])
if late ==0
    xlim([-15 1500])
else
    xlim([-15 1500])
end
ylim([-4.1 0.1])
if ver ==1
    if late == 0
        set(gca,'Layer','top','Fontsize',9,'YTickLabel',[.0001,.001,.01,.1,1],'YTick',[-4,-3,-2,-1,0],'XTick',0:250:1500,'XTickLabel',{'' '' '' '' '' '' ''},'YaxisLocation','left','Xaxislocation','top')
    else
        set(gca,'Layer','top','Fontsize',9,'YTickLabel',[.0001,.001,.01,.1,1],'YTick',[-4,-3,-2,-1,0],'XTick',0:250:1500,'XTickLabel',{'' '' '' '' '' '' ''},'YaxisLocation','left','Xaxislocation','top')
    end
else
    set(gca,'Fontsize',9,'YTickLabel',[.001,.01,.1,1],'YTick',[-3,-2,-1,0],'XTick',0:500:3000,'XTickLabel',{'' '' '' '' '' '' ''},'YaxisLocation','right','Xaxislocation','top')
end

doimage(gcf,[path, 'eyedata/figures/'],'png',[datestr(now,'ddmmyy')  'poscov' result.name],1)


