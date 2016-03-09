% Time-series analysis locked to tactile stimulation
%%
eeglab 
clear all
E275_params                                 % basic experimental parameters               % 
fmodel                      = 1;            % wich glm model
E275_models                                 % the models

%%
% subject configuration and data
tk = 4
%  for tk = p.subj;
%  tk = str2num(getenv('SGE_TASK_ID'));
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
% difference plot U vs C pooled hand by mirroring
clear ERPallstim
p.keep          = 'yes';
for e = 1:4 %length(p.trls_stim)
    [ERPallstim(e)] = getERPsfromtrl({cfg_eeg},{trls.(p.trls_stim{e})},p.bsl,p.rref,p.analysis_type{1},p.keep);
    mirindx         = mirrindex(ERPallstim(1).(p.analysis_type{1}).label,[cfg_eeg.expfolder '/channels/mirror_chans']); 
    if ismember(e,[1,2])
        ERPallstim(e).(p.analysis_type{1}).trial = ERPallstim(e).(p.analysis_type{1}).trial(:,mirindx,:);
    end
end

difflabels      = {'Unc','Cross'};
compidx         = [3 1;4 2];


Unc.(p.analysis_type{1})   = ft_appendtimelock([],ERPallstim(3).(p.analysis_type{1}),ERPallstim(1).(p.analysis_type{1}));
Cross.(p.analysis_type{1}) = ft_appendtimelock([],ERPallstim(4).(p.analysis_type{1}),ERPallstim(2).(p.analysis_type{1}));

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GLM ANALYSIS wit mirroring
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(cfg_eeg.chanfile)
p.analysisname = [p.analysisname '_mirror'];
clear modelos
Y = []; XY = [];
Y                   = Unc.(p.analysis_type{1}).trial;
Y                   = cat(1,Y,Cross.(p.analysis_type{1}).trial);
XY                  = [ones(size(Unc.(p.analysis_type{1}).trial,1),1);-1*ones(size(Cross.(p.analysis_type{1}).trial,1),1)];
for np = 1:p.npermute
    tic
    if np>1
        XY          = XY(randsample(size(XY,1),size(XY,1)));
    end
    [B,Bt,STATS,T] = regntcfe(Y,XY,np,'effect',elec,1);
    if np==1  % this is the correct grouping
        modelos.B            = B;
        modelos.Bt           = Bt;
        modelos.STATS        = STATS;
         modelos.TCFE         = T;
         modelos.n           = size(Y,1);
         modelos.time        = Unc.(p.analysis_type{1}).time;
    else
         for b = 1:size(modelos.Bt,2)
             modelos.MAXTCFEDIST(np-1,b) = max(max(abs(T(:,:,b))));
         end
    end
     toc
end
modelos_stim_mirr = sigclusthresh(modelos,elec,.05);
str_sav = 'save([cfg_eeg.analysisfolder cfg_eeg.analysisname ''/ERP/ERP_'' cfg_eeg.sujid ''_''  p.analysisname]';
str_sav = [str_sav ',''modelos_stim_mirr'''];
eval([str_sav ',''p'',''trls'',''cfg_eeg'');'])
  

  
%%
% plotting betas each subject  
% stimlock
modelplot = modelos_stim_mirr;
p.coeff = {'const','cross'};
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
