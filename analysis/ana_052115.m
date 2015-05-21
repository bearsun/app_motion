% pilot analysis
xtres = ana_pilot('data/res_xt_051915_rect_endog.mat');
khres = ana_pilot('data/res_kh_051815_rect_endog.mat');
sfres = ana_pilot('data/res_sf_052115_rect_endog.mat');
lsres = ana_pilot('data/res_ls_051815_rot_endog.mat');

h=plot(khres.dlead, khres.behav, lsres.dlead, -lsres.behav, xtres.dlead, xtres.behav, sfres.dlead, -sfres.behav);
legend(h,'kh','ls','xt','sf');