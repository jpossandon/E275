p.subj                  = p.subj;
p.times_imlock          = [500 600];
% p.minamp              = 0;
% p.prev                = {-1,1,'origstart','>0'};
p.npermute              = 5;
p.data                  = 'stim';
p.rref                  = 'yes';
p.keep                  = 'no';
p.plot                  = 1;
p.analysis_type         = {'ICAem'};

% p.sac                 = 1;
p.bsl                   = [-.2 0];
p.interval              = [-.15 .6 .025]; % [start end step]
p.colorlim              = [-10 10];

p.model                 = 1;
p.cov                   = '';
p.model_cov             = '[]';
p.cov                   = 'cross';   
p.model_cov             = 'cat(2,covs.covariate_cross)'; 
p.model_inter           = [1 2];
p.coeff                 = {'const','LR','Cross','LPxCross'};

% p.fix_model_cov       = 'cat(2,covs.covariate_modinc,covs.covariate_moddec,covs.covariate_amp)';%'cat(2,covs.covariate_emp,covs.covariate_amp)';
% p.fix_model_inter     = [];
% p.coeff_fix           = {'const','LR','modinc','moddec','amp'};

p.analysisname        = [p.data '_' p.analysis_type{1} '_rref' p.rref '_keep' p.keep '_cov_' p.cov];   

%p.model_inter         = [1 2;1 3]
% p.model_cov           =
% cat(2,covs.covariate_modinc,covs.covariate_moddec,covs.covariate_fixdur,covs.covariate_amp)
