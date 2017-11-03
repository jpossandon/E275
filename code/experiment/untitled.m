tic
Eyelink('command', '!*write_ioport 0x378 %d',3);               % start stimulation by sending a signal through the parallel port (a number that was set by js_E174_define_tact_states)
            WaitSecs(win.stim_dur);
           toc
            Eyelink('command', '!*write_ioport 0x378 %d',15); 
                    last_stim = GetSecs;
%   WaitSecs(win.stim_dur);
           stim_idx = stim_idx+1;
          Eyelink('command', '!*write_ioport 0x378 %d',0); 
          toc

% [win.hndl, win.rect]        = Screen('OpenWindow',win.whichScreen,win.bkgcolor); 
% tic
% ListenChar(2)
% t1      = PsychPortAudio('Start', pahandle, 0, 0, 0);
% 
% WaitSecs(15)
% PsychPortAudio('Stop', pahandle)
% sca
% ListenChar(1)
% toc