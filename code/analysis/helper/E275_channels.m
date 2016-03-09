% this is the channel structure for fieldtrip code
fid         = fopen('/Users/jossando/trabajo/E275/channels/easycapM1E275.txt');
tmp         = textscan(fid,'%s%s%s%s');
fclose(fid);

elec            = [];
elec.channum    = tmp{1}(2:end);
elec.label      = tmp{2}(2:end);
theta           = cellfun(@str2double, tmp{3}(2:end));
phi             = cellfun(@str2double, tmp{4}(2:end));
radians         = @(x) pi*x/180;
warning('assuming a head radius of 85 mm');
x               = 85*cos(radians(phi)).*sin(radians(theta));
y               = 85*sin(radians(theta)).*sin(radians(phi));
z               = 85*cos(radians(theta));
elec.unit       = 'mm';
elec.elecpos    = [x y z];
elec.chanpos    = [x y z];

figure
ft_plot_sens(elec,'label','label')
grid on 
rotate3d

cfg.elec            = elec;
cfg.method          = 'distance';
cfg.neighbourdist   = 52;
cfg.feedback        = 'yes';    
elec.neighbours     = ft_prepare_neighbours(cfg);

elec.channeighbstructmat = zeros(size(elec.neighbours))
for ch = 1:length(elec.channum)
    elec.channeighbstructmat(ch,:) = ismember(elec.label,elec.neighbours(ch).neighblabel)';
end
save('/Users/jossando/trabajo/E275/channels/eleceasycapM1E275','elec')

%% and for eeglab functions
  chanlocs = readlocs('/Users/jossando/trabajo/E275/channels/easycapM1E275.txt','filetype','custom',...
        'format',{'channum','labels','sph_theta_besa','sph_phi_besa'},'skiplines',1);
    save(['/Users/jossando/trabajo/E275/channels/chanlocseasycapM1E275'],'chanlocs')
    
%% mirror channels
tupu = {chanlocs.labels};
mirror_chans.labels = [tupu;{'Fpz','Fz','FCz','Cz','CPz','Pz','POz','Oz','Iz',...
    'F1','FC1','C1','CP1','P1',...
    'AF3','F3','FC3','C3','CP3','P3','PO3',...
    'F5','FC5','C5','CP5','P5',...
    'Fp1','AF7','F7','FT7','T7','TP7','P7','PO7','O1',...
    'F9','FT9','TP9','P9','PO9','O9',...
    'F2','FC2','C2','CP2','P2',...
    'AF4','F4','FC4','C4','CP4','P4','PO4',...
    'F6','FC6','C6','CP6','P6',...
    'Fp2','AF8','F8','FT8','T8','TP8','P8','PO8','O2',...
    'F10','FT10','TP10','P10','PO10','O10',...
    'VEOG3','VEOG2','VEOG1'}];
[LIA,LOCB] = ismember(mirror_chans.labels(1,:),mirror_chans.labels(2,:));
mirror_chans.indexs = LOCB;
save(['/Users/jossando/trabajo/E275/channels/mirror_chans'],'mirror_chans') 