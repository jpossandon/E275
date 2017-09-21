% Time-series analysis locked to tactile stimulation
%%
clear
E275_params                                 % basic experimental parameters               % 
fmodel                      = 1;            % wich glm model
E275_models                                 % the models

%%
% subject configuration and data
s=1;
for tk = p.subj
%  for tk = p.subj;
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
    mkdir([cfg_eeg.analysisfolder cfg_eeg.analysisname '/ERP/' cfg_eeg.sujid '/'])
    E275_base_trl_event_def_stim                                        % trial configuration  
%%
% ERP topoplots for all four conditions 
p.interval  = [-.09 .63 .01];
p.colorlim  = [-6 6];
for e = 1:4%length(p.trls_stim)
    [ERP.(p.trls_stim{e})] = getERPsfromtrl({cfg_eeg},{trls.(p.trls_stim{e})},p.bsl,p.rref,p.analysis_type{1},p.keep);
    fh = plot_topos(cfg_eeg,ERP.(p.trls_stim{e}).(p.analysis_type{1}),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock ' p.trls_stim{e} ' / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
    doimage(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/'],...
        'tiff',[ cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_' p.trls_stim{e}],1)
    nn.obs(s,e) = unique(ERP.(p.trls_stim{e}).(p.analysis_type{1}).dof);
    nn.exp(s,e) = size(trls.(p.trls_stim{e}),1);
    %          saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_' p.trls_stim{e}],'fig')
end
s = s+1;
%%    
% difference plots
% cfgs            = [];
% cfgs.parameter  = 'avg';
% cfgs.operation  = 'subtract';
% 
% difflabels      = {'LUvsLC','RUvsRC','LUvsRU','LCvsRC'};
% compidx         = [1 2;3 4;1 3;2 4];
% p.colorlim      = [-5 5];
% erpfield        = fields(ERP);
% for e = 1:length(difflabels)
%     ERP.(difflabels{e}).(p.analysis_type{1})         = ft_math(cfgs,ERP.(erpfield{compidx(e,1)}).(p.analysis_type{1}),ERP.(erpfield{compidx(e,2)}).(p.analysis_type{1}));
%      fh                  = plot_topos(cfg_eeg,ERP.(difflabels{e}).(p.analysis_type{1}),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock ' difflabels{e} ' / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
%      saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_' difflabels{e}],'fig')
% end
% [diffdata.name]           = difflabels{:};

%%
% difference plot U vs C pooled hand by mirroring
% clear ERPs
% p.keep          = 'yes';
% for e = 1:4 %length(p.trls_stim)
%     [ERPaux(e)] = getERPsfromtrl({cfg_eeg},{trls.(p.trls_stim{e})},p.bsl,p.rref,p.analysis_type{1},p.keep);
%     mirindx         = mirrindex(ERPaux(1).(p.analysis_type{1}).label,[cfg_eeg.expfolder '/channels/mirror_chans']); 
%     if ismember(e,[1,2])
%         ERPaux(e).(p.analysis_type{1}).trial = ERPaux(e).(p.analysis_type{1}).trial(:,mirindx,:);
%     end
% end
% 
% difflabels      = {'Unc','Cross'};
% compidx         = [3 1;4 2];
% 
% 
% ERP.Unc.(p.analysis_type{1})   = ft_timelockanalysis([],ft_appenddata([],ERPaux(3).(p.analysis_type{1}),ERPaux(1).(p.analysis_type{1})));
% ERP.Cross.(p.analysis_type{1}) = ft_timelockanalysis([],ft_appenddata([],ERPaux(4).(p.analysis_type{1}),ERPaux(2).(p.analysis_type{1})));
% ERP.Unc_half.(p.analysis_type{1}) = ERP.Unc.(p.analysis_type{1});
% ERP.Unc_half.(p.analysis_type{1}).avg = ERP.Unc.(p.analysis_type{1}).avg-ERP.Unc.(p.analysis_type{1}).avg(mirindx,:);
% ERP.Cross_half.(p.analysis_type{1}) = ERP.Cross.(p.analysis_type{1});
% ERP.Cross_half.(p.analysis_type{1}).avg = ERP.Cross.(p.analysis_type{1}).avg-ERP.Cross.(p.analysis_type{1}).avg(mirindx,:);
% 
% p.colorlim      = [-10 10];
% fh              = plot_topos(cfg_eeg,ERP.Unc.(p.analysis_type{1}),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock Uncross (RU and LU mirror) / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
% saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_Uncross'],'fig')
% fh              = plot_topos(cfg_eeg,ERP.Cross.(p.analysis_type{1}),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock Cross (RC and LC mirror) / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
% saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_Cross'],'fig')
% fh              = plot_topos(cfg_eeg,ERP.Unc_half.(p.analysis_type{1}),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock Uncross half (RU and LU mirror) / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
% saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_Uncross_half'],'fig')
% fh              = plot_topos(cfg_eeg,ERP.Cross_half.(p.analysis_type{1}),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock Cross half (RC and LC mirror) / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
% saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_Cross'],'fig')
% 
% % U vs C
% ERP.UvsC.(p.analysis_type{1}) = ft_math(cfgs,ERP.Unc.(p.analysis_type{1}),ERP.Cross.(p.analysis_type{1}));
% ERP.UvsC_half.(p.analysis_type{1}) = ft_math(cfgs,ERP.Unc_half.(p.analysis_type{1}),ERP.Cross_half.(p.analysis_type{1}));
% p.colorlim      = [-5 5];
% fh            = plot_topos(cfg_eeg,ERP.UvsC.(p.analysis_type{1}),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock U minus C / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
% saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_UvsC'],'fig')
% fh            = plot_topos(cfg_eeg,ERP.UvsC_half.(p.analysis_type{1}),p.interval,p.bsl,p.colorlim,[cfg_eeg.sujid ' imlock U minus C half / ' p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
% saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/' cfg_eeg.sujid '/' cfg_eeg.sujid '_imlock_' p.analysis_type{1} '_UvsC_half'],'fig')
% close all
 save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/ERP/' cfg_eeg.sujid '/ERP_' cfg_eeg.sujid '_stimlock'],'ERP','p')
end



%%
% Grand averages
at                  = 1;
p.analysis_type     = {'ICAem'}; %'plain' / 'ICAe' / 'ICAm' / 'ICAem' 
cfgr                = [];
s=1
for tk = p.subj; % subject number
    if ismac    
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),'analysisname','stimlock','expfolder','/Users/jossando/trabajo/E275/'); % this is just to being able to do analysis at work and with my laptop
    else
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),'analysisname','stimlock');
    end
    load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/ERP/' cfg_eeg.sujid '/ERP_' cfg_eeg.sujid '_stimlock'],'ERP','p')
    
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
difflabels      = {'LUvsLC','RUvsRC','LUvsRU','LCvsRC'};
 compidx         = [1 2;3 4;1 3;2 4];
for e = 1:length(fERP)
     GA.(difflabels{e})  = ft_math(cfgs,GA.(fERP{compidx(e,1)}),GA.(fERP{compidx(e,2)}));
 end
save([cfg_eeg.analysisfolder cfg_eeg.analysisname '/ERP/GA'],'GA','p','nn')
%%
% GA FIGURE
fERP    = fields(GA);
p.interval = [-.09 .63 .01];
p.colorlim = [-8 8];
for ff=1:length(fERP)
    if sum(strcmp(fERP{ff},{'LUvsLC','RUvsRC'}))
        p.colorlim = [-2 2];
    else
        p.colorlim = [-6 6];
    end
    fh            = plot_topos(cfg_eeg,GA.(fERP{ff}),p.interval,p.bsl,p.colorlim,['all ' fERP{ff} ' '  p.analysis_type{1} ' / bsl: ' sprintf('%2.2f to %2.2f /',p.bsl(1),p.bsl(2))]);
    doimage(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/GA/'],'tiff',['all_imlock_' p.analysis_type{1} '_' fERP{ff}],1)
% saveas(fh,[cfg_eeg.analysisfolder cfg_eeg.analysisname '/figures/GA/all_imlock_' p.analysis_type{1} '_' fERP{ff}],'fig')
% close(fh)
end

%%
% Multiplot figure

% load(cfg_eeg.chanfile)
% cfgp            = [];
% cfgp.showlabels = 'no'; 
% cfgp.fontsize   = 12; 
% cfgp.elec       = elec;
% cfgp.interactive    = 'yes';
% 
% ft_multiplotER(cfgp,GA.LU,GA.LC,GA.LUvsLC)