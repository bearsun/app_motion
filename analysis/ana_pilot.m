function res = ana_pilot(matfile)
% analyze pilot data
% 
% high tone for horizontal, low tone for vertical
% left for horizontal, right for vertical
% flead could be [-32   -16    -8     0     8    16    32]
%
% kh = load('/home/liwei/Documents/studies/app_motion/data/res_kh_051815_rect_endog.mat');
% ls = load('/home/liwei/Documents/studies/app_motion/data/res_ls_051815_rot_endog.mat');

fleadpools = [-32, -16, -8, 0, 8, 16, 32];
data = load(matfile);
res.behav = ana(data.behav);
res.prebe = ana(data.behav_pre);
res.postbe = ana(data.behav_post);

    function res = ana(d)
        % analysis behav data
        t = struct2table(d);
        res = NaN(size(fleadpools));
        for kflead = 1:numel(fleadpools)
            flead = fleadpools(kflead);
            consist = sum(t.flead == flead & ismember(t.tone,'high') & ...
                t.keypressed == 114) + sum(t.flead == flead & ...
                ismember(t.tone, 'low') & t.keypressed == 115);
            inconsist = sum(t.flead == flead & ismember(t.tone,'high') & ...
                t.keypressed == 115) + sum(t.flead == flead & ...
                ismember(t.tone, 'low') & t.keypressed == 114);
            res(kflead) = consist - inconsist;
        end
    end

end