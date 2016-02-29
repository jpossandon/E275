
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% E275_jo_experiment.m 
% Free viewing with tactile stimulation experiment
% This is an EEG/Eye-tracking/Tactile-stimulation experiment
% The experiment consists in the presentation of real world photographies, which
% subject are instructed to freely explore. At the same time random tactile
% stimulation is delivered to the left or right hand, and subjects are
% instructed to ignore the stimulation.
%
% If the experiment script is interrupted, run the following lines in the
% command windows so a new experiment can be initiated:
%       sca                                         % close PTB windows
%       Eyelink('Shutdown');                        % closes the link to the eye-tracker
%       fclose(obj);                                % closes the serial port
%       PsychPortAudio('Close', pahandle);          % closes the audio port
%
% This experiment script is a modification of Touch_experiment.m, also by 
% JPO and used in a previous experiment without EEG in NBP lab (Osnabr?ck)
% JPO, January-2016, Hamburg
%
% TOCHECK: 
% - what would be the screen resolution
% - all !CHANGE!
% - win.el.eye_used problem
% - 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENT PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear all                                                                 % we clear parameters?
% this is for debugging
win.DoDummyMode             = 0;                                            % (1) is for debugging without an eye-tracker, (0) is for running the experiment
win.stim_test               = 1;                                            % (1) for testing the stimulators (always when doing the experiment), (0) to skip
%PsychDebugWindowConfiguration(0,0.5);                                       % this is for debugging with a single screen

% Screen parameters
win.whichScreen             = 0;                                            % (CHANGE?) here we define the screen to use for the experiment, it depend on which computer we are using and how the screens are conected so it might need to be changed if the experiment starts in the wrong screen
win.FontSZ                  = 20;                                           % font size
win.bkgcolor                = 127;                                          % screen background color, 127 gray
win.Vdst                    = 66;                                           % (!CHANGE!) viewer's distance from screen [cm]         
win.res                     = [1920 1080];                                  %  horizontal x vertical resolution [pixels]
win.wdth                    = 51;                                           %  51X28.7 cms is teh size of Samsung Syncmaster P2370 in BPN lab EEG rechts
win.hght                    = 28.7;                                         % 
win.pixxdeg                 = win.res(1)/(2*180/pi*atan(win.wdth/2/win.Vdst));% 
win.trial_minimum_length    = 8;                                            % this is the minimal length of image presentation, afterwwards image changes contingent on a fixation occuring whithin a vertical strip arround the horizontal midline (defined by win.center_threshold)
win.center_thershold        = 3*win.pixxdeg;                                % distance from the midline threshold for gaze contingent end of trial

% Tactile stimulation settings (using the box stimulator)
win.tact_freq               = 200;                                          % frequency of stimulation in Hz
win.cycle_time              = 1000/win.tact_freq*1000;                      % cycle_time sets frequency in microseconds (1000 microsecond is one milisecond)
win.on_time                 = win.cycle_time-1/2*win.cycle_time;                             % on_time specifies intensity. If stimulator is on for half of the cycle time, intensity is maximal
win.stim_dur                = .025;                                         % duration of tactile stimulation. The vibrator takes some time to stop its motion so for around 50 ms we use 25 ms of stimulation time (ask Tobias for the exact latencies they have measured)
win.stim_min_latency        = .750;                                         % minimum time from trial start (new image appearance) or previous stimulation for a tactile stimulation to occur
win.halflife                = 8/3;                                          % we use an exponential distribution for a flat hazard function. Here the denominator set the duration in which half of the times will occur an stimulation
win.stim_lambda             = log(2)./win.halflife;                                 

% Blocks and trials
win.exp_trials              = 390;
win.test_trials             = 10;
win.t_perblock              = 15;
win.calib_every             = 2; 

% Audio, white noise parameters
win.wn_vol                  = .2;                                           % (CHANGE?) adjust to subject comfort

% Device input during the experiment
win.in_dev                  = 1;                                            % (1) - keyboard  (2) - mouse  (3) - pedal (?)    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENT START
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% (!CHANGE!) adjust this to the appropiate screen
display(sprintf('\n\n\n\n\n\nPlease check that the display screen resolution is set to 1920x1080 and the screen borders are OK. \nIf screen resolution is changes matlab (and the terminal) need to be re-started.\n'))
if ismac                                                                    % this bit is just so I can run the experiment in my mac without a problem
    exp_path                = '/Users/jossando/trabajo/E275/';              % path in my mac
else
    exp_path                = '/home/th/Experiments/E275/';
end

win.s_n                     = input('Subject number: ','s');                % subject id number, this number is used to open the randomization file
win.fnameEDF                = sprintf('s%02d.EDF',str2num(win.s_n));       % EDF name can be only 8 letters long, so we can have numbers only between 01 and 99
pathEDF                     = [exp_path 'data/' sprintf('s%02d/',str2num(win.s_n))];                           % where the EDF files are going to be saved
if exist([pathEDF win.fnameEDF],'file')                                         % checks whether there is a file with the same name
    rp = input(sprintf('!Filename %s already exist, do you want to overwrite it (y/n)?',win.fnameEDF),'s');
    if (strcmpi(rp,'n') || strcmpi(rp,'no'))
        error('filename already exist')
    end
end

win.s_age                   = input('Subject age: ','s');
win.s_hand                  = input('Subject handedness for writing (l/r): ','s');
win.s_gender                = input('Subject gender (m/f): ','s');
setStr                      = sprintf('Subject %d\nAge %s\nHandedness %s\nGender %s\n',win.s_n,win.s_age,win.s_hand,win.s_gender); % setting summary
fprintf(setStr); 

AssertOpenGL();                                                             % check if Psychtoolbox is working (with OpenGL) TODO: is this needed?
ClockRandSeed();                                                            % this changes the random seed

[IsConnected, IsDummy] = EyelinkInit(win.DoDummyMode);                      % open the link with the eyetracker
assert(IsConnected==1, 'Failed to initialize EyeLink!')
 
% ListenChar(2)                                                             % disable key listening by MATLAB windows(CTRL+C overridable)

prevVerbos = Screen('Preference','Verbosity', 2);                           % this two lines it to set how much we want the PTB to output in the command and display window 
prevVisDbg = Screen('Preference','VisualDebugLevel',3);                     % verbosity-1 (default 3); vdbg-2 (default 4)
Screen('Preference', 'SkipSyncTests', 2)                                    % for maximum accuracy and reliability

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START PTB SCREEN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[win.hndl, win.rect]        = Screen('OpenWindow',win.whichScreen,win.bkgcolor);   % starts PTB screen
% if win.rect(3)~=1280 || win.rect(4)~=960                                    % (!CHANGE!) if resolution is not the correct one the experiment stops
%     sca
%     Eyelink('Shutdown');       % closes the link to the eye-tracker
%     fclose(obj);               % closes the serial port
%     error('Screen resolution must be 1280x960')
% end
[win.cntr(1), win.cntr(2)] = WindowCenter(win.hndl);                        % get where is the display screen center
Screen('BlendFunction',win.hndl, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);     % enable alpha blending for smooth drawing
HideCursor(win.hndl);                                                       % this to hide the mouse
Screen('TextSize', win.hndl, win.FontSZ);                                   % sets teh font size of the text to be diplayed
KbName('UnifyKeyNames');                                                    % recommended, called again in EyelinkInitDefaults


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SERIAL PORT SETTING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ismac                                                                    % for debugging        
    display('Skipping serial port settings. Only for testing the code')
else
    device                  = '/dev/ttyS0';                                 % /dev/ttyS0 is the default linux serial port (file)
    obj                     = serial(device,'BaudRate',115200,...           % serial port specs, this is D/P/S = 8/N/1 which is the standars
                                'Parity','none',...
                                'StopBits',1,...
                                'FlowControl','none'); 
    try                                                                     % try to open the serial port 
        if strcmpi(obj.Status, 'closed')
            fopen(obj);
        end
    catch
        error('MATLAB:serial:fwrite:openserialfailed', lasterr);
        fclose(obj);
    end
    fprintf('done');
    fprintf('\nwriting to serial port...');
    ok = E275_define_tact_states(obj, win.on_time, win.cycle_time);         % E275_define_tact_states defines the codes to control the stimulation box via the parallel port:
    if ok ~= 1                                                              % It should be (1) left stimulator; (2) right stimulator; (3) both; (10) turn-off
        error('\n failed writing stimulus codes to serial port!\n');
    end
    fprintf('done');
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START AUDIO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

freq                        = 48000;                                        % noise frequency in Hz
dur                         = 15;                                           % noise duration in seconds
wavedata                    = rand(1,freq*dur)*2-1;                         % the noise
wavedata                    = [wavedata ; wavedata];                        % double for stereo
nrchannels                  = 2;                                            % ditto

InitializePsychSound;                                                       % Perform basic initialization of the sound driver:

try                                                                         % Try with the 'freq'uency we wanted:
    pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
catch                                                                       % Failed. Retry with default frequency as suggested by device:
    fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', freq);
    fprintf('Sound may sound a bit out of tune, ...\n\n');
    psychlasterror('reset');
    pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
end
PsychPortAudio('FillBuffer', pahandle, wavedata);                           % Fill the audio playback buffer with the audio data 'wavedata':
PsychPortAudio('Volume', pahandle,win.wn_vol);                              % Sets the volume (between 0 and 1)
s = PsychPortAudio('GetStatus', pahandle);                                  % Status of the port, necessary later to defice wheter to start or stop audio


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INSTRUCTIONS IN GERMAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if win.in_dev == 1
    txtdev = ['Leertaste dr' 252 'cken (press Space)'];
elseif win.in_dev == 2
    txtdev = 'Maustate klicken';
end

% This is the safest way so umlaut are corretly displayed UTF. 
% code for umlauts 228(a),252(u)
txt1     = double(['Die Funktionsf' 228 'higkeit der Ger' 228 'te muss '...    
            252 'berpr' 252 'ft werden\n' txtdev ' zum Fortfahren..']);             
txt2     = double(['Stimulatoren werden auf den Handr' 252 'cken besfestigt ...\n' txtdev]);
txt3     = double(['Der linke Stimulator wird getestet (vibriert drei mal), ...\n danach ' txtdev]);
txt4     = double(['Der rechte Stimulator wird getestet (vibriert drei mal), ...\n danach ' txtdev]);
txt5     = double(['Beide Stimulatoren vibrieren gleichzeitig (drei mal), ...\n danach '  txtdev]); 
txt6     = double(['Beginn des Experiments \n Test Block \n Die H' 228 ...
            'nde bitte parallel positionieren (parallel). \n Zum Beginnen die ' txtdev]);
txt7     = double(['Beginn des Experiments\n Test Block \n  F' 252 'r den n' 228 ...
            'chsten Block bitte die H' 228 'nde ' 252 'berkreuzen (crossed). \n Zum Fortfahren die ' txtdev]);      
% txt 9&10 are contingent to the block so they are defined later
txt10    = double(['F' 252 'r den n' 228 'chsten Block die H' 228 ...
        'nde parallel positionieren. Zum Fortfahren die ' txtdev]);
txt11    = double(['F' 252 'r den n' 228 'chsten Block die H' 228 ...
        'nde ' 252 'berkreuzen. Zum Fortfahren die '  txtdev]);

%these are for debugging
handstr  = {'Left','Right'};
crossstr = {'Uncrossed','Crossed'};
        
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EYE-TRACKER SETUP, OPEN THE EDF FILE AND ADDS INFO TO ITS HEADER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[win.el, win.elcmds] = setup_eyetracker(win, 1);                            % Setups the eye-tracker with the before mentioned parameters

DrawFormattedText(win.hndl,txt1,'center','center',255,55);                  % This 'draws' the text, nothing is displayed until Screen flip
Screen('Flip', win.hndl);                                                   % This is the command that changes the PTB display screen. Here it present the first instructions.

if win.in_dev == 1                                                          % Waiting for input according to decided device to continue
    waitForKB_linux({'space'});                                             % press the space key in the keyboard
elseif win.in_dev == 2
    [clicks,x,y,whichButton] = GetClicks(win.hndl,0);                       % mouse clik
end

OpenError = Eyelink('OpenFile', win.fnameEDF);                                  % opens the eye-tracking file. It can only be done after setting-up the eye-tracker 
if OpenError                                                                % error in case it is not possible, never happened that I know, but maybe if the small hard-drive aprtition of the eye=tracker is full
    error('EyeLink OpenFile failed (Error: %d)!', OpenError), 
end
Eyelink('Command', sprintf('add_file_preamble_text ''%s''', setStr));       % this adds the information about subject to the end of the header  
wrect = Screen('Rect', win.hndl);                                           
Eyelink('Message','DISPLAY_COORDS %d %d %d %d', 0, 0, wrect(1), wrect(2));  % write display resolution to EDF file

ListenChar(2)                                                               % disable MATLAB windows' keyboard listen (no unwanted edits)


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STIMULATOR TEST
% ALWAYS: left-hand is # 1 and right-hand is # 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if win.stim_test
    DrawFormattedText(win.hndl,txt2,'center','center',255,55);
    Screen('Flip', win.hndl);
    if win.in_dev == 1                                                          % Waiting for input according to decided device to continue
        waitForKB_linux({'space'});                                             % press the space key in the keyboard
    elseif win.in_dev == 2
        [clicks,x,y,whichButton] = GetClicks(win.hndl,0);                       % mouse clik
    end

    DrawFormattedText(win.hndl,txt3,'center','center',255,55);                  % TEST LEFT STIMULATOR (three times)
    Screen('Flip', win.hndl);
    WaitSecs(1);
    for e=1:3
        Eyelink('command', '!*write_ioport 0x378 0');                  
        WaitSecs(1+rand(1));      
        Eyelink('command', '!*write_ioport 0x378 1');                           % start stimulation by sending a signal through the parallel port (a number that was set by E275_define_tact_states)
        WaitSecs(win.stim_dur);                                                 % for the specified duration
        Eyelink('command', '!*write_ioport 0x378 15');                          % stop stimulation
        WaitSecs(win.stim_dur);
    end
    if win.in_dev == 1                                                          % Waiting for input according to decided device to continue
        waitForKB_linux({'space'});                                             % press the space key in the keyboard
    elseif win.in_dev == 2
        [clicks,x,y,whichButton] = GetClicks(win.hndl,0);                       % mouse clik
    end

    DrawFormattedText(win.hndl,txt4,'center','center',255,55);                  % TEST RIGHT STIMULATOR (three times)
    Screen('Flip', win.hndl);
    WaitSecs(1);
    for e=1:3
        Eyelink('command', '!*write_ioport 0x378 0');
        WaitSecs(1+rand(1));      
        Eyelink('command', '!*write_ioport 0x378 2');                           % start stimulation by sending a signal through the parallel port (a number that was set by E275_define_tact_states)
        WaitSecs(win.stim_dur);       
        Eyelink('command', '!*write_ioport 0x378 15');                          % stop stimulation
        WaitSecs(win.stim_dur);
    end
    if win.in_dev == 1                                                          % Waiting for input according to decided device to continue
        waitForKB_linux({'space'});                                             % press the space key in the keyboard
    elseif win.in_dev == 2
        [clicks,x,y,whichButton] = GetClicks(win.hndl,0);                       % mouse clik
    end

    DrawFormattedText(win.hndl,txt5,'center','center',255,55);                  % TEST BOTH STIMULATORs (three times), this is not needed for this experiment but anyways
    Screen('Flip', win.hndl);
    WaitSecs(1);
    for e=1:3
        Eyelink('command', '!*write_ioport 0x378 0');
        WaitSecs(1+rand(1));      
        Eyelink('command', '!*write_ioport 0x378 5');                    
        WaitSecs(win.stim_dur);       
        Eyelink('command', '!*write_ioport 0x378 15');    
        WaitSecs(win.stim_dur);
    end
    Eyelink('command', '!*write_ioport 0x378 0');
    if win.in_dev == 1                                                          % Waiting for input according to decided device to continue
        waitForKB_linux({'space'});                                             % press the space key in the keyboard
    elseif win.in_dev == 2
        [clicks,x,y,whichButton] = GetClicks(win.hndl,0);                       % mouse clik
    end

    fprintf('\nTest ready!');
else
    fprintf('\nSkipping stimulators Test.\n Only during experiment debugging');
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EYE-TRACKER CALIBRATION AND VALIDATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EyelinkDoTrackerSetup(win.el);                                              % calibration/validation (keyboard control)
Eyelink('WaitForModeReady', 500);

[image,map,alpha]   = imread([exp_path 'stimuli/blackongrt.jpg']);          % drift correction dot image
fixIndex            = Screen('MakeTexture', win.hndl, image);               % this is one of the way PTB deals with images, the image matrix is transformed in a texture with a handle that can be user later to draw the image in theb PRB screen


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Randomization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_images         = 400:415;                                                 % all subject see the same test images
test_images         = test_images(1:win.test_trials);                       % in the same order, it does not matter
win.image_order     = [test_images,...                                      % we randomize the order of the images, not that it really matters
                        randperm(win.exp_trials,win.exp_trials)];
nTrials             = win.test_trials+win.exp_trials;                       % Total # of trial
nBlocks             = win.exp_trials./win.t_perblock;                       % # experimental block without counting the first test one
win.block_start     = [1,zeros(1,win.test_trials-1),...                     % Trials that are block start
                        repmat([1,zeros(1,win.t_perblock-1)],1,nBlocks)];
if rem(win.s_n,2)                                                           % we balance across subjects (according to their subject number) whether they start the experiment with the hand crossed or uncrossed, again this should not matter that much
    win.blockcond   = [zeros(1,win.test_trials),...
        repmat([zeros(1,win.t_perblock),ones(1,win.t_perblock)],1,nBlocks/2)];
else
    win.blockcond   = [zeros(1,win.test_trials),...
        repmat([ones(1,win.t_perblock),zeros(1,win.t_perblock)],1,nBlocks/2)];
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THE ACTUAL EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

b                   = 0;                                                    % block flag
for nT = 1:nTrials                                                          % loop throught the experiment trials
    
    image                       = imread(sprintf('%sstimuli/image_%01d.jpg',...
                                exp_path,win.image_order(nT)));      

    postextureIndex             = Screen('MakeTexture', win.hndl, image);   % makes the texture of this trial image
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % BLOCK START
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if  win.block_start(nT) == 1                                                % if it is a trial that starts a block   
        if s.Active                                                         % if the white noise was on, we sopt it here
            PsychPortAudio('Stop', pahandle)
        end
        
        % Hand position block intructions
        if nT ==1 && win.blockcond(nT) == 0                                  % practice trials and uncrossed
            draw_instructions_and_wait(txt6,win.bkgcolor,win.hndl,win.in_dev,1)
        elseif nT ==1 && win.blockcond(nT) == 1                              % practice trials amd crossed, this according to randomization should be unnecesary
            draw_instructions_and_wait(txt7,win.bkgcolor,win.hndl,win.in_dev,1)
        elseif win.blockcond(nT) == 0                % uncrossed
            txt8    = double(['Block ' num2str(b) '/' num2str(nBlocks+1) ' beendet \n Pause \n  F' 252 'r den n' 228 ... 
            'chsten Block bitte die H' 228 'nde parallel positionieren (parallel). \n Zum Fortfahren die ' txtdev]);
            draw_instructions_and_wait(txt8,win.bkgcolor,win.hndl,win.in_dev,1)
        elseif win.blockcond(nT) == 1                % crossed
            txt9    = double(['Block ' num2str(b) '/' num2str(nBlocks+1) ' beendet \n Pause \n  F' 252 'r den n' 228 ... 
            'chsten Block bitte die H' 228 'nde ' 252 'berkreuzen (crossed). \n Zum Fortfahren die ' txtdev]);
            draw_instructions_and_wait(txt9,win.bkgcolor,win.hndl,win.in_dev,1)
        end      
        b = b+1;
        if nT>1 %&& ismember(nT, win.t_perblock+win.test_trials+1:win.calib_every*win.t_perblock:nTrials)                              % we calibrate every two small blocks
            EyelinkDoTrackerSetup(win.el);
        end
        
        if win.blockcond(nT) == 0
            DrawFormattedText(win.hndl, txt10,'center','center',255,55);
        elseif win.blockcond(nT) == 1
            DrawFormattedText(win.hndl,txt11,'center','center',255,55);
        end
        Screen('Flip', win.hndl);
        if win.in_dev == 1                                                              
            waitForKB_linux({'space'});                                           
        elseif win.in_dev == 2
            GetClicks(win.hndl,0);                                                      
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TRIALS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    % IMAGE DRAWING AND DECISION OF WHEN TO CHANGE
    if  win.block_start(nT) == 1                                            % this is the image that starts the block
        t1      = PsychPortAudio('Start', pahandle, 0, 0, 0);               % starts the white noise, third input is set to 0 so it loops until is sopped
 
        Screen('FillRect', win.hndl, win.bkgcolor);                         % remove what was writte or displayed
        Screen('DrawTexture', win.hndl, fixIndex);                          % drift correction image
        Screen('Flip', win.hndl);
        Eyelink('WaitForModeReady', 500);
        EyelinkDoDriftCorrect2(win.el,win.res(1)/2,win.res(2)/2,0)          % drift correction 
        
        Screen('FillRect', win.hndl, win.bkgcolor);
        Screen('DrawTexture', win.hndl, postextureIndex);                   % draw the trial image
        Eyelink('message','TRIALID %d', nT);                                % message about trial start in the eye-tracker
        Eyelink('Command',...                                               % display in the eyetracker what is going on
            'record_status_message ''Block %d Image 1 Trial %d''',b,nT);
        ima_x   =   1;                                                      % keeps track of the image number within the block
        Eyelink('StartRecording');
        if nT==1
            win.el.eye_used = Eyelink('EyeAvailable');
            if win.el.eye_used==win.el.BINOCULAR,                           % (!TODO!) this I do not know yet
                win.el.eye_used = win.el.LEFT_EYE;
            end
        end
        s       = PsychPortAudio('GetStatus', pahandle);

    else                                                                   % this is the rest of the images
        Screen('DrawTexture', win.hndl, postextureIndex);
        while 1                                                             % images change contingent to the end of a fixation and the horixzontal position, we already did the waiting at the end of previous trial
            [data,type] = get_ETdata;
                if type ==6 % start fixation
                     if abs(data.genx(win.el.eye_used+1)-win.res(1)./2)<win.center_thershold
%                     if abs(data.genx(win.el.eye_used)-win.res(1)./2)<win.center_thershold % (!TODO!) check this
%                        WaitSecs(.04+randsample(.01:.01:.1,1));              % this is a lag+jitter so the change of the image occurs after saccadic supression betwenn .05 and .150 sec
                        break
                    end
                end
        end
    end
   
    
    Screen('Flip', win.hndl);                                               % actual image change, we message it to the eye-tracke and set the timer
    Eyelink('message','SYNCTIME');                                          % so trial zero time is just after image change
    Eyelink('command', '!*write_ioport 0x378 %d',96);                       % image appearance trigger, same as in my other free-viewing data
    tstart      = GetSecs;                                                  % timer trial start
    last_stim   = tstart;                                                   % in this case, this mean image appearace
 
   
    Eyelink('message','METATR image %d',win.image_order(nT));               % we send relevant information to the eye-tracker file, here which image
    Eyelink('WaitForModeReady', 50);
    Eyelink('message','METATR block %d',win.blockcond(nT));                 % block condition
    Eyelink('WaitForModeReady', 50);
    Eyelink('message','METATR block_start %d',win.block_start(nT));         % if it was the first image in the block
    Eyelink('command', '!*write_ioport 0x378 %d',0);                        % flush the parallel port
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TACTILE STIMULATION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
%     rvals     =  win.stim_min_latency + (win.stim_max_latency-win.stim_min_latency).*rand(100,1); % interstimulation intervals defined by an uniform distribution    
    rvals       = win.stim_min_latency + ...                                % interstimulation intervals defined by an exponential distribution with half-life = 1/lambda
                (-1./win.stim_lambda .* log(rand([1 100])));                % rvals = win.stim_min_latency + exprnd(1./win.stim_lambda,1,100);    by pass stat toolbox
   
    stim_idx    = 1;
    while GetSecs<tstart+win.trial_minimum_length                           % lopp until trials finishes
        if GetSecs>last_stim+rvals(stim_idx)
          stim      = round(1+rand(1));                                     % 1 - left uncross; 2 - right uncross; 3 - left cross; 4 - right cross
         
          if win.blockcond(nT)==0
            Eyelink('command', '!*write_ioport 0x378 %d',stim);               % start stimulation by sending a signal through the parallel port (a number that was set by js_E174_define_tact_states)
            WaitSecs(win.stim_dur);       
          elseif win.blockcond(nT)==1
            Eyelink('command', '!*write_ioport 0x378 %d',stim+2);               % start stimulation by sending a signal through the parallel port (a number that was set by js_E174_define_tact_states)
            WaitSecs(win.stim_dur);       
          end
          Eyelink('command', '!*write_ioport 0x378 %d',15);                 % stop stimulation
          last_stim = GetSecs;
          WaitSecs(0.03);
          stim_idx = stim_idx+1;
          Eyelink('command', '!*write_ioport 0x378 %d',0);                  % flush the parallel port
          %for testing purporses
          display(sprintf('\n Delivered stimulation at the %s hand %s  %4.2f',handstr{stim},crossstr{win.blockcond(nT)+1},GetSecs-tstart))
        end
    end
    
    Eyelink('command', '!*write_ioport 0x378 %d',0);                        % flush the parallel port for last time
    Eyelink('WaitForModeReady', 50);
    Eyelink('StopRecording');
    Eyelink('WaitForModeReady', 50);
    if nT<nTrials                                                           % here we start next trial
        if win.block_start(nT+1) ~= 1
            Eyelink('message','TRIALID %d', nT+1);
            ima_x = ima_x+1;
            Eyelink('Command','record_status_message ''Block %d Image %d Trial %d''',b,ima_x,nT+1);
            Eyelink('WaitForModeReady', 50);
            Eyelink('StartRecording');  
        end
    end
end

PsychPortAudio('Stop', pahandle);                                           % Stop the white noise after the last trial

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finishing EDF file and transfering info (in case experiment is interrupted
% this can be run to save the eye-tracking data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% Task Iteration done; save files, restore stuff, DON'T clear vars %%%%
Eyelink('CloseFile');
Eyelink('WaitForModeReady', 500); % make sure mode switching is ok
if ~win.DoDummyMode
    % get EDF->DispPC: file size [bytes] if OK; 0 if cancelled; <0 if error
    rcvStat = Eyelink('ReceiveFile', win.fnameEDF, pathEDF,1);
    if rcvStat > 0 % only sensible if real connect
        fprintf('EDF received to %s (%.1f MiB).\n',pathEDF,rcvStat/1024^2);
    else
        fprintf(2,'EDF file reception error: %d.\n', rcvStat);
    end
end

save([pathEDF,win.fnameEDF(1:end-3),'mat'],'win')
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLOSING ALL DEVICES, PORTS, ETC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Most of the commands below are important for being able to restart the
% experiment, in the case the experiment crushs they should be entered
% manually

% A known issue: Eyelink('Shutdown') crashing Matlab in 64-bit Linux
% cf. http://tech.groups.yahoo.com/group/psychtoolbox/message/12732
% not anymore it seems
%if ~IsLinux(true), Eyelink('Shutdown'); end
PsychPortAudio('Close', pahandle);                                          % close the audio device
Eyelink('Shutdown');                                                        % close the link to the eye-tracker

Screen('CloseAll');                                                         % close the PTB screen
Screen('Preference','Verbosity', prevVerbos);                               % restore previous verbosity
Screen('Preference','VisualDebugLevel', prevVisDbg);                        % restore prev vis dbg
fclose(obj);                                                                % close the serial port
ListenChar(1)                                                               % restore MATLAB keyboard listening (on command window)
