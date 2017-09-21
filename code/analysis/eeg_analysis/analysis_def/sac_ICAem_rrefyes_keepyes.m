p.subj                  = p.subj;
p.times                 = [1000 50];
% p.minamp              = 0;
% p.prev                = {-1,1,'origstart','>0'};
p.npermute              = 1;
p.data                  = 'sac';
p.rref                  = 'yes';
p.keep                  = 'no';
p.plot                  = 1;
p.analysis_type         = {'ICAem'};

% p.sac                 = 1;
p.bsl                   = [-1 -.8];
p.interval              = [-.7 .02 .01]; % [start end step]
p.colorlim              = [-10 10];

p.model                 = 1;
p.cov                   = 'eye_head';   
p.model_cov             = 'cat(2,covs.covariate_eye,covs.covariate_head,covs.covariate_cross)'; 
p.interact              = {[1 2];[1 3];[1 4];[2 3];[2 4];[3 4];[1 2 3];[1 3 4];[1 2 4];[2 3 4];[1 2 3 4]};
p.coeff                 = {'const','LR','eye','head','cross','LRxeye','LRxhead',...
    'LRxcross','eyexhead','eyexcross','headxcross','LRxeyexhead','LRxheadxcross',...
    'LRxeyexcross','eyexheadxcross','LRxeyexheadxcross'};

p.mirror                = [];
% p.fix_model_cov       = 'cat(2,covs.covariate_modinc,covs.covariate_moddec,covs.covariate_amp)';%'cat(2,covs.covariate_emp,covs.covariate_amp)';
% p.fix_model_inter     = [];
% p.coeff_fix           = {'const','LR','modinc','moddec','amp'};

p.analysisname        = [p.data '_' p.analysis_type{1} '_rref' p.rref '_cov_' p.cov];   

%p.model_inter         = [1 2;1 3]
% p.model_cov           =
% cat(2,covs.covariate_modinc,covs.covariate_moddec,covs.covariate_fixdur,covs.covariate_amp)
