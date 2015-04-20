function demo1_041715
% demo1 for apparent motion - temporal - voluntary control
% 128 frames from 1st frame to 2nd frame (2134 ms)
% 

freq = 48000;
duration = 1/60;
freq_h = 1480;
freq_l = 460;
t = 0:1/freq:duration; 

AssertOpenGL;

InitializePsychSound;

pahandle = PsychPortAudio('Open', [], [], 4, freq,1);

beep_h = sin(2.*pi.*freq_h.*t);
beep_l = sin(2.*pi.*freq_l.*t);

PsychPortAudio('FillBuffer', pahandle, beep_h);

t=NaN(100,1);
for i=1:100
    t(i) = PsychPortAudio('Start', pahandle, 1, 0, 1);
end
end