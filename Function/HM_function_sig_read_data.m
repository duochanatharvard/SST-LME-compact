function [test_mean,test_random,out] = HM_function_sig_read_data(varname,method,do_NpD,yr_start,case_id,env)

    % *******************
    % Input and Output **
    % *******************
    if ~exist('env','var'),
        env = 1;                             % 1 means on odyssey
    end

    % ****************************
    % Find the LME file to read **
    % ****************************

    dir_home = HM_OI('home',env);
    app = ['HM_',varname,'_',method];
    if app(end)=='_', app(end)=[]; end
    app(end+1) = '/';
    dir_lme = [dir_home,HM_OI('LME_run',env,app)];
    % dir_lme(end) = []; dir_lme = [dir_lme,'_linear_model_structure/'];

    switch case_id,
    case 1,
        file_lme = [dir_lme,'LME_',app(1:end-1),'_yr_start_',num2str(yr_start),...
                    '_deck_level_',num2str(do_NpD),'_eq_wt.mat'];
    case 2,
        file_lme = [dir_lme,'LME_',app(1:end-1),'_yr_start_',num2str(yr_start),...
                    '_deck_level_',num2str(do_NpD),'_cor_err.mat'];

    case 3,
        file_lme = [dir_lme,'LME_',app(1:end-1),'_yr_start_',num2str(yr_start),...
                    '_deck_level_',num2str(do_NpD),'_cor_err_kent.mat'];

    case 4,
        file_lme = [dir_lme,'LME_',app(1:end-1),'_yr_start_',num2str(yr_start),...
                    '_deck_level_',num2str(do_NpD),'_cor_err_trim.mat'];

    case 5,
        file_lme = [dir_lme,'LME_',app(1:end-1),'_yr_start_',num2str(yr_start),...
                    '_deck_level_',num2str(do_NpD),'_cor_err_coarse_sp.mat'];

    case 6,
        file_lme = [dir_lme,'LME_',app(1:end-1),'_yr_start_',num2str(yr_start),...
                    '_deck_level_',num2str(do_NpD),'_cor_err_coarse_tim.mat'];

    case 7,
        file_lme = [dir_lme,'LME_',app(1:end-1),'_yr_start_',num2str(yr_start),...
                    '_deck_level_',num2str(do_NpD),'_cor_err_down.mat'];

    case 8,
        file_lme = [dir_lme,'LME_',app(1:end-1),'_yr_start_',num2str(yr_start),...
                    '_deck_level_',num2str(do_NpD),'_cor_err_power_0.75.mat'];

    case 9,
        file_lme = [dir_lme,'LME_',app(1:end-1),'_yr_start_',num2str(yr_start),...
                    '_deck_level_',num2str(do_NpD),'_eq_wt_new.mat'];

    case 101,
        file_lme = ['/Volumes/My Passport Pro/Hvd_SST/LME_model_structure_2.mat'];

    case 102,
        file_lme = ['/Volumes/My Passport Pro/Hvd_SST/LME_model_structure_3.mat'];
    end

    disp(file_lme)

    % ********************************************************
    % Read in the input and add up the effects to be tested **
    % ********************************************************
    clear('out','test_mean','test_random')
    load(file_lme,'out')

    if do_NpD == 1,
        out.bias_decade = out.bias_decade_dck;
        out.bias_decade_rnd = out.bias_decade_rnd_dck;
        out.bias_fixed  = out.bias_fixed_dck;
        out.bias_fixed_random = out.bias_fixed_rnd_dck;
    end

    NN = size(out.bias_decade,1);
    out.bias_decade = out.bias_decade(1:NN,:);
    out.bias_decade_rnd = out.bias_decade_rnd(1:NN,:,:);

    N_group = size(out.unique_grp,1);
    N_rnd   = size(out.bias_fixed_random,1);

    if do_NpD == 1,
        temp_id = find(out.unique_grp(:,3) == 732 & ~ismember(out.unique_grp(:,1:2),'RU','rows'));
        out.bias_decade(1:10,temp_id) = nan;
        out.bias_decade_rnd(1:10,temp_id) = nan;

        for i = 1:1:numel(temp_id)
            l = ismember(out.unique_grp(:,1:2),out.unique_grp(temp_id(i),1:2),'rows');
            ll = nansum(~isnan(out.bias_decade(:,l)),2) == 1;
            out.bias_decade(ll,l) = nan;
            out.bias_decade_rnd(ll,l,:) = nan;
        end
        clear('temp_id')
    end

    fixed_mean   = repmat(out.bias_fixed,1,NN)';
    fixed_random = repmat(reshape(out.bias_fixed_random',1,N_group,N_rnd),NN,1,1);
    test_mean = fixed_mean + out.bias_decade;
    test_random = fixed_random + out.bias_decade_rnd;

end
