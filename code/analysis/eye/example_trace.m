% example figure

%%
if ismac
    path = '/Users/jossando/trabajo/touch/';
else
    path = '/net/store/users/jossando/touch/';
end
load([path 'data/alleyedata.mat'])
load([path 'data/allsampledata.mat'])
load([path 'data/subjectsinfo.mat'])
eyedata.events          = data;
eyedata.events.angle    = data.angle*pi/180;
subjects                = sdata.edfnumber;

clear data

%% image with one trace
suj = 4;

   
    subjsample      = struct_select(sample,{'subject'},{['==' num2str(suj)]},2);
    timsample       = subjsample.time>1 & subjsample.time<6000;
    
           [~,events]      = define_event([],eyedata,2,{'start','>0';'blockstart','==0';'posinix','>1280/2-138';...
                           'posinix','<1280/2+138';'trial','>10';'subject',['==' num2str(suj)]},...
                           [10 10]);


        auxtrl          = unique(events.trial);    
        
for tr = 164;
im = unique(events.image(events.trial==auxtrl(tr)));
stim = unique(events.stim(events.trial==auxtrl(tr)));

display(sprintf('Processing subject %d   trial %d  image %d   stim %d',suj,auxtrl(tr),im,stim))      
auxdata             = subjsample.pos(:,subjsample.trial==auxtrl(tr) & timsample);
auxdata(1,auxdata(1,:)>1280 | auxdata(1,:)<0) = NaN;
auxdata(2,auxdata(2,:)>960 | auxdata(2,:)<0) = NaN;
auxdataim = auxdata

figure
if im<256
imshow(imresize(imread(sprintf('%sStimuli/image_%d.bmp',path,im)),.5))
else            
   imshow(imresize(imread(sprintf('%sStimuli/image_%d.jpg',path,im)),.5))
end
hold on
auxdata = auxdata/2

% plot(auxdata(1,:),auxdata(2,:),'-','Color',[0 0 0],'LineWidth',3)
plot(auxdata(1,:),auxdata(2,:),'-','Color',[0 0 1])%,'LineWidth',2)
plot(auxdata(1,1:1500),auxdata(2,1:1500),'.','MarkerSize',6,'Color',[1 0 0])
plot(auxdata(1,1),auxdata(2,1),'s','Color',[1 0 0],'MarkerSize',12,'MarkerFaceColor',[0 0 1])

axis ij
end

%% horizontal trace from previous plot plus other horizontal traces
cmap = cbrewer('qual','Set1',30);
cmap(find(cmap<.8)) =cmap(find(cmap<.8))+.2 
cmap = cbrewer('qual','Set3',30);
figure,
line([0 3000],[640 640],'LineStyle','--','Color',[.7 .7 .7],'LineWidth',2)
hold on
a=1
for tr = randsample(1:200,20)
    auxdata             = subjsample.pos(:,subjsample.trial==auxtrl(tr) & timsample);
auxdata(1,auxdata(1,:)>1280 | auxdata(1,:)<0) = NaN;
bi = 1-rand(1)/2;
    plot(auxdata(1,1:1500),'LineWidth',1,'Color',cmap(a,:))
    plot(1500,auxdata(1,1500),'s','Color',cmap(a,:),'MarkerSize',10,'MarkerFaceColor',cmap(a,:))
    a=a+1;
end
plot(auxdataim(1,1:1500),'LineWidth',2,'Color',[1 0 0])
plot(1500,auxdataim(1,1500),'s','Color',[1 0 0],'MarkerSize',10,'MarkerFaceColor',[1 0 0])
    
axis([0 1500 0 1280])
set(gca,'XTick',0:1500:3000,'YTick',0:640:1280)
box off

%% subject betas

 load([path 'analysis/model2nd_allright_all_signpermT'],'result')
s = find(subjects==suj);

figure,
hold on
plot(1:1499,squeeze(result.allb(1,:,:)),'Linewidth',1,'Color',[1 .8 .8])
line([0 1500],[0 0],'LineStyle','--','Color',[.7 .7 .7],'LineWidth',2)
plot(1:1499,squeeze(result.allb(1,s,:)),'Linewidth',2,'Color',[1 0 0])
axis([0 1500 -320 320])
set(gca,'XTick',0:1500:3000,'YTick',-320:320:320)
box off

