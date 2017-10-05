clear
E275_params                                 % basic experimental parameters               % 
p.analysisname  = 'spectra';
%%
% subject configuration and data
 s=1;
for tk = p.subj
    tk
%  for tk = p.subj;
% tk = str2num(getenv('SGE_TASK_ID'));
    if ismac    
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),...
            'expfolder','/Users/jossando/trabajo/E275/'); % this is just to being able to do analysis at work and with my laptop
    else
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),...
            'expfolder','/Users/jpo/trabajo/E275/');
    end
    
    filename                = sprintf('s%02d',tk);
    cfg_eeg                 = eeg_etParams_E275(cfg_eeg,...
                                            'filename',filename,...
                                            'EDFname',filename,...
                                            'event',[filename '.vmrk'],...
                                            'clean_name','final',...
                                            'analysisname',p.analysisname);    % single experiment/session parameters 
    load([cfg_eeg.eyeanalysisfolder cfg_eeg.filename 'eye.mat'])            % eyedata               
   
    % get relevant epochevents
    load([cfg_eeg.analysisfolder 'cleaning/' cfg_eeg.sujid '/' cfg_eeg.filename cfg_eeg.clean_name],'bad');
    [trl,events]  = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==96'},[0 8000]);
    epochevents             = [];
    epochevents.latency     = [events.time;events.time+4000];                       % fixation start, here the important thing is the ini pos
    epochevents.latency     = epochevents.latency(:)';
    rem = [];
    for e = 1:length(epochevents.latency)
        if any((epochevents.latency(e)>bad(:,1) & epochevents.latency(e)<bad(:,2)) |...
                (epochevents.latency(e)+4000>bad(:,1) & epochevents.latency(e)+4000<bad(:,2)))
            rem = [rem,e];
        end
    end
        epochevents.latency(rem)             = [];
    epochevents.type        = repmat({'seg'},1,length(epochevents.latency));
    [EEG,winrej] = getDataDeconv(cfg_eeg,epochevents,200);  
    EEGepoch = pop_epoch( EEG, {  'seg'  }, [0  2], 'newname', ' repochs', 'epochinfo', 'yes');
 
    
    for ch = 1:EEGepoch.nbchan
        [Pxx,F] = periodogram(squeeze(EEGepoch.data(ch,:,:)),[],400,EEG.srate,'power');
        spctM(ch,:) = mean(Pxx,2);
        spctSTD(ch,:) = std(Pxx,1,2);
        [~,locs] = findpeaks(double(spctM(ch,find(F>2 & F<40))),double(F(F>2 & F<40)),'MinPeakProminence',.05,'MinPeakDistance',3,'Annotate','extents');
        chpeaks{ch} = locs' ;
    end
    Pfreqs = unique(cell2mat(chpeaks));
    countsPfreqs = histc(cell2mat(chpeaks),Pfreqs);
    
    fh = figure,
    set(gcf,'Position',[10 350, 1300 600])
    subplot(2,3,1)
    plot(F,spctM'), hold on
    plot(F,mean(spctM),'r','LineWidth',3)
    ylim([0 10])
    
    subplot(2,3,2)
    loglog(F,spctM'), hold on
    loglog(F,mean(spctM),'r','LineWidth',3)
    ylim([.01 20])
    xlim([0 100])
    
    subplot(2,3,3)
    bar(Pfreqs,countsPfreqs)
    ylim([0 76])
    set(gca,'XTick',Pfreqs)
    
    load(cfg_eeg.chanlocs)
    load('cmapjp','cmap') 
    sbd = [3 8.5;8 16;15.5 30];
    for sb = 1:size(sbd,1)
        ix = find(Pfreqs>sbd(sb,1) & Pfreqs<sbd(sb,2) );
        
        if ~isempty(ix)
            [a,b] = max(countsPfreqs(ix));
            frtoplot = Pfreqs(ix(b));
            subplot(2,3,3+sb)    
            topoplot(spctM(:,F==frtoplot),chanlocs,'colormap',cmap,'headrad','rim','electrodes','on');
            colorbar
            title(sprintf('%2.1f Hz | %d peaks',frtoplot,a))
        end
    end
    mkdir(fullfile(cfg_eeg.analysisfolder,cfg_eeg.analysisname,'figures_subjects'))
     doimage(fh,fullfile(cfg_eeg.analysisfolder,cfg_eeg.analysisname,'figures_subjects'),'png',...
                [datestr(now,'ddmmyy') cfg_eeg.sujid],1)    
    spectraALL(s).id = tk;
    spectraALL(s).spctM = spctM;
    spectraALL(s).spctSTD = spctSTD;
    spectraALL(s).Pfreqs = Pfreqs;
    spectraALL(s).countsPfreqs = countsPfreqs;
    s = s+1
end
save(fullfile(cfg_eeg.analysisfolder,cfg_eeg.analysisname,'allspectra'),'spectraAll')