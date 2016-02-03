%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% E275

trialdur    = 8;
halflife    = trialdur/3;
decay       = log(2)./halflife;         %lambda
mean_life   = 1/decay;
min_length  = .75;
display(sprintf('\nCalculating estimates for:\n\n  Trial duration : %4.2f s\n  Half-life      : %4.2f s\n  Lambda         : %4.2f\n  Mean interval  : %4.2f s',trialdur,halflife,decay,mean_life))


nsim        = 1000;
ntrials     = 390;
binwidth    = .5;
tbins       = 0:binwidth:trialdur;
display(sprintf('\nRunning %d simulations of %d trials each\n',nsim,ntrials))

 
nevents                     = zeros(1,nsim);        % number of events per sim
nostim                      = zeros(1,nsim);        % number of trials without stimulation
 intervals                   = zeros(1,nsim);        % times between trials
% intervals2                   = [];
ntimes                      = zeros(nsim,length(tbins));
for n =1:nsim
    times                   = [];                   % times of event occurence
    interv                  = [];                   
    for nT = 1:ntrials
        rvals               = min_length+(-1./decay .* log(rand([1 10])));
        localsum            = cumsum(rvals(1:end));
        if localsum(1)<trialdur
            nevents(1,n)    = nevents(1,n)+find(localsum<trialdur,1,'last');
            times           = [times,localsum(1:find(localsum<trialdur,1,'last'))];
%                 interv          = [interv,mean(rvals(1:find(localsum<trialdur,1,'last')))];      % we need to take the mean of each trial interval, otrhewise we are waiting them more than they should
%                interv          = [interv,rvals(1:find(localsum<trialdur,1,'last')+1)]; need to select also the interval that goes further of the length of the trial, otherwise we are sampling selectively short intervals
            interv  = [interv diff([0 localsum(1:find(localsum<trialdur,1,'last')) trialdur])];

        else
            nostim(1,n)     = nostim(1,n)+1;
%                  interv          = [interv,rvals(1)];      % sampling of the intervals that are longer than trial duration
                 interv          = [interv,trialdur];     % this is what would happen, but it will result in an stimate smaller than expectide time because sometime the new event would occur at a duration longer than trialdur
        end
    end
    ntimes(n,:)             = histc(times,tbins);
    intervals(n)            = mean(interv);
 end


figure
set(gcf,'Position',[160 15 982 690])
subplot(2,3,1)
hold on
plot(tbins(1:end-1)+binwidth/2,ntimes(:,1:end-1)./repmat(sum(ntimes(:,1:end-1),2),1,length(tbins)-1),'Color',[.7 .7 .7])
plot(tbins(1:end-1)+binwidth/2,mean(ntimes(:,1:end-1)./repmat(sum(ntimes(:,1:end-1),2),1,length(tbins)-1)),'LineWidth',2,'Color',[0 0 0])
title('Event occurence time')
xlabel('(t)')

subplot(2,3,2)
hist(nevents,50)
title('Total # stim')
xlabel('(# stimulations per sim)')


subplot(2,3,3)
hist(nostim,50)
title('# trials wo stim')
xlabel('(#/sim)')


subplot(2,3,4)
hist(intervals,50)
title('mean ISI per sim')
xlabel('ISI (s)')

subplot(2,3,5)
axis off
text(0,1,sprintf('# Simulations                   : %d',nsim),'Fontsize',12)
text(0,.9,sprintf('# Trials/sim                     : %d',ntrials),'Fontsize',12)
text(0,.8,sprintf('# Trials dur                      : %d sec',trialdur),'Fontsize',12)
text(0,.7,sprintf('Total viewing time          : %d min',ceil(ntrials*trialdur/60)),'Fontsize',12)
text(0,.6,sprintf('Half-life                            : %2.1f',halflife),'Fontsize',12)
text(0,.5,sprintf('Min t after start/stim         : %2.2f',min_length),'Fontsize',12)

subplot(2,3,6)
axis off
text(0,.9,sprintf('<# total events>              ~ %d',round(decay*trialdur*ntrials)),'Fontsize',12)
text(0,.8,sprintf('<# triasl wo events>        ~ %d (%4.1f%%)',round(ntrials/(2^(trialdur/halflife))),100/(2^(trialdur/halflife))) ,'Fontsize',12)
text(0,.7,sprintf('<time betw. events>        ~ %4.2f sec',halflife/log(2)),'Fontsize',12)

text(0,.5,sprintf('Mean # events                ~ %d',round(mean(nevents))),'Fontsize',12)
text(0,.4,sprintf('Mean # trials wo events  ~ %d (%4.1f%%)',round(mean(nostim)),round(mean(nostim))/ntrials*100),'Fontsize',12)
text(0,.3,sprintf('Mean time betw. events   ~ %4.2f sec',mean(intervals)),'Fontsize',12)

%%
% % what about the convergence of the time between event
samp = [];
for s = 1:100   % number samples per time
    for rep = 1:ntrials
        rvals                       = (-1./decay .* log(rand([1 s])));
        samp(s,rep)                 = mean(rvals);
    end
    s
end
figure
hold on
plot(1:s,mean(samp,2))
plot(1:s,mean(samp,2)+std(samp,1,2)./sqrt(rep),'--')
plot(1:s,mean(samp,2)-std(samp,1,2)./sqrt(rep),'--')

%%
% hazard(t)=first_failure(t)/no_failure(t)
% Flat hazard occurs when the probability of an event to occur is the same
% independently of the time is has happened since last event.
% hazard(t)=const (lambda)
% IN ORDER OF THIS TO WORK WELL AND NOT BEING BIASED IT NEED TO SAMPLE
% PROPERLY THE EXPONENTIAL DISTRIBUTION, the upper limit of the binning
% need to be several times the halflife
halflife            = 1;
decay               = log(2)./halflife;  

samples             = 500000;
bins                = 10000;
timelimit           = 30*halflife;
binwidth            = timelimit/bins;
rvals               = (-1./decay .* log(rand([1 samples])));
nbins               = 0:binwidth:timelimit;
n                   = histc(rvals,nbins);
pn                  = n(1:end-2)./(sum(n));
% 

figure
hold all
h(1)                = plot(nbins(1:end-2),pn);
h(2)                = plot(nbins(1:end-2),1-cumsum(pn));
h(3)                = plot(nbins(1:end-2),pn./binwidth./[1,(1-cumsum(pn(1:end-1)))]);
h(4)                = vline(halflife);
h(5)                = line([nbins(1) nbins(end-2)],[decay decay],'Color',[0 0 0]);
axis([0  timelimit -decay 2/decay])

legend(h,{'Failure','Survival','Hazard','Half-life','Lambda'})