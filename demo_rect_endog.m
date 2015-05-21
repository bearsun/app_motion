function demo_rect_endog(env)
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
AssertOpenGL;
Priority(1);

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

sid = input('identifier for this session?','s');

framerate=Screen('FrameRate',mainscreen);
% delays=[0,17,34,67]; %cue lag time
% fdelays=round(delays*framerate/1000);
leads = [-400, -267, -200, -133, -67, 0, 533, NaN];
% leads = [0, 17, 34, 67, 133, 267, 533, 1067];
fleads = round(leads*framerate/1000);
isi=2134; % in ms
fisi=round(isi/framerate);
ntrialspercond = 16;
ntrialsperblock = numel(leads) * ntrialspercond;
nblocks = 4; % with two passive viewing blocks pre and post

gray = [128 128 128];
black = [0 0 0];
bgcolor = gray;
decc = .49;
dfixsize = .22;
dsize = .22;

% Keyboard setting
kspace = KbName('space'); kesc = KbName('Escape');
kleft = KbName('Left'); kright = KbName('Right');
kdown = KbName('Down');kup=KbName('Up');
kreturn=KbName('Return');
kback = KbName('BackSpace');
possiblekn = [kleft, kright]; % left for counterclockwise, right for
% clockwise

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

%% generate trial sequence
[sfleads, sbufferhandles] = BalanceTrials(ntrialsperblock*nblocks, 1, fleads, [bufferhandle_h, bufferhandle_l]);

%% generate passive viewing blocks
[sfleads_pre, sbufferhandles_pre] = BalanceTrials(ntrialsperblock, 1, fleads, [bufferhandle_h, bufferhandle_l]);
[sfleads_post, sbufferhandles_post] = BalanceTrials(ntrialsperblock, 1, fleads, [bufferhandle_h, bufferhandle_l]);

%% open window and buffers
[mainwin,mrect]=Screen('OpenWindow', mainscreen, bgcolor);
[frame1,f1rect]=Screen('OpenOffscreenWindow',mainscreen, bgcolor);
[frame2,f2rect]=Screen('OpenOffscreenWindow',mainscreen, bgcolor);

%% visual angle to pixels
pecc = ang2pix(decc);
psize = ang2pix(dsize);
pnoisepatch = round((pecc+psize)*2);
pfixsize = ang2pix(dfixsize);
xy1 = [-pecc/sqrt(2),pecc/sqrt(2);-pecc/sqrt(2),pecc/sqrt(2)];
xy2 = [-xy1(1,:); xy1(2,:)];
f1center=[f1rect(3)/2, f1rect(4)/2];
f2center=[f2rect(3)/2, f2rect(4)/2];
%% construct frame1 and frame2
Screen('gluDisk', frame1, black, f1center(1), f1center(2), pfixsize);
Screen('DrawDots', frame1, xy1, psize, black, f1center);

Screen('gluDisk', frame2, black, f2center(1), f2center(2), pfixsize);
Screen('DrawDots', frame2, xy2, psize, black, f2center);

%% empty loader for behavioral results
behav = struct('keypressed', [], ...
        'flead', [], ...
        'tone', [], ...
        'rt', []);
behav_pre = behav;
behav_post = behav;
    
timing = struct('status',[],...
    'Flip_delay',[], ...
    'Flip_exe', [],...
    'vonset', [],...
    'aonset', [],...
    'av_offset', [],...
    'scheduled_av_offset', []);
timing_pre = timing;
timing_post = timing;

KbStrokeWait;
%% Loop for trials
for block = 1:(nblocks+2)
    for subtrial = 1:ntrialsperblock
        if block == 1
            trial = subtrial;
            flead = sfleads_pre(trial);
            bufferhandle = sbufferhandles_pre(trial);
        elseif block == 6
            trial = subtrial;
            flead = sfleads_post(trial);
            bufferhandle = sbufferhandles_post(trial);
        else
            trial = subtrial + (block - 2) * ntrialsperblock;
            flead=sfleads(trial);
            bufferhandle=sbufferhandles(trial);
        end
        
        if ~isnan(flead)
            PsychPortAudio('FillBuffer', pahandle, bufferhandle);
        end
        
        [~,vonset1] = Screen('Flip', mainwin);
        Screen('DrawTexture', mainwin, frame1);
        
        if ~isnan(flead)
            playtime = vonset1 + (fisi-flead+1) / framerate;
            PsychPortAudio('Start', pahandle, 1, playtime, 0);
        end
        
        Screen('Flip', mainwin, [], 1);
        for d = 1:(fisi-2)
            Screen('Flip', mainwin, [], 2);
        end
        vbl1 = Screen('Flip', mainwin);
        Screen('DrawTexture', mainwin, frame2);
        %     % schedule beep after the app_motion
        %     PsychPortAudio('Start', pahandle, 1, vonset1 + (fdelay+1) / framerate, 0);
        [vbl,vonset, t1] = Screen('Flip', mainwin);
        
        if isnan(flead)
            audio_onset = NaN;
        else
            stat = PsychPortAudio('GetStatus', pahandle);
            audio_onset = stat.StartTime;
            while 1
                if GetSecs > audio_onset  %%make sure the sound is played? force to wait for 1 sec
                    break;
                end
            end
        end
        
        % collect behav data
        while 1
            [keyIsDown, timeSecs, keyCode] = KbCheck;
            if keyIsDown
                nKeys = sum(keyCode);
                if nKeys == 1
                    if keyCode(kesc)
                        session_end;return
                    elseif any(keyCode(possiblekn))
                        keypressed=find(keyCode);
                        if isnan(flead)
                            rt = timeSecs - vonset;
                        else
                            rt = timeSecs - audio_onset;
                        end
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
        if block == 1
            behav_pre(trial) = struct('keypressed', keypressed, ...
                'flead', flead, ...
                'tone', tone, ...
                'rt', rt);
            
            timing_pre(trial)=struct('status', stat, ...
                'Flip_delay', vbl - vbl1, ...
                'Flip_exe', t1 - vbl, ...
                'vonset', vonset, ...
                'aonset', audio_onset, ...
                'av_offset', abs(audio_onset - vonset) * 1000.0, ...
                'scheduled_av_offset', flead / framerate * 1000.0);
        elseif block == 6
            behav_post(trial) = struct('keypressed', keypressed, ...
                'flead', flead, ...
                'tone', tone, ...
                'rt', rt);
            
            timing_post(trial)=struct('status', stat, ...
                'Flip_delay', vbl - vbl1, ...
                'Flip_exe', t1 - vbl, ...
                'vonset', vonset, ...
                'aonset', audio_onset, ...
                'av_offset', abs(audio_onset - vonset) * 1000.0, ...
                'scheduled_av_offset', flead / framerate * 1000.0);
        else
            behav(trial) = struct('keypressed', keypressed, ...
                'flead', flead, ...
                'tone', tone, ...
                'rt', rt);
            
            timing(trial)=struct('status', stat, ...
                'Flip_delay', vbl - vbl1, ...
                'Flip_exe', t1 - vbl, ...
                'vonset', vonset, ...
                'aonset', audio_onset, ...
                'av_offset', abs(audio_onset - vonset) * 1000.0, ...
                'scheduled_av_offset', flead / framerate * 1000.0);
        end
        %     fprintf('Flip delay = %6.6f secs.  Flipend vs. VBL %6.6f\n', vbl - vbl1, t1-vbl);
        %     fprintf('Delay start vs. played: %6.6f secs, offset %f\n', t3 - t2, offset);
        %
        %     fprintf('Buffersize %i, xruns = %i, playpos = %6.6f secs.\n', status.BufferSize, status.XRuns, status.PositionSecs);
        %     fprintf('Screen    expects visual onset at %6.6f secs.\n', vonset);
        %     fprintf('PortAudio expects audio onset  at %6.6f secs.\n', audio_onset);
        fprintf('Expected audio-visual delay    is %6.6f msecs.\n', abs(audio_onset - vonset)*1000.0);
        fprintf('Scheduled audio-visual delay    is %6.6f msecs.\n', flead / framerate * 1000.0);
        
        %% noise patch
        for i = 1:framerate
            noiseimg=(50*randn(pnoisepatch) + 128);
            tex=Screen('MakeTexture', mainwin, noiseimg);
            Screen('DrawTexture', mainwin, tex);
            Screen('Flip', mainwin);
        end
        
        KbStrokeWait;
    end
    if block == 5
        DrawFormattedText(mainwin,['End of block ' num2str(block) '. Press to start the next.'], 'center','center', black);
    else
        DrawFormattedText(mainwin,['End of block ' num2str(block) '. High tone for horizontal, low tone for vertical. Press to start the next.'], 'center','center', black);
    end
    Screen('Flip', mainwin);
    KbStrokeWait;
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
        save(['res_' sid '.mat'],'behav','timing','behav_pre','timing_pre','behav_post','timing_post');
        return
    end
end
