function draw_instructions_and_wait(text,bkg,win,ws)

Screen('FillRect', win, bkg);
Screen('Flip', win);
   
DrawFormattedText(win, text, 'center', 'center',255, 60);
Screen('Flip', win);
waitForKB_linux('space');
Screen('FillRect', win, bkg);
Screen('Flip', win);
WaitSecs(ws);