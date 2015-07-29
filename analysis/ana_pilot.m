function res = ana_pilot(matfile)
% analyze pilot data
% 
% high tone for horizontal, low tone for vertical
% left for horizontal, right for vertical
% flead could be [-32   -16    -8     0     8    16    32]
%
% kh = load('/home/liwei/Documents/studies/app_motion/data/res_kh_051815_rect_endog.mat');
% ls = load('/home/liwei/Documents/studies/app_motion/data/res_ls_051815_rot_endog.mat');
% 
% fleadpools = [-32 -16 -8 0 8 16 32];
% fleadpools = [-32   -24   -16   -12    -8     0    32];
data = load(matfile);
[~,filename,~] = fileparts(matfile);

kleft = KbName('Left');
kright = KbName('Right');

if strcmp(filename(end),'1') %high for horizontal, low for vertical
    kforhigh = kleft; % high -- horizontal -- left key
    kforlow = kright;
elseif strcmp(filename(end),'2') %high for vertical, low for horizontal
    kforhigh = kright; %high -- vertical -- right key
    kforlow = kleft;
else
    error('check filename');
end


uniflead = unique(cat(2, data.behav.flead));
fleadpools = sort(uniflead(~isnan(uniflead)&~isinf(uniflead)));
ntrialspercond = numel(data.behav)/(numel(fleadpools)+2);

res.behav = ana(data.behav);
res.prebe = ana(data.behav_pre);
res.postbe = ana(data.behav_post);
res.dlead = [fleadpools*1000/60, Inf];

    function res = ana(d)
        % analysis behav data
        t = struct2table(d);
        res = NaN(size(fleadpools));
        for kflead = 1:numel(fleadpools)
            flead = fleadpools(kflead);
            consist = sum(t.flead == flead & ismember(t.tone,'high') & ...
                t.keypressed == kforhigh) + sum(t.flead == flead & ...
                ismember(t.tone, 'low') & t.keypressed == kforlow);
            inconsist = sum(t.flead == flead & ismember(t.tone,'high') & ...
                t.keypressed == kforlow) + sum(t.flead == flead & ...
                ismember(t.tone, 'low') & t.keypressed == kforhigh);
            res(kflead) = (consist - inconsist)/ntrialspercond;
        end
        
        %flead = Inf;
        consist = sum(isinf(t.flead) & ismember(t.tone,'high') & ...
            t.keypressed == kforhigh) + sum(isinf(t.flead) & ...
            ismember(t.tone, 'low') & t.keypressed == kforlow);
        inconsist = sum(isinf(t.flead) & ismember(t.tone,'high') & ...
            t.keypressed == kforlow) + sum(isinf(t.flead) & ...
            ismember(t.tone, 'low') & t.keypressed == kforhigh);
        res(kflead+1) = (consist - inconsist)/ntrialspercond;
    end

end