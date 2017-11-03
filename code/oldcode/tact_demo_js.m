% script to demonstrate tactile stimuli to participants
% experiments E174/E175
% 07-2012, Jonathan Schubert
% a tactile stimulus consists of a 500 ms stimulation that is interrupted 2 or 3 times (randomly)

test=0;

nidaq_out_slot = 0; % which port of the big nidaq box is the device connected to?
nidaq_in_slot = 2;

% set the time during which stimulators are switched off
gap=100;
stim_duration = 500;
tact_freq = 200; % in Hz
% calculate from this the settings for the stimulators that are handed over
% to js_define_tactile_states function. cycle_time sets frequency in
% microseconds
cycle_time = 1000/data.tact_freq*1000;
% intensity is specified with on_time. if stimulator is on for half of the
% cycle time, intensity is maximal
on_time = cycle_time/2;
%%
% ________________________________________________________________
%
% define parallel ports for triggering
% ________________________________________________________________

if ~test
    fprintf('\nopening parallel/nidaq ports...');
    nidaq_ports = digitalio('nidaq', 'Dev2');
    for n = 7 : -1 : 0
        addline(nidaq_ports, n, nidaq_out_slot, 'out'); %tactile: 0 is port 0 on the device
    end
end

reset_code = [0 0 0 0 0 0 0 0];

off_code = dec2bin(10); %t for tactile %example: dec number 4 would be binary 100.
off_code = [ones(1, 8-length(off_code)) * 48 off_code]; % this fills in zeros when needed
off_code = off_code - 48;

if ~test
    input_port = digitalio('nidaq', 'Dev2');
    addline(input_port, 0:1, nidaq_in_slot, 'in');  %input_port.Line(1:2) = input
    fprintf('done');
else
    fprintf('\ntesting, skipping nidaq port');
end



%%
% ________________________________________________________________
%
% define serial port for tactile box
% ________________________________________________________________
fprintf('\nopening serial port...');

if ~test
    global ser;
    ser = th_E105_create_serialport;
    try
        if strcmpi(ser.Status, 'closed')
            fopen(ser);
        end
    catch
        error('MATLAB:serial:fwrite:openserialfailed', lasterr);
        fclose(ser);
    end
    fprintf('done');
    
    fprintf('\nwriting to serial port...');
    ok = js_E174_define_tact_states(ser, on_time, cycle_time);
    if ok ~= 1
        fprintf('\n failed writing stimulus codes to serial port!\n');
    end
    fprintf('done');
else
    fprintf('testing, skipping serial port');
end
%%
fprintf('\nDruecke Enter um Stimuli zu präsentieren!');

for k = 1:5
    %     WaitSecs(1);
    KbStrokeWait();
    
    % draw a random number of touches
    no_of_touches = round(random('unif', 3, 4));
    
    fprintf(['\nno of touches: ', num2str(no_of_touches)]);
    if no_of_touches==3
        tact_stim_duration = (stim_duration - 2*gap)/3;
    elseif no_of_touches==4
        tact_stim_duration = (stim_duration - 3*gap)/4;
    end
    
    
    
    % draw randomly which side is stimulated
    touched_side = round(random('unif', 1, 2));
    
    if touched_side == 1
        fprintf('\nLEFT finger\n');
    else
        fprintf('\nRIGHT finger\n');
    end
    
    
    
    % calculate parallel port code
    stim_code = dec2bin(data.trial(tlfd).tact); %t for tactile %example: dec number 4 would be binary 100.
    stim_code = [ones(1, 8-length(stim_code)) * 48 stim_code]; % this fills in zeros when needed
    current_code = stim_code - 48;
    
    for s = 1 : no_of_touches
        
        %tactile stimulus on
        if ~test
            putvalue(nidaq_ports, current_code);
            %             WaitSecs(0.002);
            %             putvalue(nidaq_ports, reset_code);
        end
        
        % wait for stimulus duration, then turn off
        WaitSecs(tact_stim_duration / 1000);
        if ~test
            putvalue(nidaq_ports, off_code);
            %             WaitSecs(0.002);
            %             putvalue(nidaq_ports, reset_code);
        end
        
        
        if s < no_of_touches
            WaitSecs(gap / 1000);
        end
        
    end
end

fclose(ser)