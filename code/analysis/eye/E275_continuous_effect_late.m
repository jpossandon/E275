% analysis of effect of late stimulation in viewing behavior
%%
clear 
if ismac
    path = '/Users/jossando/trabajo/E275/';
else
    path = '/net/store/users/jossando/E275/';
end
load([path 'analysis/eyedata/alleyedata.mat'])
load([path 'analysis/eyedata/allsampledata.mat'])
eyedata.events          = data;
eyedata.events.angle    = data.angle*pi/180;
subjects                = unique(eyedata.events.subject);

%%
subjects = [1:4];
cross               = [0 0 0 1 1 1];  % (no cross-no stim / no cross/left / no cross/right / no cross/both 
stimside            = [0 1 2 0 3 4];  %    cross-no stim  /  cross/left   /  cross/right   / cross/both)
 saclat              = cell(length(subjects),8);
 fixlat              = cell(length(subjects),8);
 fixelap              = cell(length(subjects),8);
conds               = {'u_no','u_l','u_r','c_no','c_l','c_r'};
% clear auxdata
earlylatlimit       = [105 200]; 
for s = 1:length(subjects)
     display(sprintf('Processing subject %d',subjects(s)))
    
    subjsample          = struct_select(sample,{'subject'},{['==' num2str(subjects(s))]},2);    % data from the current subject s
    
    indxstim            = find(stim.subject==subjects(s) & stim.trial>10);                      % stimulation for subjects s and after first 10 test trials
    val                 = stim.value(indxstim);                             % respective values for trigger, time and trial
    rnval               = length(val);
    t                   = stim.time(indxstim);
    tr                  = stim.trial(indxstim);  
    
    % control values, we take them for trials without stimulation after
    % image apearance (~ half trials) at the same time that stimulation
    % ocurred in the other trials
    nostimtrl           = setdiff(11:400,tr);
    val                 = [val,zeros(1,rnval)];
    tr                  = [tr,randsample(nostimtrl,rnval,'true')];
    t                   = [t,randsample(t,rnval)];
        
    nreprog =1;                 % counter to separate trials in which the first saccade after stimulation ocurred after earlylatlimit
    for n = 1:length(t)
        
        crossaux                    = eyedata.events.block(find(eyedata.events.subject==subjects(s)  & eyedata.events.trial==tr(n),1,'first'));  % what is the crossing condition for this trial
        if isempty(crossaux)
            if val(n)<3
                crossaux            = 0;
            else
                crossaux            = 1;
            end
            sprintf('No data for trial %d subject %d',tr(n),subjects(s))
        end
            
        indxsac                     = find(eyedata.events.subject==subjects(s) & eyedata.events.trial==tr(n) & eyedata.events.type==2 & eyedata.events.start>t(n));  % the saccades for this specific subject, trial that ocurred after stimulation
        indxfix                     = find(eyedata.events.subject==subjects(s) & eyedata.events.trial==tr(n) & eyedata.events.type==1 & eyedata.events.start<t(n) & eyedata.events.end>t(n));  % the saccades for this specific subject, trial that ocurred after stimulation
        if ~isempty(indxsac)        % if there is a saccade
            auxlat                                          = eyedata.events.start(indxsac(1))-t(n); % latency from stimulation
            saclat{s,cross==crossaux & stimside == val(n)}  = [saclat{s,cross==crossaux & stimside == val(n)}; auxlat]; % get it for later
        end
          if ~isempty(indxfix)        % if there is a fixation
            auxlat                                          = eyedata.events.end(indxfix(1))-t(n); % latency from stimulation
            fixlat{s,cross==crossaux & stimside == val(n)}  = [fixlat{s,cross==crossaux & stimside == val(n)}; auxlat]; % get it for later
            auxlat                                          = t(n)-eyedata.events.start(indxfix(1)); % latency from stimulation
            fixelap{s,cross==crossaux & stimside == val(n)}  = [fixelap{s,cross==crossaux & stimside == val(n)}; auxlat]; % get it for later
        end
        timsample                   = subjsample.time>t(n) & subjsample.time<t(n)+1500;              % we look into 1 second after stimulation TODO: remove data that is after 5 sec ??
        timsamplebsl                = subjsample.time>t(n)-50 & subjsample.time<t(n);                % and compare to baseline
        
        aux                         = subjsample.pos(1,subjsample.trial==tr(n) & timsample);           % get respective x pos
        fix_pre_posx                    = -1920/2+round(nanmean(subjsample.pos(1,subjsample.trial==tr(n) & timsamplebsl)));
       
        if fix_pre_posx>5000 , fix_pre_posx = NaN;,end,    
        
        auxdata(n,1,1:750)          = NaN;                                                           % next three lines is to fill with NANs for trials with less data than 1 second
        auxdata(n,1,1:length(aux))  = aux;
        auxdata(n,1,auxdata(n,1,:)>1920 | auxdata(n,1,:)<0) = NaN;
        
        auxbsl                          = subjsample.pos(1,subjsample.trial==tr(n) & timsamplebsl);   % this is before stimulation so it is not necesarry to fill with NaNs
        auxbsl(auxbsl>1920 | auxbsl<0)  = NaN;
%         auxdata(n,1,:)                  = auxdata(n,1,:)-nanmean(auxbsl);                             % baseline correction
        auxdata(n,1,:)                  = auxdata(n,1,:);%-nanmean(auxbsl);                             % baseline correction
        
        
        if ~isempty(indxsac)            % data only for trials with saccades after stimulation and that occurred after earlylatlimit
            if auxlat>earlylatlimit(1) & auxlat<earlylatlimit(2)
                auxdata_reprog(nreprog,1,:)              = auxdata(n,1,:);
            end
        end
        
        datac(s).(conds{cross==crossaux & stimside==val(n)})(n,:)   = auxdata(n,1,1:499);
            
        % the next lines generete the dummy coding for
        % left,right,bilateral, against cros-nostim
        XY(n,1) = crossaux;
        if val(n)>0 && val(n)<3
            XY(n,val(n)+1) = 1;
        elseif val(n)>2 && val(n)<5   
            XY(n,val(n)-1) = 1;
        end
        XY(n,6) = fix_pre_posx;
        if ~isempty(indxsac)          % data only for trials with saccades after stimulation and that occurred after earlylatlimit
            if auxlat>earlylatlimit(1) & auxlat<earlylatlimit(2) 
                datac_reprog(s).(conds{cross==crossaux & stimside==val(n)})(nreprog,:)   = auxdata(n,1,1:499);   
            
                XY_reprog(nreprog,1) = crossaux;
                if val(n)>0 && val(n)<3
                    XY_reprog(nreprog,val(n)+1) = 1;
                elseif val(n)>2 && val(n)<5   
                    XY_reprog(nreprog,val(n)-1) = 1;
                end
                 XY_reprog(nreprog,6) = fix_pre_posx;
                nreprog = nreprog+1;
            end
        end
        % effect coding without comparison to no-stim
        if n<rnval+1
            if val(n)==1 | val(n)==3
                XY_eff(n,1) = -1;
            elseif val(n)==2 | val(n)==4
                XY_eff(n,1) = 1;
            end
            if crossaux
                XY_eff(n,2)     = 1;
            else
                XY_eff(n,2)     = -1;
            end
            XY_eff(n,4)     = fix_pre_posx;
        end
    end
        
    for st=1:length(conds)
        datac(s).(conds{st})            = nanmean(datac(s).(conds{st}));
        datac_reprog(s).(conds{st})     = nanmean(datac_reprog(s).(conds{st}));
    end
    XY(:,4) = XY(:,1).*XY(:,2);
    XY(:,5) = XY(:,1).*XY(:,3);
    XY_eff(:,3) = XY_eff(:,1).*XY_eff(:,2);
    
    XY_reprog(:,4) = XY_reprog(:,1).*XY_reprog(:,2);
    XY_reprog(:,5) = XY_reprog(:,1).*XY_reprog(:,3);
 
    elec.channeighbstructmat = 0;
    [datac(s).B,datac(s).Bt,datac(s).STATS,datac(s).T] = regntcfe(auxdata,XY,1,'dummy',elec,0);
    [datac_eff(s).B,datac_eff(s).Bt,datac_eff(s).STATS,datac_eff(s).T] = regntcfe(auxdata(1:rnval,:,:),XY_eff,1,'effect',elec,0);
    
    [datac_reprog(s).B,datac_reprog(s).Bt,datac_reprog(s).STATS,datac_reprog(s).T] = regntcfe(auxdata_reprog,XY_reprog,1,'dummy',elec,0);
    clear XY auxdata XY_reprog auxdata_reprog XY_eff
    save([path 'analysis/model_late'],'datac','datac_eff','saclat','fixlat','fixelap','datac_reprog','subjects')
end

%%
cmap = colormap('lines');
allb = squeeze([datac_eff.B]);
figure,
hold on
for e = 1:5
plot(allb(e:5:end,:)','Color',cmap(e,:))
h(e) = plot(median(allb(e:5:end,:))','Color',cmap(e,:),'LineWidt',3);
end
legend(h,{'constant','LR','Cross','LRxCross','PosCov'})
ylim([-200 200])
%%
%2nd level
% clear 
% if ismac
%     path = '/Users/jossando/trabajo/touch/analysis/';
% else
%     path = '/net/store/users/jossando/touch/analysis/';
% end
% 
% rpgroup  = {'all','reprog'};
% for rp = 1
%     if rp == 1
%         load([path 'model_late'],'datac','subjects')
%         allb        = reshape([datac.B],[9,57,750]);
%     elseif rp == 2
%         load([path 'model_late'],'datac_reprog','subjects')
%         allb        = reshape([datac_reprog.B],[9,57,750]);
%     end
%         allb(1,:,:) = allb(1,:,:)-640.*ones(ones,size(allb,2),size(allb,3)); %to test if baseline is different from midline
%     for g = 4%[1,4,5]
%         if g == 1
%             subjs = 1:57;  % 1 to 22 are the first group
%             sname    = 'allsubjects_late';
%         elseif g == 2
%             subjs = 1:22;  % 1 to 22 are the first group
%             sname    = 'firstgroup_late';
%         elseif g == 3
%             subjs = 23:40;  % 1 to 22 are the first group
%             sname    = 'secondgroup_late';
%         elseif g == 4
%             subjs = 1:47;  % 1 to 22 are the first group
%             sname    = 'allright_late';
%         elseif g == 5
%             subjs    = 48:57;  % 1 to 22 are the first group
%             sname       = 'allleft_late';   
%         elseif g == 6
%              subjs1  = 1:47;  % 1 to 22 are the first group
%              subjs2  = 48:57;  % 1 to 22 are the first group
%             
%             sname       = 'indep_late'; 
%         end
% 
%         tiempos                     = 1:2:1500;
%         data2nd(1,:,:,:)            = permute(allb(:,subjs,:),[1 3 2]);
%         
%         for methods = {'signpermT'}%'bootet','bootsym','boottrimsym','boottrimet'}
%             if g<6
%                 data2nd(1,:,:,:)            = permute(allb(:,subjs,:),[1 3 2]);
%                 elec.channeighbstructmat = 0;
%                 [result]                    = regmodel2ndstat(data2nd,tiempos,elec,10000,methods{:},'tfce');
%                 result.subjects             = subjects;
% 
%             else
%                 data2nd1(1,:,:,:)           = permute(allb(:,subjs1,:),[1 3 2]);
%                 data2nd2(1,:,:,:)           = permute(allb(:,subjs2,:),[1 3 2]);
% 
%                 elec.channeighbstructmat = 0;
%                 [result]                    = regmodel2ndstat_ind(data2nd1,data2nd2,tiempos,elec,1000,methods{:},'tfce');
% 
%                 result.subjects1             = subjects(subjs1);
%                 result.subjects2             = subjects(subjs2);  
%             end
%                 result.name                 = sname;
%                 result.times                = tiempos;
%                 result.subjects             = subjects(subjs);
% 
%                 result.allb                 = allb(:,subjs,:);
% 
%                 save([path 'model2nd_' sname '_' rpgroup{rp} '_' methods{:}],'result')
%                 clear data2nd
%                 
%        end
%     end
% end
% 