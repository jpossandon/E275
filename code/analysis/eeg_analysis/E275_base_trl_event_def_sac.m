clear trls sacpar
[trls.Left,events]            = define_event(cfg_eeg,eyedata,2,{'|angle','>135';'|angle','<-135';'&dur','>10';'dur','<100'},...
            p.times_saclock);
[trls.Right,events]            = define_event(cfg_eeg,eyedata,2,{'&angle','>-45';'&angle','<45';'&dur','>10';'dur','<100'},...
            p.times_saclock);
[trls.Left_nostim,events]            = define_event(cfg_eeg,eyedata,2,{'|angle','>135';'|angle','<-135';'&dur','>10';'dur','<100';'latestim','==0'},...
            p.times_saclock);
[trls.Right_nostim,events]            = define_event(cfg_eeg,eyedata,2,{'&angle','>-45';'&angle','<45';'&dur','>10';'dur','<100';'latestim','==0'},...
            p.times_saclock);
stimconds = {'LU','RU','LC','RC'};

for td=1:4
    [trlstim,events_stim]       = define_event(cfg_eeg,eyedata,'ETtrigger',{'value',sprintf('==%d',td)},p.times_saclock);   
    trlsacL                     = [];   trlsacR                     = [];
    trlsaclatL                  = [];   trlsaclatR                  = [];
    trlanglesL                  = [];   trlanglesR                  = [];
    for t = events_stim.time
        [trl,events]            = define_event(cfg_eeg,eyedata,2,{'&start',sprintf('>%d',t+100);'&start',sprintf('<%d',t+1500);'|angle','>135';'|angle','<-135';'&dur','>10';'dur','<100'},...
            p.times_saclock);
        if ~isempty(trl)
            trlsacL              = [trlsacL;trl];
            trlanglesL           = [trlanglesL,events.angle(1:1:end)];
            trlsaclatL           = [trlsaclatL,events.start(1:1:end)-t];
        end
        clear trl
        [trl,events]            = define_event(cfg_eeg,eyedata,2,{'&start',sprintf('>%d',t+100);'&start',sprintf('<%d',t+1500);'&angle','>-45';'&angle','<45';'&dur','>10';'dur','<100'},...
            p.times_saclock);
        if ~isempty(trl)
            trlsacR              = [trlsacR;trl];
            trlanglesR           = [trlanglesR,events.angle(1:1:end)];
            trlsaclatR           = [trlsaclatR,events.start(1:1:end)-t];
        end
        clear trl
    end
    for direc = {'L','R'}
        eval(['trls.' stimconds{td} 'sac' direc{:} '= trlsac' direc{:} ';'])
        eval(['sacpar.lat_' stimconds{td} 'sac' direc{:} ' = trlsaclat' direc{:} ';'])
        eval(['sacpar.ang_' stimconds{td} 'sac' direc{:} ' = trlangles' direc{:} ';'])
        end
end       

p.trls_stim                        = {'Left','Right','Left_nostim','Right_nostim','LUsacL','LUsacR','RUsacL','RUsacR','LCsacL','LCsacR','RCsacL','RCsacR'};

% covs.covariate_cross                = {{[-1*ones(1,size(trls.trlLU,1)),ones(1,size(trls.trlLC,1))]};{[-1*ones(1,size(trls.trlRU,1)),ones(1,size(trls.trlRC,1))]}};
   
