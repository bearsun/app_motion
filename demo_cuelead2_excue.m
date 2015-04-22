function demo_cuelead2_excue(env)
% demo1 for apparent motion - temporal - voluntary control
% 128 frames from 1st frame to 2nd frame (2134 ms)
% instead of tone cue, use subliminal cue on the midpoint of ap trail
% cue length: 50 ms
% cue size: 2.18 vd (half of the sti, 1/4 in area)
% large ecc: 8.71 vd    large sti: 4.36 vd
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
sid = [];
sid = input('identifier for this session?');

framerate=Screen('FrameRate',mainscreen);
% delays=[0,17,34,67]; %cue lag time
% fdelays=round(delays*framerate/1000);
leads = [-533, -267, -133, -67, 0, 67, 133, 533];
fleads = round(leads*framerate/1000);
isi=2134; % in ms
fisi=round(isi/framerate);
ntrialsperblock = 128;
nblocks = 4; % with two passive viewing blocks pre and post
cuelast = 50; % in ms
fcuelast = cuelast * framerate / 1000;

gray = [128 128 128];
black = [0 0 0];
bgcolor = gray;
decc = 8.71;
dfixsize = .22;
dsize = 4.36;
dcuesize = dsize/2;

% Keyboard setting
kspace = KbName('space'); kesc = KbName('Escape');
kleft = KbName('Left'); kright = KbName('Right');
kdown = KbName('Down');kup=KbName('Up');
kreturn=KbName('Return');
kback = KbName('BackSpace');
possiblekn = [kleft, kright]; % left for counterclockwise, right for
% clockwise

%% generate trial sequence
[sfleads, scue] = BalanceTrials(ntrialsperblock*nblocks, 1, fleads, ['cue_cw', 'cue_ccw']);

%% open window and buffers
[mainwin,mrect]=Screen('OpenWindow', mainscreen, bgcolor);
[frame1,f1rect]=Screen('OpenOffscreenWindow',mainscreen, bgcolor);
[frame2,f2rect]=Screen('OpenOffscreenWindow',mainscreen, bgcolor);
[frame1cw,~]=Screen('OpenOffscreenWindow',mainscreen, bgcolor);
[frame2cw,~]=Screen('OpenOffscreenWindow',mainscreen, bgcolor);
[frame1ccw,~]=Screen('OpenOffscreenWindow',mainscreen, bgcolor);
[frame2ccw,~]=Screen('OpenOffscreenWindow',mainscreen, bgcolor);

%% visual angle to pixels
pecc = ang2pix(decc);
psize = ang2pix(dsize);
pcuesize = ang2pix(dcuesize);
pfixsize = ang2pix(dfixsize);
xy1 = [0,0;-pecc,pecc];
xy2 = xy1([2,1],:);
cue_cw = [pecc/sqrt(2), -pecc/sqrt(2); -pecc/sqrt(2), pecc/sqrt(2)];
cue_ccw = [pecc/sqrt(2), pecc/sqrt(2); -pecc/sqrt(2), -pecc/sqrt(2)];
f1center=[f1rect(3)/2, f1rect(4)/2];
f2center=[f2rect(3)/2, f2rect(4)/2];
%% construct frame1 and frame2
Screen('gluDisk', frame1, black, f1center(1), f1center(2), pfixsize);
Screen('DrawDots', frame1, xy1, psize, black, f1center);

Screen('gluDisk', frame2, black, f2center(1), f2center(2), pfixsize);
Screen('DrawDots', frame2, xy2, psize, black, f2center);

%% frame1, frame2 with different cue
Screen('gluDisk', frame1cw, black, f1center(1), f1center(2), pfixsize);
Screen('DrawDots', frame1cw, xy1, psize, black, f1center);
Screen('DrawDots', frame1cw, cue_cw, pcuesize, black, f1center);

Screen('gluDisk', frame2cw, black, f2center(1), f2center(2), pfixsize);
Screen('DrawDots', frame2cw, xy2, psize, black, f2center);
Screen('DrawDots', frame2cw, cue_cw, pcuesize, black, f2center);

Screen('gluDisk', frame1ccw, black, f1center(1), f1center(2), pfixsize);
Screen('DrawDots', frame1ccw, xy1, psize, black, f1center);
Screen('DrawDots', frame1ccw, cue_ccw, pcuesize, black, f1center);

Screen('gluDisk', frame2ccw, black, f2center(1), f2center(2), pfixsize);
Screen('DrawDots', frame2ccw, xy2, psize, black, f2center);
Screen('DrawDots', frame2ccw, cue_ccw, pcuesize, black, f2center);

%% empty loader for behavioral results
behav = struct('keypressed', [], ...
    'flead', [], ...
    'cue', [], ...
    'rt', []);

behav_pre = struct('keypressed', [], ...
    'rt', []);

behav_post = struct('keypressed', [], ...
    'rt', []);

KbStrokeWait;
%% Loop for trials
for block = 1:(nblocks+2)
    for subtrial = 1:ntrialsperblock
        if block ~= 1 && block ~= nblocks+2
            trial = subtrial + (block - 2) * ntrialsperblock;
            flead = sfleads(trial);
            if strcmp(scue(trial), 'cue_cw')
                frame1cue = frame1cw;
                frame2cue = frame2cw;
            elseif strcmp(scue(trial), 'cue_ccw')
                frame1cue = frame1ccw;
                frame2cue = frame2ccw;
            else
                error('wrong cue seq');
            end
            [cueonset, vonset] = present_with_cue(fisi, flead, fcuelast, mainwin, frame1, frame2, frame1cue, frame2cue);
        else
            trial = subtrial;
            vonset = present_without_cue(fisi, mainwin, frame1, frame2);
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
                        rt = timeSecs - vonset;
                        break;
                    end
                end
            end
        end
        
        % save data
        if block == 1
            behav_pre(trial) = struct('keypressed', keypressed, ...
                'rt', rt);
            
        elseif block == 6
            behav_post(trial) = struct('keypressed', keypressed, ...
                'rt', rt);
            
        else
            behav(trial) = struct('keypressed', keypressed, ...
                'flead', flead, ...
                'actual_flead', (vonset - cueonset) * framerate, ...
                'cue', scue(trial), ...
                'rt', rt);
            
            fprintf('flead %i, actual flead = %6.6f, cue = %s \n', behav(trial).flead, behav(trial).actual_flead, behav(trial).cue);
        end
        
        Screen('Flip', mainwin);
        KbStrokeWait;
    end
    if block == 5
        DrawFormattedText(mainwin,['End of block ' num2str(block) '. Press to start the next.'], 'center','center', white);
    else
        DrawFormattedText(mainwin,['End of block ' num2str(block) '. High tone for clockwise, low tone for counter-clockwise. Press to start the next.'], 'center','center', white);
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
        save(['res_' num2str(sid) '.mat'],'behav','behav_pre','behav_post');
        return
    end

end


function vonset = present_without_cue(fisi, mainwin, frame1, frame2)

present(mainwin, frame1, fisi);
vonset = present(mainwin, frame2, 1);

end


function [cueonset, vonset] = present_with_cue(fisi, flead, fcuelast, mainwin, frame1, frame2, frame1cue, frame2cue)

if flead > 0 % cue lead
    
    present(mainwin, frame1, fisi - flead);
    
    if flead >= fcuelast
        
        cueonset = present(mainwin, frame1cue, fcuelast);
        present(mainwin, frame1, flead-fcuelast);
        vonset = present(mainwin, frame2, 1);
        
    elseif flead < fcuelast
        
        cueonset = present(mainwin, frame1cue, flead);
        vonset = present(mainwin, frame2cue, fcuelast-flead);
        present(mainwin, frame2, 1);
        
    else
        error('flead ? fcuelast');
    end
    
elseif flead == 0 % onset together
    present(mainwin, frame1, fisi);
    vonset = present(mainwin, frame2cue, fcuelast);
    present(mainwin, frame2, 1);
    cueonset = vonset;
    
elseif flead < 0 % cue lag
    
    present(mainwin, frame1, fisi);
    vonset = present(mainwin, frame2, -flead);
    cueonset = present(mainwin, frame2cue, fcuelast);
    present(mainwin, frame2, 1);
    
else
    error('flead ? 0')
end


end

function onset = present(mainwin, frame, t)

if t > 0
    Screen('DrawTexture', mainwin, frame);
    for flip = 1:(t-1)
        if flip == 1
            [~, onset] = Screen('Flip',mainwin,[],1);
        else
            Screen('Flip',mainwin,[],1);
        end
    end
    Screen('Flip',mainwin);
end

end


