
win.trial_minimum_length    = .6;
win.stim_min_latency = .005;
win.stim_lambda = 1.2603;
win.stim_dur = .0025;

allnevents=[];
alloccurtime=[];
for e=1:100
    tic
    occurtime = [];
    nevents = [];
    for t=1:384
        tstart = GetSecs;
        last_stim = GetSecs;
        rvals = win.stim_min_latency + exprnd(1./win.stim_lambda,1,100);
        stim_idx = 1;
        while GetSecs<tstart+win.trial_minimum_length
            if GetSecs>last_stim+rvals(stim_idx)
                stim = randsample(1:3,1);
                occurtime = [occurtime,GetSecs-tstart];
                WaitSecs(win.stim_dur);       
                last_stim = GetSecs;
                stim_idx = stim_idx+1; 
            end
        end
     nevents = [nevents,stim_idx-1];
    end
    allnevents = [allnevents;nevents];
    alloccurtime = [alloccurtime,occurtime]; 
    toc
end