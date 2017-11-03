%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% asking for subject number for file and other info to not have id problems
% TOCHECK: 
% - why is not transferring the files
% 
% later
clear all
display(sprintf('\n\n\n\n\n\nPlease check that screen resolution is set to 1280x960 and the screen borders are OK. \nIf screen resolution is changes matlab (and the terminal) need to be re-started.\n'))
exp_path         = '/home/experiment/experiments/touch_eeg/';
pathEDF         = [exp_path 'data/'];
s_n             = input('Subject number: ','s');
fnameEDF        = sprintf('Touch%03d.EDF',str2num(s_n));
if exist([pathEDF fnameEDF],'file')
    rp = input(sprintf('!Filename %s already exist, do you want to overwrite it (y/n)?',fnameEDF),'s');
    if ~(strcmpi(rp,'n') || strcmpi(rp,'no'))
        error('filename already exist')
    end
end
win.s_name             = input('Subject name (initials): ','s');
win.s_age              = input('Subject age: ','s');
win.s_hand             = input('Subject handedness for writing (l/r): ','s');
win.s_gender           = input('Subject gender (m/f): ','s');
setStr = sprintf('Subject %s\nAge %s\nHandedness %s\nGender %s\n',win.s_name,win.s_age,win.s_hand,win.s_gender); % setting summary
fprintf(setStr); % print relevant current settings, ask for confirmation

AssertOpenGL(); % check if Psychtoolbox is working (with OpenGL) TODO: is this needed?
win.DoDummyMode = false;

ClockRandSeed(); % this works ok
% assert(exist(BaseDir,'dir')==7, sprintf('"%s" does not exist!', BaseDir))

% init EyeLink in desired mode (already here for checking EDF file names)
[IsConnected IsDummy] = EyelinkInit(win.DoDummyMode);
assert(IsConnected==1, 'Failed to initialize EyeLink!')


% ListenChar(2) % disable key listening by MATLAB windows(CTRL+C overridable)
% initiate Psychtoolbox screen
prevVerbos = Screen('Preference','Verbosity', 2); % verbosity-1 (default 3)
prevVisDbg = Screen('Preference','VisualDebugLevel',3); %vdbg-2 (default 4)

load([exp_path 'touch_randomization.mat'])
s_rand = s_rand(str2num(s_n),:);

win.FontSZ                  = 20;
win.bkgcolor                = 127;
% TODO check this numbers
win.Vdst                    = 80;          % viewer's distance from screen [cm]
win.res                     = [1280 960]; % horizontal x vertical resolution [pixels]
win.wdth                    = 53;        % BENQ monitor Peters EEG&EyeTRackin lab
win.hght                    = 30;        % 
win.pixxdeg                 = 45;
win.center_thershold        = 3*win.pixxdeg;       % distance from the midline threshold for gaze contingent end of trial
win.trial_minimum_length    = 8;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tactile settings and setup
win.tact_freq = 200; % in Hz
% calculate from this the settings for the stimulators that are handed over
% to js_define_tactile_states function. cycle_time sets frequency in
% microseconds
win.cycle_time              = 1000/win.tact_freq*1000;
% intensity is specified with on_time. if stimulator is on for half of the
% cycle time, intensity is maximal
win.on_time = win.cycle_time-1;            % TODO: check how this work
win.latency_firststim       = .150;        % ??? Do we jitter this?
win.stim_dur                = .025;        % the vibrator takes some time to stop its motion so for around 50 ms we use 25 ms of stimulation time (ask Tobias for the exact latencies they have measured)
win.stim_min_latency        = .5;          % we need to check this again and decide between a uniform or exponential distribution, in case of uniform we need min and max latency, otherwise we need min latency and a "half-life" lambda
% win.stim_max_latency        = 3.5;
win.stim_lambda             = log(2)./3.75;         % we use an exponential distribution with a lambda of the time it takes to complete a trial,  this means than in half of the trial there will be an stimuli and half not, however having a stimuli in the trial does no prevent having a second one 

fprintf('\nopening serial port...');
device = '/dev/ttyS0';          % this is the serial port
obj = serial(device,'BaudRate', 115200,'Parity','none','StopBits',1,'FlowControl','none'); % and specs, this is D/P/S = 8/N/1 which it seems to be kind of standard
try                 % try to open the serial port if is nottouch_randomization.mat
    if strcmpi(obj.Status, 'closed')
        fopen(obj);
    end
catch
    error('MATLAB:serial:fwrite:openserialfailed', lasterr);
    fclose(obj);
end
fprintf('done');exp_path
fprintf('\nwriting to serial port...');
ok = define_tact_states(obj, win.on_time, win.cycle_time);      % here I am trying to do bilateral stimulation with only one code, do not know if possible, this needs to be done once to setup the stimulator to a given code for the different stimulation channels and stimulation frequency
if ok ~= 1
    error('\n failed writing stimulus codes to serial port!\n');
end
fprintf('done');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% open and set a screen
win.whichScreen = min(Screen('Screens'));
[win.hndl win.rect] = Screen('OpenWindow',win.whichScreen,win.bkgcolor);
% if win.rect(3)~=1280 || win.rect(4)~=960
%     sca
%     error('Screen resolution must be 1280x960')
% end
[win.cntr(1) win.cntr(2)] = WindowCenter(win.hndl);
Screen('BlendFunction',win.hndl, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);% enable alpha blending for smooth drawing
HideCursor(win.hndl);
Screen('TextSize', win.hndl, win.FontSZ);
KbName('UnifyKeyNames'); % recommended, called again in EyelinkInitDefaults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% eye-tracker setup, instructions and calibration stuff
[win.el win.elcmds] = setup_eyetracker(win, 1); % (re)do verbose setup

% instructions
DrawFormattedText(win.hndl, 'Die Funktionsfähigkeit der Geräte muss überprüft werden\n Leertaste zum Fortfahren..','center','center',255,55);   % TODO: we need this instructions in german
Screen('Flip', win.hndl);
waitForKB_linux({'space'});

OpenError = Eyelink('OpenFile', fnameEDF);
if OpenError, error('EyeLink OpenFile failed (Error: %d)!', OpenError), end
Eyelink('Command', sprintf('add_file_preamble_text ''%s''', setStr));     % this adds the information about subject to the end of the header, TODO: check if adds everything or only the first line    
wrect = Screen('Rect', win.hndl); % write resolution to EDF file
Eyelink('Message','DISPLAY_COORDS %d %d %d %d', 0, 0, wrect(1), wrect(2));

% Calibrate the eye tracker (and tell the experimenter)
 ListenChar(2) % disable MATLAB windows' keyboard listen (no unwanted edits)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now we test if the side of stimulators are correct
% ALWAYS: left-hand number 1 and right-hand number 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DrawFormattedText(win.hndl, 'Now we check that the tactile stimulators are correctly placed and work ... \nPress space to proceed','center','center',255,55);
% Screen('Flip', win.hndl);
% waitForKB_linux({'space'});
% 
% DrawFormattedText(win.hndl, 'Testing stimulator 1 (three times), ...\nPress space when finished','center','center',255,55);
% Screen('Flip', win.hndl);
%     WaitSecs(3); 
% for e=1:3
%     WaitSecs(1+rand(1));      
%     Eyelink('command', '!*write_ioport 0x378 1');                    % start stimulation by sending a signal through the parallel port (a number that was set by js_E174_define_tact_states)
%     WaitSecs(win.stim_dur);       
%     Eyelink('command', '!*write_ioport 0x378 10');    % stop stimulation
%        
% end
% waitForKB_linux({'space'});
% 
% DrawFormattedText(win.hndl, 'Testing stimulator 2 (three times), ...\nPress space when finished','center','center',255,55);
% Screen('Flip', win.hndl);
%     WaitSecs(3);
% for e=1:3
%     WaitSecs(1+rand(1));      
%     Eyelink('command', '!*write_ioport 0x378 2');                    % start stimulation by sending a signal through the parallel port (a number that was set by js_E174_define_tact_states)
%     WaitSecs(win.stim_dur);       
%     Eyelink('command', '!*write_ioport 0x378 10');    % stop stimulation
% end
% waitForKB_linux({'space'});
% 
% DrawFormattedText(win.exp_pathhndl, 'Testing both stimulator together (three times), ...\nPress space when finished','center','center',255,55);
% Screen('Flip', win.hndl);
%     WaitSecs(3);
% for e=1:3
%     WaitSecs(1+rand(1));      
%     Eyelink('command', '!*write_ioport 0x378 3');                    % start stimulation by sending a signal through the parallel port (a number that was set by js_E174_define_tact_states)
%     WaitSecs(win.stim_dur);       
%     Eyelink('command', '!*write_ioport 0x378 10');    % stop stimulation
% end
% waitForKB_linux({'space'});

DrawFormattedText(win.hndl, 'Stimulatoren werden auf den Handrücken besfestigt ...\n Leertaste drücken','center','center',255,55);
Screen('Flip', win.hndl);
waitForKB_linux({'space'});
DrawFormattedText(win.hndl, 'Der linke Stimulator wird getestet (vibriert drei mal), ...\n danach Leertaste drücken','center','center',255,55);
Screen('Flip', win.hndl);
    WaitSecs(3);
for e=1:3
    WaitSecs(1+rand(1));      
    Eyelink('command', '!*write_ioport 0x378 1');                    % start stimulation by sending a signal through the parallel port (a number that was set by js_E174_define_tact_states)
    WaitSecs(win.stim_dur);       
    Eyelink('command', '!*write_ioport 0x378 10');    % stop stimulation
end
waitForKB_linux({'space'});

DrawFormattedText(win.hndl, 'Der rechte Stimulator wird getestet (vibriert drei mal), ...\n danach Leertaste drücken','center','center',255,55);
Screen('Flip', win.hndl);
    WaitSecs(3);
for e=1:3
    WaitSecs(1+rand(1));      
    Eyelink('command', '!*write_ioport 0x378 2');               % start stimulation by sending a signal through the parallel port (a number that was set by js_E174_define_tact_states)
    WaitSecs(win.stim_dur);       
    Eyelink('command', '!*write_ioport 0x378 10');    % stop stimulation
end
waitForKB_linux({'space'});

DrawFormattedText(win.hndl, 'Beide Stimulatoren vibrieren gleichzeitig (drei mal), ...\n danach Leertaste drücken','center','center',255,55);
Screen('Flip', win.hndl);
    WaitSecs(3);
for e=1:3
    WaitSecs(1+rand(1));      
    Eyelink('command', '!*write_ioport 0x378 3');                    % start stimulation by sending a signal through the parallel port (a number that was set by js_E174_define_tact_states)
    WaitSecs(win.stim_dur);       
    Eyelink('command', '!*write_ioport 0x378 10');    % stop stimulation
end
waitForKB_linux({'space'});

fprintf('\nTest ready!');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calibration + validation/home_local/tracking/experiments/touch and ready to start
EyelinkDoTrackerSetup(win.el);  % calibration/validation (keyboard control)
% define reference eye for "realtime tests" such as controlfix()
 Eyelink('WaitForModeReady', 500);

% drift correction dot
[image,map,alpha] = imread([exp_path 'stimuli/blackongrt.png']);
% image(:,:,4) = alpha;
fixIndex=Screen('MakeTexture', win.hndl, image);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the actual task!
b=0;        % block flag
nTrials = length(s_rand);
for nT = 1:nTrials
  
    if s_rand(nT).image<256
        image = imread(sprintf('%sstimuli/image_%01d.bmp',exp_path,s_rand(nT).image));      % load the image for next trial
    else
        image = imread(sprintf('%sstimuli/image_%01d.jpg',exp_path,s_rand(nT).image));      % load the image for next trial
    end
    if s_rand(nT).mirror ==1
        image(:,:,1) = fliplr(image(:,:,1));
        image(:,:,2) = fliplr(image(:,:,2));
        image(:,:,3) = fliplr(image(:,:,3));
    end
    postextureIndex=Screen('MakeTexture', win.hndl, image);
    
    % if it is a trial that starts a block     
    if s_rand(nT).block_start == 1   
        if nT ==1 && s_rand(nT).block == 0          % uncrossed
          draw_instructions_and_wait('Beginn des Experiments \n Test Block \n Die Hände bitte parallel positionieren (parallel). \n Zum Beginnen die Leertaste drücken (press Space)',win.bkgcolor,win.hndl,1)
        elseif nT ==1 && s_rand(nT).block == 1      % crossed, this according to randomization should be unnecesary
          draw_instructions_and_wait('Beginn des Experiments\n Test Block \n  Für den nächsten Block bitte die Hände überkreuzen (crossed). \n Zum Fortfahren die Leertaste drücken. (press Space)',win.bkgcolor,win.hndl,1)
        elseif s_rand(nT).block == 0                % uncrossed
          draw_instructions_and_wait(sprintf('Block %d/17 beendet \n Pause \n Für den nächsten Block die Hände bitte parallel positionieren (parallel). \n Zum Fortfahren die Leertaste drücken (press Space). \n',b),win.bkgcolor,win.hndl,1)
        elseif s_rand(nT).block == 1                % crossed
          draw_instructions_and_wait(sprintf('Block %d/17 beendet \n Pause  \n Für den nächsten Block die Hände bitte überkreuzen (crossed). \n Zum Fortfahren die Leertaste drücken. (press Space) \n',b),win.bkgcolor,win.hndl,1)
        end      

        if nT>1 && ismember(nT,[49:48:384]+10)   % we calibrate every two small blocks
            EyelinkDoTrackerSetup(win.el);
        end
        b = b+1;
        if s_rand(nT).block==0
            
            DrawFormattedText(win.hndl, 'Für den nächsten Block die Hände parallel positionieren. Zum Fortfahren die Leertaste drücken (press Space).','center','center',255,55);
        elseif s_rand(nT).block==1
            DrawFormattedText(win.hndl, 'Für den nächsten Block die Hände überkreuzen. Zum Fortfahren die Leertaste drücken (press Space).','center','center',255,55);
        end
        Screen('Flip', win.hndl);
        waitForKB_linux({'space'});
    end

    
    % image drawing and decision when to change  
   if  s_rand(nT).block_start == 1               % this is the image that starts the block
        Screen('FillRect', win.hndl, win.bkgcolor);
        Screen('DrawTexture', win.hndl, fixIndex);
        Screen('Flip', win.hndl);
        Eyelink('WaitForModeReady', 500);
        EyelinkDoDriftCorrect2(win.el,win.res(1)/2,win.res(2)/2,0)           
        Screen('FillRect', win.hndl, win.bkgcolor);
        Screen('DrawTexture', win.hndl, postextureIndex);
        Eyelink('message','TRIALID %d', nT);
        Eyelink('Command','record_status_message ''Block %d Image 1 Trial %d''',b,nT);
        ima_x=1;
        Eyelink('StartRecording');
        if nT==1
            win.el.eye_used = Eyelink('EyeAvailable');
            if win.el.eye_used==win.el.BINOCULAR, win.el.eye_used = win.el.LEFT_EYE;end
        end

    else                                    % this is the rest of the images
        Screen('DrawTexture', win.hndl, postextureIndex);
        while 1                             % images change contingent to the end of a fixation and the horixzontal position, we already did the waiting at the end of previous trial
            [data,type] = get_ETdata;
                if type ==6 % start fixation
%                     if abs(data.genx(win.el.eye_used+1)-win.res(1)./2)<win.center_thershold
                    if abs(data.genx(win.el.eye_used)-win.res(1)./2)<win.center_thershold %CHANGED THE PLUS 1 THING
                        WaitSecs(.04+randsample(.01:.01:.1,1));              % this is a lag+jitter so the change of the image occurs after saccadic supression betwenn .5 and .150 sec
                        break
                    end
                end
        end
   end
   
   % actual image change, we message it to the eye-tracke and set the timer
   Screen('Flip', win.hndl);
   Eyelink('message','SYNCTIME'); 
   tstart = GetSecs;
   % this was for the previous only behavioral experiment in which there
   % was a stimulation at start
%    WaitSecs(win.latency_firststim);
%     
%    if s_rand(nT).stim>0
%         Eyelink('command', '!*write_ioport 0x378 %d',s_rand(nT).stim);                    % start stimulation by sending a signal through the parallel port (a number that was set by js_E174_define_tact_states)
%         WaitSecs(win.stim_dur);
%         Eyelink('command', '!*write_ioport 0x378 %d',10);    % stop stimulation
%    end   
   last_stim = GetSecs;
   
    % we send relevant information now
    Eyelink('message','METATR image %d',s_rand(nT).image);
    Eyelink('WaitForModeReady', 50);
%     Eyelink('message','METATR stim %d',s_rand(nT).stim);
%     Eyelink('WaitForModeReady', 50);
    Eyelink('message','METATR block %d',s_rand(nT).block);
    Eyelink('WaitForModeReady', 50);
    Eyelink('message','METATR block_start %d',s_rand(nT).block_start);

    % now we stimulate randomly to left, right and both after times
    % taken randomly from a uniform distribution (or exponential)
    % if we use an uniform distribution
%     rvals =  win.stim_min_latency + (win.stim_max_latency-win.stim_min_latency).*rand(100,1); % get enough random values    
    % if we use an exponential distribution
        rvals = win.stim_min_latency + exprnd(1./win.stim_lambda,1,100);
    stim_idx = 1;
    while GetSecs<tstart+win.trial_minimum_length
        if GetSecs>last_stim+rvals(stim_idx)
%           stim = randsample(1:3,1); % no more bilateral (3) stimulation
           stim = randsample(1:2,1);
          Eyelink('command', '!*write_ioport 0x378 %d',stim);                    % start stimulation by sending a signal through the parallel port (a number that was set by js_E174_define_tact_states)
          WaitSecs(win.stim_dur);       
          Eyelink('command', '!*write_ioport 0x378 %d',10);    % stop stimulation
          last_stim = GetSecs;
          stim_idx = stim_idx+1; 
        end
    end
    Eyelink('WaitForModeReady', 50);
    Eyelink('StopRecording');
    Eyelink('WaitForModeReady', 50);
    if nT<nTrials
        if s_rand(nT+1).block_start ~= 1
            Eyelink('message','TRIALID %d', nT+1);
            ima_x=ima_x+1;
            Eyelink('Command','record_status_message ''Block %d Image %d Trial %d''',b,ima_x,nT+1);
            Eyelink('WaitForModeReady', 50);
            Eyelink('StartRecording');  
        end
    end
end


%%%%% Task Iteration done; save files, restore stuff, DON'T clear vars %%%%
Eyelink('CloseFile');
Eyelink('WaitForModeReady', 500); % make sure mode switching is ok
if ~win.DoDummyMode
    % get EDF->DispPC: file size [bytes] if OK; 0 if cancelled; <0 if error
    rcvStat = Eyelink('ReceiveFile', fnameEDF, pathEDF,1);
    if rcvStat > 0 % only sensible if real connect
        fprintf('EDF received to %s (%.1f MiB).\n',pathEDF,rcvStat/1024^2);
    else
        fprintf(2,'EDF file reception error: %d.\n', rcvStat);
    end
end
% A known issue: Eyelink('Shutdown') crashing Matlab in 64-bit Linux
% cf. http://tech.groups.yahoo.com/group/psychtoolbox/message/12732
if ~IsLinux(true), Eyelink('Shutdown'); end
Screen('CloseAll');
Screen('Preference','Verbosity', prevVerbos); % restore previous verbosity
Screen('Preference','VisualDebugLevel', prevVisDbg);% restore prev vis dbg
ListenChar(1) % restore MATLAB keyboard listening (on command window)
