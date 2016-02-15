function E275_jo_volumetest()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% E275 White-noise volume test
% This script can be used to define the appropiate wn volume in the 
% experimental script
%
% JPO, 28.01.16, Hamburg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noise_volume            = input('Volume to test [between 0 and 1]: ');      % Volume input between 0-1

try
freq                        = 48000;                                        % noise frequency in Hz
dur                         = 10;                                           % noise duration in seconds
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
PsychPortAudio('Volume', pahandle,noise_volume);                            % sets the noise volume to the input one      

display('Audio Port status before starting playback')
s               = PsychPortAudio('GetStatus', pahandle)                   % Status of the port, necessary later to defice wheter to start or stop audio
t1              = PsychPortAudio('Start', pahandle, 0, 0, 0);               % Start the sounds
display('Audio Port status after starting playback')
s               = PsychPortAudio('GetStatus', pahandle)
WaitSecs(dur)
PsychPortAudio('Stop', pahandle);
PsychPortAudio('Close', pahandle);                                          % close the audio device
catch
    PsychPortAudio('Close', pahandle);
end

