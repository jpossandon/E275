p.subj                  = p.subj;
p.times                 = [1000 1250];
p.npermute              = 1;
p.data                  = 'stimTFR';
p.rref                  = 'yes';
p.keep                  = 'no';
p.plot                  = 1;
p.analysis_type         = {'ICAem'};

p.interval              = [-.15 .6 .025]; % [start end step]
% p.colorlim              = [-10 10];

p.model                 = 1;
% p.cov                   = '';
% p.model_cov             = '[]';
p.cov                   = 'cross';   
p.model_cov             = 'cat(2,covs.covariate_cross)'; 
p.interact              = [1 2];
p.coeff                 = {'const','LR','Cross','LRxCross'};
p.mirror                = [];

p.analysisname        = [p.data '_' p.analysis_type{1} '_rref' p.rref '_cov_' p.cov];   

p.cfgTFR.channel            = 'all';	
p.cfgTFR.keeptrials         = 'yes';	                
% p.cfgTFR.method             = 'tfr';
% p.cfgTFR.width              = 7; 
p.cfgTFR.output             = 'pow';	
p.cfgTFR.foi                = 8:1:30;
% p.cfgTFR.toi                = (-600:10:800)/1000;
p.cfgTFR.pad                = 3;%2*sum(p.times)/1000;    
% p.bsl                       = [-.49 -.3];

p.cfgTFR.method             = 'mtmconvol';
p.cfgTFR.taper              = 'hanning';
p.cfgTFR.winsize            = 0.500;
p.cfgTFR.t_ftimwin          = p.cfgTFR.winsize*ones(1,length(p.cfgTFR.foi));
% p.cfgTFR.output             = 'fourier';	

p.cfgTFR.tapsmofrq          = ones(1,length(p.cfgTFR.foi));
p.cfgTFR.toi                = (-p.times(1)+p.cfgTFR.winsize*1000/2+10:10:-10+p.times(2)-p.cfgTFR.winsize*1000/2)/1000;	
p.bsl                       = [-(p.times(1)/1000)+p.cfgTFR.winsize/2+.01 -p.cfgTFR.winsize/2];
%