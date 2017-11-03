[IsConnected, IsDummy] = EyelinkInit(0);         
Eyelink('command', '!*write_ioport 0x378 0');
win.tact_freq               = 100;
freq                        = 48000;                                        % noise frequency in Hz
dur                         = 5;                                           % noise duration in seconds
wavedata1                   = rand(1,freq*dur)*2-1;                         % the noise
wavedata2                   = 2*sin(2.*pi.*win.tact_freq.*[0:1/freq:dur-1/freq]);      % the stimulus
wavedata                    = [wavedata1 ; wavedata2];                      % double for stereo
nrchannels                  = 2;                                            % ditto

                                       % ditto

InitializePsychSound;                                                       % Perform basic initialization of the sound driver:

pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
PsychPortAudio('FillBuffer', pahandle, wavedata);                           % Fill the audio playback buffer with the audio data 'wavedata':
 PsychPortAudio('Volume', pahandle,.7);                            % sets the noise volume to the input one      

t1              = PsychPortAudio('Start', pahandle, 0, 0, 0);               % Start the sounds
Eyelink('command', '!*write_ioport 0x378 2');                           % start stimulation by sending a signal through the parallel port (a number that was set by E275_define_tact_states)
WaitSecs(dur)
Eyelink('command', '!*write_ioport 0x378 0');                           % start stimulation by sending a signal through the parallel port (a number that was set by E275_define_tact_states)
     
PsychPortAudio('Stop', pahandle);
PsychPortAudio('Close', pahandle);                                          % close the audio device
