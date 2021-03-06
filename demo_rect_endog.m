function demo_rect_endog
% tested 6/24/15, for this code, audio goes 7-8 ms ahead of schedule
% upadted 7/28/15, updated to 2 half hour sessions, with more conditions on
% each side as anchor point (pre should be high on bias, post should be no
% bias.
% demo for apparent motion - temporal - voluntary control
% horizontal vs. vertical apparent motion with endogenous auditory cue
% 128 frames from 1st frame to 2nd frame (2134 ms)
% High tone for horizontal, low tone for vertical
% response: left for vertical, right for horizontal
% small ecc: .49 vd    small sti: .22 vd
%
% Mossbridge, J. A., Ortega, L., Grabowecky, M., & Suzuki, S. (2013). Rapid
% volitional control of apparent motion during percept generation.
% Attention, Perception, & Psychophysics, 75(7), 1486-1495.

%% some parameters
clc;
AssertOpenGL;
Priority(1);

timingadjustment = .007; %according to previous test, audio seems to go 7ms ahead of video

env = 'lab';

if strcmp(env, 'lab')
    monitorh=30; %12;% in cm
    distance=55; %25;% in cm
    mainscreen=1;
elseif strcmp(env, 'lap')
    monitorh=19;
    distance=45;
    mainscreen=0;
else
    error('pls input env');
end

sid = input('subject initial?','s');
group = input('group?');
session = input('session?');

if group == 1
    tones = {'High', 'Low'};
    motions = {'Horizontal', 'Vertical'};
elseif group == 2
    tones = {'High', 'Low'};
    motions = {'Vertical', 'Horizontal'};
end

framerate=Screen('FrameRate',mainscreen);
% delays=[0,17,34,67]; %cue lag time
% fdelays=round(delays*framerate/1000);
leads = [-533, -133, 0, 16, 33, 67, 133, 533, NaN, Inf];
catchlead = -533;
% leads = [0, 17, 34, 67, 133, 267, 533, 1067];
fleads = round(leads*framerate/1000);
catchflead = round(catchlead * framerate / 1000);
isi=2134; % in ms
fisi=round(isi/framerate);
ntrialspercond = 16;
ntrialsperblock = numel(leads) * ntrialspercond;
if session == 1
    nblocks = 1; % 3 exp blocks, including the 2nd session
elseif session == 2
    nblocks = 2;
else
    error('wrong session number');
end

gray = [128 128 128];
black = [0 0 0];
yellow = [255 255 0];
white = [255 255 255];
red = [128 0 0];
fxcolor = yellow;
bgcolor = black;
sticolor = white;
decc = .49;
dfixsize = .05;
dsize = .22;

% Keyboard setting
kspace = KbName('space'); kesc = KbName('Escape');
kleft = KbName('Left'); kright = KbName('Right');
kdown = KbName('Down');kup=KbName('Up');
kreturn=KbName('Return');
kback = KbName('BackSpace');
possiblekn = [kleft, kright];

% beep loading
freq = 48000;
duration = 1/60;
freq_h = 1480;
freq_l = 460;

InitializePsychSound(1); %with low-latency

pahandle = PsychPortAudio('Open', [], [], [], freq,1);
% Level 1 (the default) means: Try to get the lowest latency that is possible
% under the constraint of reliable playback, freedom of choice for all parameters
% and interoperability with other applications. Level 2 means: Take full control
% over the audio device, even if this causes other sound applications to fail or
% shutdown. Level 3 means: As level 2, but request the most aggressive settings
% for the given device. Level 4: Same as 3, but fail if device can't meet the
% strictest requirements.

beep_h = MakeBeep(freq_h,duration,freq);
beep_l = MakeBeep(freq_l,duration,freq);

bufferhandle_h = PsychPortAudio('CreateBuffer', pahandle, beep_h);
bufferhandle_l = PsychPortAudio('CreateBuffer', pahandle, beep_l);


%% warm up
PsychPortAudio('FillBuffer', pahandle, bufferhandle_h);
PsychPortAudio('Start', pahandle, 1, 0, 1);
PsychPortAudio('Stop', pahandle, 1);
PsychPortAudio('FillBuffer', pahandle, bufferhandle_l);
PsychPortAudio('Start', pahandle, 1, 0, 1);
PsychPortAudio('Stop', pahandle, 1);

%% open window and buffers
[mainwin,mrect]=Screen('OpenWindow', mainscreen, bgcolor);
[frame1,f1rect]=Screen('OpenOffscreenWindow',mainscreen, bgcolor);
[frame2,f2rect]=Screen('OpenOffscreenWindow',mainscreen, bgcolor);
[frame3,f3rect]=Screen('OpenOffscreenWindow',mainscreen, bgcolor);
[frame4,f4rect]=Screen('OpenOffscreenWindow',mainscreen, bgcolor);

%% opposite mapping for catch trial vs. tones
% not supported in 2011a

%  catchframe = container.Map([bufferhandle_h, bufferhandle_l],[frame3, frame4]); %cue for vertical / horizontal motion

%% visual angle to pixels
pecc = ang2pix(decc);
psize = ang2pix(dsize);
pnoisepatch = round((pecc+psize)*2);
pfixsize = ang2pix(dfixsize);
xy1 = [-pecc/sqrt(2),pecc/sqrt(2);-pecc/sqrt(2),pecc/sqrt(2)];
xy2 = [-xy1(1,:); xy1(2,:)];
xy3 = [xy1(1,:); zeros(1,2)]; % cue for vertical motion
xy4 = [zeros(1,2); xy1(2,:)];  % cue for horizontal motion

f1center=[f1rect(3)/2, f1rect(4)/2];
f2center=[f2rect(3)/2, f2rect(4)/2];
f3center=[f3rect(3)/2, f3rect(4)/2];
f4center=[f4rect(3)/2, f4rect(4)/2];

%% construct frame1 and frame2
Screen('gluDisk', frame1, fxcolor, f1center(1), f1center(2), pfixsize);
Screen('DrawDots', frame1, xy1, psize, sticolor, f1center);

Screen('gluDisk', frame2, fxcolor, f2center(1), f2center(2), pfixsize);
Screen('DrawDots', frame2, xy2, psize, sticolor, f2center);

%% extra frame for catch trial
Screen('gluDisk', frame3, fxcolor, f3center(1), f3center(2), pfixsize);
Screen('DrawDots', frame3, xy3, psize, sticolor, f3center);

Screen('gluDisk', frame4, fxcolor, f4center(1), f4center(2), pfixsize);
Screen('DrawDots', frame4, xy4, psize, sticolor, f4center);

%% frames for noise mask
tex = NaN(framerate,1);

for i = 1:framerate
    noiseimg=(50*randn(pnoisepatch) + 128);
    tex(i)=Screen('MakeTexture', mainwin, noiseimg);
end

%% initialize every thing at the beginning of session 1

%% generate trial sequence
[sfleads, sbufferhandles] = BalanceTrials(ntrialsperblock*nblocks, 1, fleads, [bufferhandle_h, bufferhandle_l]);

%% empty loader for behavioral results
behav = struct('keypressed', [], ...
    'flead', [], ...
    'tone', []);

timing = struct('status',[],...
    'Flip_delay',[], ...
    'Flip_exe', [],...
    'vonset', [],...
    'aonset', [],...
    'av_offset', [],...
    'scheduled_av_offset', []);

if session == 1    
    %% generate passive viewing block
    [sfleads_pre, sbufferhandles_pre] = BalanceTrials(ntrialsperblock, 1, fleads, [bufferhandle_h, bufferhandle_l]);
    behav_pre = behav;
    timing_pre = timing;
    nblocks = nblocks + 1;
end

%% Loop for trials
for block = 1:nblocks
    
    if block == 1 && session == 1
        DrawFormattedText(mainwin, 'Block No.1,\n Please report the direction of motion,\nLeft key for horizontal, right key for vertical.\nPress space to start.\n', 'center', 'center', white);
    else
        DrawFormattedText(mainwin, ['Block No.', num2str(block),'\n Please try to see the motion cued by the tone (High for ', motions{1},', low for ', motions{2},')\n and report the actual direction of motion,\nLeft key for horizontal, right key for vertical.\nPress space to start.\n'], 'center', 'center', white);
    end
    
    Screen('Flip',mainwin);
    KbStrokeWait;
    
    for subtrial = 1:ntrialsperblock
        if session == 1
            if block == 1
                trial = subtrial;
                flead = sfleads_pre(trial);
                bufferhandle = sbufferhandles_pre(trial);
            else
                trial = subtrial + (block - 2) * ntrialsperblock;
                flead=sfleads(trial);
                bufferhandle=sbufferhandles(trial);
            end
        else
            trial = subtrial + (block - 1) * ntrialsperblock;
            flead=sfleads(trial);
            bufferhandle=sbufferhandles(trial);
        end
        
        if isinf(flead)
            if group == 1
                if bufferhandle == bufferhandle_h
                    catchframe = frame3;
                elseif bufferhandle == bufferhandle_l
                    catchframe = frame4;
                end
            elseif group == 2
                if bufferhandle == bufferhandle_h
                    catchframe = frame4;
                elseif bufferhandle == bufferhandle_l
                    catchframe = frame3;
                end
            end
        end
        
        if ~isnan(flead)
            PsychPortAudio('FillBuffer', pahandle, bufferhandle);
        end
        
        [~,vonset1] = Screen('Flip', mainwin);
        Screen('DrawTexture', mainwin, frame1);
        
        if ~isnan(flead)&&~isinf(flead)
            playtime = vonset1 + (fisi+flead+1) / framerate;
            playtime = playtime + timingadjustment;
            PsychPortAudio('Start', pahandle, 1, playtime, 0);
        end
        
        if isinf(flead)
            playtime = vonset1 + (fisi+catchflead+2) / framerate;
            playtime = playtime + timingadjustment;
            PsychPortAudio('Start', pahandle, 1, playtime, 0);
        end
        
        Screen('Flip', mainwin, [], 1);
        for d = 1:(fisi-2)
            Screen('Flip', mainwin, [], 2);
        end
        
        if isinf(flead)
            Screen('Flip', mainwin);
            Screen('DrawTexture', mainwin, catchframe);
        end
        
        vbl1 = Screen('Flip', mainwin);
        Screen('DrawTexture', mainwin, frame2);
        %     % schedule beep after the app_motion
        %     PsychPortAudio('Start', pahandle, 1, vonset1 + (fdelay+1) / framerate, 0);
        [vbl,vonset, t1] = Screen('Flip', mainwin);
        
        if isnan(flead)
            audio_onset = NaN;
            stat = NaN;
        else
            while 1
                if GetSecs > t1 + .8  %%make sure the sound is played? force to wait for .8 sec
                    break;
                end
            end
            stat = PsychPortAudio('GetStatus', pahandle);
            audio_onset = stat.StartTime;
        end
        
        % collect behav data
        while 1
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown
                if sum(keyCode) == 1
                    if keyCode(kesc)
                        session_end;return
                    elseif any(keyCode(possiblekn))
                        keypressed=find(keyCode);
                        %                         if isnan(flead)
                        %                             rt = timeSecs - vonset;
                        %                         else
                        %                             rt = timeSecs - audio_onset;
                        %                         end
                        break;
                    end
                end
            end
        end
        
        if bufferhandle == bufferhandle_l
            tone = 'low';
        elseif bufferhandle == bufferhandle_h
            tone = 'high';
        else
            error('bufferhandle not matching any handle');
        end
        
        % save data
        if block == 1 && session == 1
            behav_pre(trial) = struct('keypressed', keypressed, ...
                'flead', flead, ...
                'tone', tone);
            
            timing_pre(trial)=struct('status', stat, ...
                'Flip_delay', vbl - vbl1, ...
                'Flip_exe', t1 - vbl, ...
                'vonset', vonset, ...
                'aonset', audio_onset, ...
                'av_offset', (audio_onset - vonset) * 1000.0, ...
                'scheduled_av_offset', flead / framerate * 1000.0);
        else
            behav(trial) = struct('keypressed', keypressed, ...
                'flead', flead, ...
                'tone', tone);
            
            timing(trial)=struct('status', stat, ...
                'Flip_delay', vbl - vbl1, ...
                'Flip_exe', t1 - vbl, ...
                'vonset', vonset, ...
                'aonset', audio_onset, ...
                'av_offset', (audio_onset - vonset) * 1000.0, ...
                'scheduled_av_offset', flead / framerate * 1000.0);
        end
        %     fprintf('Flip delay = %6.6f secs.  Flipend vs. VBL %6.6f\n', vbl - vbl1, t1-vbl);
        %     fprintf('Delay start vs. played: %6.6f secs, offset %f\n', t3 - t2, offset);
        %
        %     fprintf('Buffersize %i, xruns = %i, playpos = %6.6f secs.\n', status.BufferSize, status.XRuns, status.PositionSecs);
        %     fprintf('Screen    expects visual onset at %6.6f secs.\n', vonset);
        %     fprintf('PortAudio expects audio onset  at %6.6f secs.\n', audio_onset);
        fprintf('Expected audio-visual delay    is %6.6f msecs.\n', (audio_onset - vonset)*1000.0);
        
        if isinf(flead)
            fprintf('Scheduled audio-visual delay    is %6.6f msecs.\n', catchlead)
        else
            fprintf('Scheduled audio-visual delay    is %6.6f msecs.\n', flead / framerate * 1000.0);
        end
        
        %% noise patch
        for i = Shuffle(1:framerate)
            Screen('DrawTexture', mainwin, tex(i));
            Screen('Flip', mainwin);
        end
        Screen('Flip', mainwin);
        KbStrokeWait;
    end
    %     if block == 5
    %         DrawFormattedText(mainwin,['End of block ' num2str(block) '. Press to start the next.'], 'center','center', black);
    %     else
    %         DrawFormattedText(mainwin,['End of block ' num2str(block) '. High tone for horizontal, low tone for vertical. Press to start the next.'], 'center','center', black);
    %     end
    %     Screen('Flip', mainwin);
    %     KbStrokeWait;
end

session_end;

    function pixels=ang2pix(ang)
        pixpercm=mrect(4)/monitorh;
        pixels=tand(ang/2)*distance*2*pixpercm;
    end

    function session_end
        PsychPortAudio('Close');
        ShowCursor;
        sca;
        if session == 1
            save(['res_s1_', sid, datestr(now,'mmddyy'), '.mat'],'behav','timing','behav_pre','timing_pre');
        elseif session == 2
            save(['res_s2_', sid, datestr(now,'mmddyy'), '.mat'],'behav','timing');
        end
        return
    end
end
