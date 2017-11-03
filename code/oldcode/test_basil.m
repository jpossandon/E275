cd /home_local/tracking/experiments/touch/code
device = '/dev/ttyS0';
serial_port = serial(device,'BaudRate', 115200,'Parity','none','StopBits',1,'FlowControl','none');
fopen(serial_port);

tact_freq = 20; % in Hz
% % calculate from this the settings for the stimulators that are handed over
% % to js_define_tactile_states function. cycle_time sets frequency in
% % microseconds
cycle_time = 1000/tact_freq*1000;
% % intensity is specified with on_time. if stimulator is on for half of the
% % cycle time, intensity is maximal
on_time = cycle_time/2;
% on_time = 25000
% cycle_time = 80000
%define state 1: turn on stimulator #1
fprintf(serial_port, ['V1,' num2str(on_time) ',' num2str(cycle_time) ',1\n']);
fprintf(serial_port, 'V2,200,100,1\n');
fprintf(serial_port, 'V3,200,100,1\n');
fprintf(serial_port, 'V4,200,100,1\n');
fprintf(serial_port, 'V5,200,100,1\n');
fprintf(serial_port, 'V6,200,100,1\n');
fprintf(serial_port, 'V7,200,100,1\n');
fprintf(serial_port, 'V8,200,100,1\n');

% on_time = 25000

%define state 2: turn on stimulator #2
fprintf(serial_port, ['V2,' num2str(on_time) ',' num2str(cycle_time) ',2\n']);
fprintf(serial_port, 'V1,200,100,2\n');
fprintf(serial_port, 'V3,200,100,2\n');
fprintf(serial_port, 'V4,200,100,2\n');
fprintf(serial_port, 'V5,200,100,2\n');
fprintf(serial_port, 'V6,200,100,2\n');
fprintf(serial_port, 'V7,200,100,2\n');
fprintf(serial_port, 'V8,200,100,2\n');
%define state 3: turn on stimulator #3
fprintf(serial_port, 'V1,200,100,3\n');
fprintf(serial_port, 'V2,200,100,3\n');
fprintf(serial_port, 'V3,200,100,2\n');
fprintf(serial_port, 'V4,200,100,3\n');
fprintf(serial_port, 'V5,200,100,3\n');
fprintf(serial_port, 'V6,200,100,3\n');
fprintf(serial_port, 'V7,200,100,3\n');
fprintf(serial_port, 'V8,200,100,3\n');

%       %define state 1: turn on stimulator #1
fprintf(serial_port, ['V1,' num2str(on_time) ',' num2str(cycle_time) ',4\n']);
on_time = cycle_time/10;
fprintf(serial_port, ['V2,' num2str(on_time) ',' num2str(cycle_time) ',4\n']);
fprintf(serial_port, 'V3,200,100,4\n');
fprintf(serial_port, 'V4,200,100,4\n');
fprintf(serial_port, 'V5,200,100,4\n');
fprintf(serial_port, 'V6,200,100,4\n');
fprintf(serial_port, 'V7,200,100,4\n');
fprintf(serial_port, 'V8,200,100,4\n');


fwrite(serial_port,'!*write_ioport 0x378 0x00')
fwrite(serial_port,'!*write_ioport 0x378 1')
fwrite(serial_port,'!*write_ioport 0x378 0')
fwrite(serial_port,'!*write_ioport 0x378 3')
fwrite(serial_port,'!*write_ioport 0x378 4')



edf_filename    = 'test.edf'
whichScreen = max(Screen('Screens'));
win.FontSZ                  = 20;
win.bkgcolor                = 127;
% TODO check this numbers
win.Vdst                    = 80;          % viewer's distance from screen [cm]
win.res                     = [1920 1080]; % horizontal x vertical resolution [pixels]
win.wdth                    = 40;        % TODO: physical screen width  [cm]
win.hght                    = 29.5;        % TODO: physical screen height [cm]
win.pixxdeg                 = 45;
win.center_thershold        = 3*win.pixxdeg;       % distance from the midline threshold for gaze contingent end of trial
win.trial_minimum_length    = 6;

[win.hndl win.Rect] = Screen('OpenWindow',whichScreen,0,[0 0 100 100]);       %testwindow


win.DoDummyMode = false;
[win.el win.elcmds] = setup_eyetracker(win, 1);
Eyelink('OpenFile', edf_filename );
Eyelink('command', '!*write_ioport 0x378 0x00');
EyelinkDoTrackerSetup(win.el);  % calibration/validation (keyboard control)
Eyelink('command', '!*write_ioport 0x378 1')
Eyelink('command', '!*write_ioport 0x378 0')
Eyelink('command', '!*write_ioport 0x378 3')