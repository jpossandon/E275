% Time-series analysis locked to tactile stimulation
%%
% eeglab
clear
E275_params                                 % basic experimental parameters               % 
p.analysisname  = 'deconvTF';
%%
% subject configuration and data
 
if ismac 
run('/Users/jossando/trabajo/matlab/unfold/init_unfold.m')        
else
run('/Users/jpo/trabajo/matlab/unfold/init_unfold.m')   
end    
for tk = p.subj
    tk
%  for tk = p.subj;
% tk = str2num(getenv('SGE_TASK_ID'));
    if ismac    
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),...
            'expfolder','/Users/jossando/trabajo/E275/'); % this is just to being able to do analysis at work and with my laptop
    else
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),...
            'expfolder','/Users/jpo/trabajo/E275/');
    end
    
    filename                = sprintf('s%02d',tk);
    cfg_eeg                 = eeg_etParams_E275(cfg_eeg,...
                                            'filename',filename,...
                                            'EDFname',filename,...
                                            'event',[filename '.vmrk'],...
                                            'clean_name','final',...
                                            'analysisname',p.analysisname);    % single experiment/session parameters 
   
    % get relevant epochevents
    load([cfg_eeg.eyeanalysisfolder cfg_eeg.filename 'eye.mat'])            % eyedata               
    [trl,events]           = define_event(cfg_eeg,eyedata,2,{'&origstart','>0';'&origstart','<7000'},...
                                [800 100],{-1,1,'origstart','>0'}); 
    epochevents             = [];
    epochevents.latency     = events.start;                       % fixation start, here the important thing is the ini pos
    epochevents.type        = cell(1,length(events.start));
    epochevents.type(events.type==1) = repmat({'fix'},1,sum(events.type==1));
    epochevents.type(events.type==2) = repmat({'sac'},1,sum(events.type==2));

    epochevents.pxini       = (events.posinix-960)/45;            
    epochevents.pyini       = (events.posiniy-540)/45;     
    epochevents.pxend       = (events.posendx-960)/45;            
    epochevents.pyend       = (events.posendy-540)/45;
    epochevents.pxdiff      = epochevents.pxend-epochevents.pxini;  
    epochevents.pydiff      = epochevents.pyend-epochevents.pyini; 
    epochevents.side        = nan(1,length(events.start));    
    epochevents.cross       = nan(1,length(events.start));    
    
    
    [trl,events]  = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','>0'},[1500 1000]);
    events                  = struct_elim(events,find(~ismember(events.value,[1:6,96])),2,0);
    epochevents.latency     = [epochevents.latency,events.time];
    ETttype                 = cell(1,length(events.value));
    ETttype(events.value==96)   = repmat({'image'},1,sum(events.value==96));
    ETttype(events.value<96)    = repmat({'stim'},1,sum(events.value<96));
    epochevents.type            = [epochevents.type,ETttype];
    ETside                  = nan(1,length(events.value));
    ETside(ismember(events.value,[1 3 5])) = -1;
    ETside(ismember(events.value,[2 4 6])) = 1;
    epochevents.side        = [epochevents.side,ETside];
    ETcross                 = nan(1,length(events.value));
    ETcross(ismember(events.value,[1 2])) = -1;
    ETcross(ismember(events.value,[3:6])) = 1;
    epochevents.cross       = [epochevents.cross,ETcross];
    epochevents.pxini       = [epochevents.pxini,nan(1,length(events.value))];    
    epochevents.pyini       = [epochevents.pyini,nan(1,length(events.value))];       
    epochevents.pxend       = [epochevents.pxend,nan(1,length(events.value))];          
    epochevents.pyend       = [epochevents.pyend,nan(1,length(events.value))];  
    epochevents.pxdiff      = [epochevents.pxdiff,nan(1,length(events.value))];  
    epochevents.pydiff      = [epochevents.pydiff,nan(1,length(events.value))];  
  
    % getting the data in EEGlab format
    [EEG,winrej] = getDataDeconv(cfg_eeg,epochevents,100);  

     cfgDesign           = [];
    cfgDesign.eventtype = {'fix','sac','image','stim'};
    cfgDesign.formula   = {'y ~pxini*pyini','y~pxdiff*pydiff','y~1','y~ side*cross'};
    model               = 'Fxy_Sxdyd_IM_STsc';
 
    % this get each subject respective peak for somatosensory and visual,
    % and calculates a fractional bandwith of .4
    % If there is no peak it takes the group average
    load(fullfile(cfg_eeg.analysisfolder,'spectra','allspectra'),'spectra')
    sptk            = find([spectra.seg.id]==tk);
    freqbands       = {'alfaSS' 'alphaV'};
    if ~isempty(spectra.seg(sptk).fpstr.alpha)
        pkSS        = spectra.seg(sptk).fpstr.alpha;
    else
        auxspct     = [spectra.seg.fpstr];
        pkSS        = mean([auxspct.alpha]);
    end
    if ~isempty(spectra.bst(sptk).fpstr.alpha)
        pkV         = spectra.bst(sptk).fpstr.alpha;
    else
        auxspct     = [spectra.bst.fpstr];
        pkV         = mean([auxspct.alpha]);
    end
    fracBWSS        = pkSS*.25/2;
    fracBWV         = pkV*.25/2;
    bplim           = [pkSS-fracBWSS pkSS+fracBWSS;...
                       pkV-fracBWV pkV+fracBWV];
    filtPnts        = [500 500]; % check this
    for fb = 1:length(freqbands)
        [EEGaux,com]              = pop_eegfiltnew(EEG, bplim(fb,1), bplim(fb,2), filtPnts(fb), 0, [], 0);
        EEGaux.data         = abs(hilbert(EEGaux.data')');
        EEGaux              = dc_designmat(EEGaux,cfgDesign);
        cfgTexp             = [];
        cfgTexp.timelimits  = [-1,1];tic
        EEGaux              = dc_timeexpandDesignmat(EEGaux,cfgTexp);toc
        EEGaux              = dc_continuousArtifactExclude(EEGaux,struct('winrej',winrej,'zerodata',0));
        EEGaux              = dc_glmfit(EEGaux);
 
        unfold.(freqbands{fb})          = dc_beta2unfold(EEGaux);
        
        for nep = 1:length(unfold.(freqbands{fb}).epoch)
            if iscell(unfold.(freqbands{fb}).epoch(nep).event)
                unfold.(freqbands{fb}).epoch(nep).event = cell2mat(unfold.(freqbands{fb}).epoch(nep).event);
            end
        end
    
      % ploting beta averages
         mkdir(fullfile(cfg_eeg.analysisfolder,cfg_eeg.analysisname,model,'figures_subjects',cfg_eeg.sujid))

         B = unfold.(freqbands{fb}).beta;
         collim = [-.2 .2];
         p.coeff = strrep({unfold.(freqbands{fb}).epoch.name},':','_');
         p.coeff = strrep(p.coeff,'(','');
         p.coeff = strrep(p.coeff,')','');
         etype   = {unfold.(freqbands{fb}).epoch.event};
         for b = 1:size(B,3);
            betas.dof   = 1;
            betas.n     = 1;
            betas.avg   = permute(B(:,:,b),[1,3,2]);
            collim      = [-6*std(betas.avg(:)) 6*std(betas.avg(:))]; 

            betas.time      = unfold(1).(freqbands{fb}).times; 
            auxresult.time  =  unfold(1).(freqbands{fb}).times;
            fh = plot_stat(cfg_eeg,auxresult,betas,[],[-.64 .64 .02],collim,.05,sprintf('Beta: %s %s',strrep(p.coeff{b},'_',' | '),etype{b}),1);
                doimage(fh,fullfile(cfg_eeg.analysisfolder,cfg_eeg.analysisname,model,'figures_subjects',cfg_eeg.sujid),'png',...
                     [datestr(now,'ddmmyy') cfg_eeg.sujid '_'  etype{b} '_' p.coeff{b} '_' freqbands{fb}],1)
         end
        end
      mkdir(fullfile(cfg_eeg.analysisfolder,cfg_eeg.analysisname,model,'glm'))
      save(fullfile(cfg_eeg.analysisfolder,cfg_eeg.analysisname,model,'glm',[cfg_eeg.sujid,'_',model]),'unfold')
      clear unfold
end 
%%
% %2nd level analysis
clear
E275_params                                 % basic experimental parameters  
p.analysisname  = 'deconvTF';% 
 if ismac    
        cfg_eeg             = eeg_etParams_E275('expfolder','/Users/jossando/trabajo/E275/','analysisname', 'deconvTF'); % this is just to being able to do analysis at work and with my laptop
    else
        cfg_eeg             = eeg_etParams_E275('expfolder','/Users/jpo/trabajo/E275/','analysisname', 'deconvTF');
 end
 
 model               = 'Fxy_Sxdyd_IM_STsc';
% p.subj              = [1,2,4,5,6,7,9,12,13,14,15,16,17,19,20,22,24,25,27,28,29,30,32,34,35];
freqbands       = {'alfaSS' 'alphaV'};
for fb = 1:length(freqbands)
    stimB = [];
    for tk = p.subj
         cfg_eeg             = eeg_etParams_E275(cfg_eeg,'sujid',sprintf('s%02d',tk));
        load([cfg_eeg.analysisfolder cfg_eeg.analysisname '/' model '/glm/' cfg_eeg.sujid '_' model],'unfold')
        auxdata = permute(unfold.(freqbands{fb}).beta(:,:,:),[1,3,2]);
%         auxdata = auxdata-repmat(mean(auxdata(:,:,1:20),3),[1,1,length(unfold.(freqbands{fb}).times)]);
 if any(strfind(p.analysisname,'mirr'))
        mirindx         = mirrindex({unfold.(freqbands{fb}).chanlocs.labels},[cfg_eeg.expfolder '/channels/mirror_chans']); 
           stimB = cat(4,stimB,auxdata-auxdata(mirindx,:,:));
 else
        stimB = cat(4,stimB,auxdata);
 end
    end
    load(cfg_eeg.chanfile)
    result.(freqbands{fb}) = regmodel2ndstat(stimB,unfold.(freqbands{fb}).times,elec,1000,'signpermT','cluster');
    interval = [-.64 .64 .02];

    pathfig = fullfile(cfg_eeg.analysisfolder,p.analysisname,model,'figures',[datestr(now,'ddmmyy')]);
    coeffs  = strrep({unfold.(freqbands{fb}).epoch.name},':','XX');
    coeffs  = strrep(coeffs,'(','');
    coeffs  = strrep(coeffs,')','');
    coeffs = strcat({unfold(1).(freqbands{fb}).epoch.event}','_',coeffs','_',freqbands{fb});

    
    glm_betaplots(cfg_eeg,stimB,result.(freqbands{fb}),interval,pathfig,coeffs)

end
mkdir(fullfile(cfg_eeg.analysisfolder,p.analysisname ,model,'glm'))

save([cfg_eeg.analysisfolder p.analysisname filesep model '/glm/glmALL'],'result')

