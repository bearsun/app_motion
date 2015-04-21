function demo1_041715(env)
% demo1 for apparent motion - temporal - voluntary control
% 128 frames from 1st frame to 2nd frame (2134 ms)
%
%
% Mossbridge, J. A., Ortega, L., Grabowecky, M., & Suzuki, S. (2013). Rapid
% volitional control of apparent motion during percept generation. 
% Attention, Perception, & Psychophysics, 75(7), 1486-1495.

%% some parameters
AssertOpenGL;

global monitorh
global distance
global mrect

if strcmp(env, 'lab')
    monitorh=30; %12;% in cm
    distance=55; %25;% in cm
elseif strcmp(env, 'lap')
    monitorh=19;
    distance=45;
else
    error('pls input env');
end

mainscreen=0;
framerate=Screen('FrameRate',mainscreen);
delays=[0,17,34,67,133,267,533,1067]; %cue lag time
fdelays=round(delays*framerate/1000);
isi=1067; % in ms
fisi=round(isi/framerate);

gray = [128 128 128];u
black = [0 0 0];
bgcolor = gray;
sticolor = black;
decc = .49;
dsize = .22;

% Keyboard setting
kspace = KbName('space'); kesc = KbName('Escape');
kleft = KbName('Left'); kright = KbName('Right');
kdown = KbName('Down');kup=KbName('Up');
kreturn=KbName('Return');
kback = KbName('BackSpace');

% beep loading
freq = 48000;
duration = 1/60;
freq_h = 1480;
freq_l = 460;

InitializePsychSound(1); %with low-latency

pahandle_h = PsychPortAudio('Open', [], [], 3, [],1);
pahandle_l = PsychPortAudio('Open', [], [], 3, [],1);
% Level 1 (the default) means: Try to get the lowest latency that is possible
% under the constraint of reliable playback, freedom of choice for all parameters
% and interoperability with other applications. Level 2 means: Take full control
% over the audio device, even if this causes other sound applications to fail or
% shutdown. Level 3 means: As level 2, but request the most aggressive settings
% for the given device. Level 4: Same as 3, but fail if device can't meet the
% strictest requirements. 

beep_h = MakeBeep(freq_h,duration,freq);
beep_l = MakeBeep(freq_l,duration,freq);

PsychPortAudio('FillBuffer', pahandle_h, beep_h);
PsychPortAudio('FillBuffer', pahandle_l, beep_l);

%% warm up
PsychPortAudio('Start', pahandle_h, 1, 0, 1);
PsychPortAudio('Stop', pahandle_h, 1);
PsychPortAudio('Start', pahandle_l, 1, 0, 1);
PsychPortAudio('Stop', pahandle_l, 1);

%% generate trial sequence
[sfdelays, spahandles] = BalanceTrials(ntrials, 1, fdelays, [pahandle_h, pahandle_l]);


%% open window and buffers
[mainwin,mrect]=Screen('OpenWindow', mainscreen, bgcolor);
[frame1,f1rect]=Screen('OpenOffscreenWindow',mainscreen, bgcolor);
[frame2,f2rect]=Screen('OpenOffscreenWindow',mainscreen, bgcolor);

%% visual angle to pixels
pecc = ang2pix(decc);
psize = ang2pix(dsize);
xy1 = [0,0;-pecc,pecc];
xy2 = xy1([2,1],:);
f1center=[f1rect(2)/2, f1rect(4)/2];
f2center=[f2rect(2)/2, f2rect(4)/2];
%% construct frame1 and frame2
Screen('gluDisk', frame1, black, f1center(1), f1center(2), psize);
Screen('DrawDots', frame1, xy1, psize, black, f1center);

Screen('gluDisk', frame2, black, f2center(1), f2center(2), psize);
Screen('DrawDots', frame2, xy, psize, black, f2center);

KbStrokeWait;
%% Loop for trials
for trial = 1:ntrials
    fdelay=sfdelays(trial);
    pahandle=spahandles(trial);
    Screen('DrawTexture', mainwin, frame1);
    Screen('Flip', mainwin, [], 1);
    for d = 1:(fisi-2)
        Screen('Flip', mainwin, [], 2);
    end
    [vbl1,vonset] = Screen('Flip', mainwin);
    Screen('DrawTexture', mainwin, frame2);
    % schedule beep
    PsychPortAudio('Start', pahandle, 1, vonset + (fdelay+1) * framerate, 0);
    [vbl2,vonset] = Screen('Flip', mainwin);
    
    
end

    function pixels=ang2pix(ang)
        pixpercm=rect(4)/monitorh;
        pixels=tand(ang/2)*distance*2*pixpercm;
    end
end