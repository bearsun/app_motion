% Example 3 - shows key-response times from auditory onset
% written for Psychtoolbox 3  by Aaron Seitz 1/2012

[window, rect]=Screen('OpenWindow',0);  % open screen
ListenChar(2); %makes it so characters typed don?t show up in the command window
HideCursor(); %hides the cursor
    KbName('UnifyKeyNames'); %used for cross-platform compatibility of keynaming
    KbQueueCreate; %creates cue using defaults
    KbQueueStart;  %starts the cue
[wavedata freq  ] = wavread('./cow.wav'); % load sound file
InitializePsychSound(1); %inidializes sound driver...the 1 pushes for low latency
pahandle = PsychPortAudio('Open', [], [], 2, freq, 1, 0); % opens sound buffer...requests high-precision timing and stereo
PsychPortAudio('FillBuffer', pahandle, wavedata'); % loads data into buffer

for trial=1:5 %runs 5 trials
    starttime=GetSecs +rand +.5 %jitters prestim interval between .5 and 1.5 seconds
     PsychPortAudio('Start', pahandle,1,starttime); %starts sound at starttime (timing should be calibrated)
    endtime=KbQueueWait();  %waits for a key-press

    RTtext=sprintf('Response Time =%1.2f secs',endtime-starttime); %makes feedback string
    DrawFormattedText(window,RTtext,'center'  ,'center',[255 0 255]); %shows RT
    vbl=Screen('Flip',window); %swaps backbuffer to frontbuffer
    Screen('Flip',window,vbl+1); %erases feedback after 1 second
end
ListenChar(0); %makes it so characters typed do show up in the command window
ShowCursor(); %shows the cursor
Screen('CloseAll'); %Closes Screen


