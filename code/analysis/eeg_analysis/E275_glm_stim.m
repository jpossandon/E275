% Time-series analysis locked to tactile stimulation
%%
% eeglab
clear all
E275_params                                 % basic experimental parameters               % 
fmodel                      = 1;            % wich glm model
E275_models                                 % the models

%%
% subject configuration and data
tk = 4
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
                                            'analysisname','stimlock');    % single experiment/session parameters 
   
    load([cfg_eeg.eyeanalysisfolder cfg_eeg.filename 'eye.mat'])            % eyedata               

    mkdir([cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/'])
      E275_base_trl_event_def_stim                                        % trial configuration  

         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLM ANALYSIS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[modelos_stim]    = regmodelpermutef({cfg_eeg},p.analysis_type{1},{trls.trl_left;trls.trl_right},eval(p.model_cov),p.model_inter,p.bsl,p.rref,p.npermute,'effect');
str_sav = 'save([cfg_eeg.analysisfolder cfg_eeg.analysisname ''/ERP/ERP_'' cfg_eeg.sujid ''_''  p.analysisname]';
str_sav = [str_sav ',''modelos_stim'''];
eval([str_sav ',''p'',''trls'',''cfg_eeg'');'])
   
%%
% plotting betas each subject  
% stimlock
modelplot = modelos_stim;
for b=1:size(modelplot.B,2)
    betas.avg       = squeeze(modelplot.B(:,b,:));
    collim          =[-6*std(betas.avg(:)) 6*std(betas.avg(:))];
    betas.time      = modelplot.time;
    betas.dof       = 1;
    betas.n         = sum(modelplot.n);
    
    fh = plot_stat(cfg_eeg,modelplot.TCFEstat(b),betas,[],p.interval,collim,.05,sprintf('Beta:%s',p.coeff{b}),1);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_glm_stimlock_' p.coeff{b} '_' p.analysis_type{1}],'fig')
    close(fh)
end

