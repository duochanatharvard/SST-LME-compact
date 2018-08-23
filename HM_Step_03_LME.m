%% A script that run LME model for intercomparison

% **************************
% Customizable Parameters **
% **************************
do_correct = 0;     % 0: i.i.d pairs   1: hetero SST variance and correlated pairs
do_NpD     = 1;     % 0: nation-level  1: deck-level hierarchical model
N_sample   = 10000; % number of random samples for significant test
do_fast    = 0;     % 1: skip binning and compute LME from binned file

% *******************
% Fixed Parameters **
% *******************
varname = 'SST';
method = 'Bucket';
do_refit = 0;
do_eqwt = 1;
do_kent = 0;
do_trim = 0;
P = HM_lme_exp_para(varname,method);
yr_start = 1850;
app_exp = HM_function_set_case(do_correct,do_eqwt,do_kent,do_trim,[]);

% ******
% O/I **
% ******
if ~exist('env','var'),
    env = 1;            % 1 means on odyssey
end

dir_home = HM_OI('home',env);
app = ['HM_',varname,'_',method];
if app(end)=='_', app(end)=[]; end
app(end+1) = '/';
dir_load = [dir_home,app];

% ***********************
% Prepare output files **
% ***********************
dir_bin  = [dir_load,HM_OI('LME_run')];
file_bin = [dir_bin,'BINNED_',app(1:end-1),'_yr_start_',num2str(yr_start),...
            '_deck_level_',num2str(do_NpD),'_',app_exp,'.mat'];
file_lme = [dir_bin,'LME_',app(1:end-1),'_yr_start_',num2str(yr_start),...
            '_deck_level_',num2str(do_NpD),'_',app_exp,'.mat'];

% ******************************
% Binning and compute the LME **
% ******************************
if do_fast == 0,
    [BINNED,W_X,Stats] = HM_lme_bin(varname,method,do_NpD,yr_start,do_refit,...
                                    do_correct,do_eqwt,do_kent,do_trim,[],env);
    save(file_bin,'BINNED','W_X','Stats','-v7.3');
end

if do_NpD == 0,
    [out,lme] = HM_lme_fit(file_bin,N_sample,0);
else
    [out,lme] = HM_lme_fit_hierarchy(file_bin,N_sample,0,1,1);
end
save(file_lme,'out','lme','-v7.3')
