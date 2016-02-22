E275_params
fmodel          = 1;
E275_models
tk=1
%  for tk = p.subj;
% tk = str2num(getenv('SGE_TASK_ID'));
    if ismac    
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),'expfolder','/Users/jossando/trabajo/E275/'); % this is just to being able to do analysis at work and with my laptop
    else
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk));
    end
    
    filename                = sprintf('s%02d',tk);
    cfg_eeg                 = eeg_etParams_E275(cfg_eeg,...
                                            'filename',filename,...
                                            'EDFname',filename,...
                                            'event',[filename '.vmrk'],...
                                            'clean_name','final',...
                                            'analysisname','stimlock');       % single experiment/session parameters 
   
%     load([cfg_eeg.analysisfolder 'behavioral/alleye.mat'])                         
%     eyedata.events = struct_select(eyedata.events,{'subjectindex'},{['==' num2str(tk)]},2);
    load([cfg_eeg.eyeanalysisfolder cfg_eeg.filename 'eye.mat'])                         

    mkdir([cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/'])
    E275_base_trl_event_def_stim
    
    %p.conds  = {'none','left-up','left-down','right-up','right-down','left','right','mod'};
    for e = 1:4%length(p.trls_stim)
        [ERPallstim(e)] = getERPsfromtrl({cfg_eeg},{trls.(p.trls_stim{e})},p.bsl,p.rref,p.analysis_type{1},p.keep);
        if p.plot
            fh = plot_topos(cfg_eeg,ERPallstim(e).(p.analysis_type{1}),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock ' p.trls_stim{e} ' / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
             saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_cond_' p.trls_stim{e}],'fig')
        end
    end
   
    if p.model
            [modelos_stim]    = regmodelpermutef({cfg_eeg},p.analysis_type{1},{trls.trl_left;trls.trl_right},eval(p.model_cov),p.model_inter,p.bsl,p.rref,p.npermute,'effect');
    end
    
    str_sav = 'save([cfg_eeg.analysisfolder cfg_eeg.analysisname ''/ERP/ERP_'' cfg_eeg.sujid ''_''  p.analysisname]';
  
        if p.model
            str_sav = [str_sav ',''ERPallstim'',''modelos_stim'''];
        else
            str_sav = [str_sav ',''ERPallstim'''];
        end
  
   eval([str_sav ',''p'',''trls'',''cfg_eeg'');'])
  
%%
% plotting betas each subject  
% stimlock
for b=1:size(modelos_stim.B,2)
    betas.avg       = squeeze(modelos_stim.B(:,b,:));
    collim          =[-6*std(betas.avg(:)) 6*std(betas.avg(:))];
    betas.time      = modelos_stim.time;
    betas.dof       = 1;
    betas.n         = sum(modelos_stim.n);

 fh = plot_stat(cfg_eeg,modelos_stim.TCFEstat(b),betas,[],[-.1 .5 .02],collim,.05,sprintf('Beta:%s',p.coeff{b}),1);
%      fh =  plot_topos(cfg,betas,[-1 0 .02],[],collim,['sac beta ' coeffi{b}]);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_betasac_' p.coeff{b} '_' p.analysis_type{1} '_cond_' p.trls_stim{e}],'fig')
%     close(fh)
end

