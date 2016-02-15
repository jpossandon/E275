function ok = E275_define_tact_states(serial_port, on_time, cycle_time)
    

    %define state 1: turn on stimulator #1
    fprintf(serial_port, ['V1,' num2str(on_time) ',' num2str(cycle_time) ',1\n']);
    fprintf(serial_port, 'V2,200,100,1\n');
    fprintf(serial_port, 'V3,200,100,1\n');
    fprintf(serial_port, 'V4,200,100,1\n');
    fprintf(serial_port, 'V5,200,100,1\n');
    fprintf(serial_port, 'V6,200,100,1\n');
    fprintf(serial_port, 'V7,200,100,1\n');
    fprintf(serial_port, 'V8,200,100,1\n');
    
    %define state 2: turn on stimulator #2
    fprintf(serial_port, 'V1,200,100,2\n');
    fprintf(serial_port, ['V2,' num2str(on_time) ',' num2str(cycle_time) ',2\n']);
    fprintf(serial_port, 'V3,200,100,2\n');
    fprintf(serial_port, 'V4,200,100,2\n');
    fprintf(serial_port, 'V5,200,100,2\n');
    fprintf(serial_port, 'V6,200,100,2\n');
    fprintf(serial_port, 'V7,200,100,2\n');
    fprintf(serial_port, 'V8,200,100,2\n');
    
    %define state 3: turn on stimulator #1
    fprintf(serial_port, ['V1,' num2str(on_time) ',' num2str(cycle_time) ',3\n']);
    fprintf(serial_port, 'V2,200,100,1\n');
    fprintf(serial_port, 'V3,200,100,1\n');
    fprintf(serial_port, 'V4,200,100,1\n');
    fprintf(serial_port, 'V5,200,100,1\n');
    fprintf(serial_port, 'V6,200,100,1\n');
    fprintf(serial_port, 'V7,200,100,1\n');
    fprintf(serial_port, 'V8,200,100,1\n');
    
    %define state 4: turn on stimulator #2
    fprintf(serial_port, 'V1,200,100,2\n');
    fprintf(serial_port, ['V2,' num2str(on_time) ',' num2str(cycle_time) ',4\n']);
    fprintf(serial_port, 'V3,200,100,2\n');
    fprintf(serial_port, 'V4,200,100,2\n');
    fprintf(serial_port, 'V5,200,100,2\n');
    fprintf(serial_port, 'V6,200,100,2\n');
    fprintf(serial_port, 'V7,200,100,2\n');
    fprintf(serial_port, 'V8,200,100,2\n');
    
    %define state 5: turn on stimulator #1 ans #2
    fprintf(serial_port, ['V1,' num2str(on_time) ',' num2str(cycle_time) ',5\n']);
    fprintf(serial_port, ['V2,' num2str(on_time) ',' num2str(cycle_time) ',5\n']);
    fprintf(serial_port, 'V3,200,100,2\n');
    fprintf(serial_port, 'V4,200,100,3\n');
    fprintf(serial_port, 'V5,200,100,3\n');
    fprintf(serial_port, 'V6,200,100,3\n');
    fprintf(serial_port, 'V7,200,100,3\n');
    fprintf(serial_port, 'V8,200,100,3\n');
    
    %define state 10: turn everything off
    fprintf(serial_port, 'V1,200,100,10\n');
    fprintf(serial_port, 'V2,200,100,10\n');
    fprintf(serial_port, 'V3,200,100,10\n');
    fprintf(serial_port, 'V4,200,100,10\n');
    fprintf(serial_port, 'V5,200,100,10\n');
    fprintf(serial_port, 'V6,200,100,10\n');
    fprintf(serial_port, 'V7,200,100,10\n');
    fprintf(serial_port, 'V8,200,100,10\n');
    
    ok = 1;