% Time-series analysis locked to tactile stimulation
%%
% eeglab
clear
E275_params                                 % basic experimental parameters               % 
fmodel                      = 2;            % wich glm model
E275_models                                 % the models

%%
% subject configuration and data
stimB = [];
ssubj = 1;
for tk = p.subj
    tk
%  for tk = p.subj;
% tk = str2num(getenv('SGE_TASK_ID'));
    if ismac    
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),...
            'expfolder','/Users/jossando/trabajo/E275/'); % this is just to being able to do analysis at work and with my laptop
    else
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk));
    end
    
    filename                = sprintf('s%02d',tk);
    cfg_eeg                 = eeg_etParams_E275(cfg_eeg,...
                                            'filename',filename,...
                                            'EDFname',filename,...
                                            'event',[filename '.vmrk'],...
                                            'clean_name','final',...
                                            'analysisname','saclock');    % single experiment/session parameters 
   
    load([cfg_eeg.eyeanalysisfolder cfg_eeg.filename 'eye.mat'])            % eyedata               

    mkdir([cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/'])
%     mkdir([cfg_eeg.analysisfolder cfg_eeg.analysisname '/ERP/' cfg_eeg.sujid '/'])
      E275_base_trl_event_def_sac                                       % trial configuration  

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLM ANALYSIS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% p.npermute = 1;
p.analysis_typ = p.analysis_type{1}; 
% [modelos_stim]    = regmodelpermutef({cfg_eeg},p.analysis_type{1},{trls.left;trls.right},eval(p.model_cov),p.model_inter,p.bsl,p.rref,p.npermute,'effect',p.mirror);
[modelos_stim]    = regmodelpermutef({cfg_eeg},[],p);
allsac(ssubj) = sac;
stimB = cat(4,stimB,modelos_stim.B);
save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/ERP/subjmodels/ERPglm_' cfg_eeg.sujid '_'  p.analysisname],'modelos_stim','p','trls','cfg_eeg','sac');

%
%     % % plotting betas each subject  
%     % % stimlock
%     modelplot = modelos_stim;
%     for b=1:size(modelplot.B,2)
%         betas.avg       = squeeze(modelplot.B(:,b,:));
%         collim          =[-6*std(betas.avg(:)) 6*std(betas.avg(:))];
%         betas.time      = modelplot.time;
%         betas.dof       = 1;
%         betas.n         = sum(modelplot.n);
% 
%         fh = plot_stat(cfg_eeg,modelplot.TCFEstat(b),betas,[],p.interval,collim,.05,sprintf('Beta:%s',p.coeff{b}),1);
%         doimage(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/'],'png',[ datestr(now,'ddmmyy') cfg_eeg.sujid '_glm_stimlock_' p.coeff{b} '_' p.analysis_type{1}],1)
% 
%     end
end
%%
%2nd level analysis

load(cfg_eeg.chanfile)
% result = regmodel2ndstat(stimB,modelos_stim.time,elec,1000,'bootet','cluster');
result = regmodel2ndstat(stimB,modelos_stim.time,elec,2000,'signpermT','cluster');
save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/ERP/' datestr(now,'ddmmyy') '_ERPglm_' p.analysisname],'result','stimB','p','cfg_eeg','allsac');

%%
load(cfg_eeg.chanfile)
% p.interval = [-.63 .09 .01];
E275_glm_stim_betaplots
