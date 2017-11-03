% Time-series analysis locked to tactile stimulation
%%
clear
E275_params                                 % basic experimental parameters               % 
fmodel                      = 2;            % wich glm model
E275_models                                 % the models

%%
% subject configuration and data
s=1;
for tk = p.subj

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
    mkdir([cfg_eeg.analysisfolder cfg_eeg.analysisname '/ERP/' cfg_eeg.sujid '/'])
    E275_base_trl_event_def_sac                                        % trial configuration  
%
% ERP topoplots for all four conditions 
    p.interval  = [-.635 .085 .01];
    p.colorlim  = [-3 3];
    for e = 1:length(p.trls_stim)
        [ERP.(p.trls_stim{e})] = getERPsfromtrl({cfg_eeg},{trls.(p.trls_stim{e})},p.bsl,p.rref,p.analysis_type{1},p.keep);
        fh = plot_topos(cfg_eeg,ERP.(p.trls_stim{e}).(p.analysis_type{1}),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' saclock ' p.trls_stim{e} ' / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
     
        doimage(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/'],...
            'tiff',[ cfg_eeg.sujid '_saclock_' p.analysis_type{1} '_' p.trls_stim{e}],1)
        nn.obs(s,e) = unique(ERP.(p.trls_stim{e}).(p.analysis_type{1}).dof);
        nn.exp(s,e) = size(trls.(p.trls_stim{e}),1);
      %          saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_' p.trls_stim{e}],'fig')
    end
    s = s+1;
%    
% difference plots
% clear diffdata
% cfgs            = [];
% cfgs.parameter  = 'avg';
% cfgs.operation  = 'subtract';
% 
% difflabels      = {'leftvsright','leftvsright_nostim','LUsacLvsleft_nostim','LCsacLvsleft_nostim'};
% compidx         = [1 2;3 4;5 3;9 3];
% p.colorlim      = [-5 5];
% 
% for e = 1:length(difflabels)
%     diffdata(e)         = ft_math(cfgs,ERPallstim(compidx(e,1)).(p.analysis_type{1}),ERPallstim(compidx(e,2)).(p.analysis_type{1}));
%     fh                  = plot_topos(cfg_eeg,diffdata(e),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' saclock ' difflabels{e} ' / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
%     saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_saclock_' p.analysis_type{1} '_' difflabels{e}],'fig')
% end
% [diffdata.name]           = difflabels{:};
% 
% %%
% % difference plot U vs C pooled hand by mirroring
% clear ERPallstim
% p.keep          = 'yes';
% for e = 1:4 %length(p.trls_stim)
%     [ERPallstim(e)] = getERPsfromtrl({cfg_eeg},{trls.(p.trls_stim{e})},p.bsl,p.rref,p.analysis_type{1},p.keep);
%     mirindx         = mirrindex(ERPallstim(1).(p.analysis_type{1}).label,[cfg_eeg.expfolder '/channels/mirror_chans']); 
%     if ismember(e,[1,2])
%         ERPallstim(e).(p.analysis_type{1}).trial = ERPallstim(e).(p.analysis_type{1}).trial(:,mirindx,:);
%     end
% end
% 
% difflabels      = {'Unc','Cross'};
% compidx         = [3 1;4 2];
% 
% 
% Unc.(p.analysis_type{1})   = ft_timelockanalysis([],ft_appenddata([],ERPallstim(3).(p.analysis_type{1}),ERPallstim(1).(p.analysis_type{1})));
% Cross.(p.analysis_type{1}) = ft_timelockanalysis([],ft_appenddata([],ERPallstim(4).(p.analysis_type{1}),ERPallstim(2).(p.analysis_type{1})));
% 
% p.colorlim      = [-10 10];
% fh              = plot_topos(cfg_eeg,Unc.(p.analysis_type{1}),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock Uncross (RU and LU mirror) / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
% saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_Uncross'],'fig')
% fh              = plot_topos(cfg_eeg,Cross.(p.analysis_type{1}),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock Cross (RC and LC mirror) / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
% saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_Cross'],'fig')
% 
% % U vs C
% UvsC          = ft_math(cfgs,Unc.(p.analysis_type{1}),Cross.(p.analysis_type{1}));
% p.colorlim      = [-5 5];
% fh            = plot_topos(cfg_eeg,UvsC,p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock U minus C / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
% saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_UvsC'],'fig')

 save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/ERP/' cfg_eeg.sujid '/ERP_' cfg_eeg.sujid '_saclock'],'ERP','p')
end

%%
% Grand averages
at                  = 1;
p.analysis_type     = {'ICAem'}; %'plain' / 'ICAe' / 'ICAm' / 'ICAem' 
cfgr                = [];
s=1
for tk = p.subj; % subject number
    if ismac    
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),'analysisname','saclock','expfolder','/Users/jossando/trabajo/E275/'); % this is just to being able to do analysis at work and with my laptop
    else
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),'analysisname','saclock');
    end
    load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/ERP/' cfg_eeg.sujid '/ERP_' cfg_eeg.sujid '_saclock'],'ERP','p')
    
    ERPall(s) = ERP;
    s=s+1;
end

fERP    = fields(ERPall);
for ff=1:length(fERP)
    str_GA = 'GA.(fERP{ff}) = ft_timelockgrandaverage([]'
    for ss = 1:length(ERPall)
        str_GA = [str_GA, ',ERPall(' num2str(ss) ').' fERP{ff} '.' p.analysis_type{1} ''];
    end
    str_GA = [str_GA,');'];
    eval(str_GA)
end

% difference 
cfgs            = [];
cfgs.parameter  = 'avg';
cfgs.operation  = 'subtract';
% 
difflabels      = {'LvsR','LUsacLvsLUsacR','RUsacLvsRUsacR'};
 compidx         = [1 2;3 4;5 6];
for e = 1:length(difflabels)
     GA.(difflabels{e})  = ft_math(cfgs,GA.(fERP{compidx(e,1)}),GA.(fERP{compidx(e,2)}));
 end
save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/ERP/GA'],'GA','p','nn')

%%
% GA FIGURE
fERP    = fields(GA);
p.interval  = [-.63 .09 .01];
p.colorlim  = [-2 2];
for ff=1:length(fERP)

    fh            = plot_topos(cfg_eeg,GA.(fERP{ff}),p.interval,p.bsl,p.colorlim,['all ' fERP{ff} ' '  p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
    doimage(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/GA/'],'tiff',['all_saclock_' p.analysis_type{1} '_' fERP{ff}],1)
% saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/GA/all_imlock_' p.analysis_type{1} '_' fERP{ff}],'fig')
% close(fh)
end

%%
% Multiplot figure

load(cfg_eeg.chanfile)
cfgp            = [];
cfgp.showlabels = 'no'; 
cfgp.fontsize   = 12; 
cfgp.elec       = elec;
cfgp.interactive    = 'yes';
cfgp.clim      = [-.6 .6];
figure,ft_multiplotER(cfgp,GA.RUsacL,GA.RUsacR,GA.RUsacLvsRUsacR)