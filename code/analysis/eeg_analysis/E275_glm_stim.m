% Time-series analysis locked to tactile stimulation
%%
E275_params                                 % basic experimental parameters               % 
fmodel                      = 1;            % wich glm model
E275_models                                 % the models

%%
% subject configuration and data
tk = 2
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
    
%%
% ERP topoplots for all four conditions 
    E275_base_trl_event_def_stim                                        % trial configuration
    
    for e = 1:4%length(p.trls_stim)
        [ERPallstim(e)] = getERPsfromtrl({cfg_eeg},{trls.(p.trls_stim{e})},p.bsl,p.rref,p.analysis_type{1},p.keep);
        if p.plot
            fh = plot_topos(cfg_eeg,ERPallstim(e).(p.analysis_type{1}),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock ' p.trls_stim{e} ' / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
             saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_' p.trls_stim{e}],'fig')
        end
    end
    
    % difference plot U vs C per hand
    %left
    LUvsLC          = ERPallstim(1).(p.analysis_type{1});
    LUvsLC.avg      = ERPallstim(1).(p.analysis_type{1}).avg-ERPallstim(2).(p.analysis_type{1}).avg;
    LUvsLC.dof      = LUvsLC.dof+ERPallstim(2).(p.analysis_type{1}).dof;
    fh              = plot_topos(cfg_eeg,LUvsLC,p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock LU minus LC / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_LUvsLC'],'fig')
    %right   
    RUvsRC          = ERPallstim(3).(p.analysis_type{1});
    RUvsRC.avg      = ERPallstim(3).(p.analysis_type{1}).avg-ERPallstim(4).(p.analysis_type{1}).avg;
    RUvsRC.dof      = RUvsRC.dof+ERPallstim(4).(p.analysis_type{1}).dof;
   
    fh              = plot_topos(cfg_eeg,RUvsRC,p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock RU minus RC / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_RUvsRC'],'fig')
  %%
    % difference plot U vs C pooled hand by mirroring
    clear ERPallstim
    p.keep          = 'yes';
    for e = 1:4%length(p.trls_stim)
        [ERPallstim(e)] = getERPsfromtrl({cfg_eeg},{trls.(p.trls_stim{e})},p.bsl,p.rref,p.analysis_type{1},p.keep);
    end
    mirindx         = mirrindex(ERPallstim(1).(p.analysis_type{1}).label,[cfg_eeg.expfolder '/channels/mirror_chans']); 
   
    Unc                                     = ERPallstim(3);
    Unc.(p.analysis_type{1}).trial          = cat(1,Unc.(p.analysis_type{1}).trial,ERPallstim(1).(p.analysis_type{1}).trial(:,mirindx,:));
    Unc.(p.analysis_type{1}).avg            = squeeze(mean(Unc.(p.analysis_type{1}).trial));
    Unc.(p.analysis_type{1}).dof            = Unc.(p.analysis_type{1}).dof+ERPallstim(1).(p.analysis_type{1}).dof(mirindx,:);
    
    
    Cross                                   = ERPallstim(4);
    Cross.(p.analysis_type{1}).trial        = cat(1,Cross.(p.analysis_type{1}).trial,ERPallstim(2).(p.analysis_type{1}).trial(:,mirindx,:));
    Cross.(p.analysis_type{1}).avg          = squeeze(mean(Cross.(p.analysis_type{1}).trial));
    Cross.(p.analysis_type{1}).dof          = Cross.(p.analysis_type{1}).dof+ERPallstim(2).(p.analysis_type{1}).dof(mirindx,:);
 
    
    fh          = plot_topos(cfg_eeg,Unc.(p.analysis_type{1}),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock Uncross (RU and LU mirror) / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_Uncross'],'fig')
    fh          = plot_topos(cfg_eeg,Cross.(p.analysis_type{1}),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock Uncross (RC and LC mirror) / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_Uncross'],'fig')
    
    %U vs C   
    UvsC          = Unc.(p.analysis_type{1});
    UvsC.avg      = UvsC.avg-Cross.(p.analysis_type{1}).avg;
    UvsC.dof      = UvsC.dof+Cross.(p.analysis_type{1}).dof;
    UvsC = rmfield(UvsC,'trial');
    fh             = plot_topos(cfg_eeg,UvsC,p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock U minus C / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_UvsC'],'fig')

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLM ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_glm_stimlock_' p.coeff{b} '_' p.analysis_type{1}],'fig')
%     close(fh)
end

