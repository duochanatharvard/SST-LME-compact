% BINNED,W_X,Stats] = HM_lme_bin(file_load,do_region,do_season,do_decade,...
%                                   yr_start,yr_interval,do_NpD,varname,sigma_obs,env)
% You can choose to assign sigma_obs, if not, it will be read from the Kent et al...
% Also, the defaulf value of env is 1, which means on Odyssey

function [BINNED,W_X,Stats] = HM_lme_bin(varname,method,do_NpD,yr_start,do_refit,...
                                         do_correct,do_eqwt,do_kent,do_trim,sigma_obs,env)

     % *******************
     % Debug            **
     % *******************
     if 0,
         varname = 'SST';
         method = 'Bucket';
         do_NpD = 1;
         yr_start = 1850;
         do_refit = 0;
         do_correct = 0;
         do_eqwt = 1;
         do_kent = 0;
         do_trim = 0;
         sigma_obs = [];
         env = 0;
     end

     % *******************
     % Input and Output **
     % *******************
     if ~exist('env','var'),
         env = 1;             % 1 means on odyssey
     end
     dir_home = HM_OI('home',env);
     app = ['HM_',varname,'_',method];
     if app(end)=='_', app(end)=[]; end
     app(end+1) = '/';
     dir_load = [dir_home,app];

    % *****************
    % Set Parameters **
    % *****************
    P = HM_lme_exp_para(varname,method);
    id_lon = 8;
    id_lat = 9;
    id_utc = 6;
    id_nat = 20:21;
    id_dck = 10;
    id_sst = 14;
    id_sst_clim = 15;
    id_da  = 43;
    N_data = 21;

    % ****************
    % Read the data **
    % ****************
    disp(['Load in the data ...'])
    if do_refit == 0,
        yr_text  = [num2str(P.yr_list(1)),'_',num2str(P.yr_list(end))];
        file_load = [dir_load,'SUM_',app(1:end-1),'_Screen_Pairs_c_once_',yr_text,'.mat'];
        load(file_load);

    else

        dir_bin  = [dir_load,HM_OI('LME_run')];
        app_exp = HM_function_set_case(do_correct,do_eqwt,do_kent,do_trim,sigma_obs);
        file_load = [dir_bin,'ANOVA_',app(1:end-1),'_yr_start_',num2str(yr_start),...
                  '_deck_level_',num2str(do_NpD),'_',app_exp,'.mat'];

        load(file_load,'data_dif_lme_in','BIAS_1','BIAS_2',...
            'location','kind_cmp_1','kind_cmp_2');
        DATA([id_lon id_lat id_utc],:) = location(1:3,:);
        DATA([id_lon id_lat id_utc] + N_data,:) = location(4:6,:);
        date = datevec((location(3,:)+location(6,:))/2/24);
        DATA(1,:) = date(:,1)';
        DATA(2,:) = date(:,2)';
        if size(kind_cmp_1,2) == 3,
            DATA([id_nat id_dck],:) = kind_cmp_1';
            DATA([id_nat id_dck]+N_data,:) = kind_cmp_2';
        else
            DATA([id_nat],:) = kind_cmp_1';
            DATA([id_nat]+N_data,:) = kind_cmp_2';
        end
    end

    % ************************
    % Removing small groups **
    % ************************
    if do_refit == 0,
        disp(['Removing small groups'])
        [point_uni,~,J] = unique([DATA(id_nat,:)';DATA(id_nat+N_data,:)'],'rows');
        J_hist = hist(J,1:1:max(J));
        remove_list = J_hist < 500;
        logic_remove = ismember(J,find(remove_list));
        logic_remove = reshape(logic_remove,numel(logic_remove)/2,2);
        logic_remove_pair = any(logic_remove,2);
        DATA(:,logic_remove_pair) = [];

        % Collect statistics ...
        Stats(1) = size(DATA,2);
    end

    % ***************************************
    % Compute the climatic variance of SST **
    % ***************************************
    disp(['Compute the climatic variance ...'])
    var_clim = HM_lme_var_clim(DATA(id_lon,:),DATA(id_lon + N_data,:),...
                               DATA(id_lat,:),DATA(id_lat + N_data,:),...
                               DATA(id_utc,:),DATA(id_utc + N_data,:),...
                               DATA(2,:),varname,env);

    % ********************************************
    % Compute the observational variance of SST **
    % ********************************************
    disp(['Compute the observational variance ...'])
    if do_kent == 1,
        var_obs  = HM_lme_var_obs(DATA(id_lon,:),DATA(id_lon + N_data,:),...
                        DATA(id_lat,:),DATA(id_lat + N_data,:),varname,method);
        if strcmp(varname,'SST'),
            if strcmp(method,'Bucket'),
                if do_NpD == 1,
                    var_rnd  = var_obs .* 0.34;
                    var_ship = var_obs .* 0.66;
                else
                    var_rnd  = var_obs .* 0.41;
                    var_ship = var_obs .* 0.59;
                end
            elseif strcmp(method,'ERI'),
                if do_NpD == 1,
                    var_rnd  = var_obs .* 0.42;
                    var_ship = var_obs .* 0.58;
                else
                    var_rnd  = var_obs .* 0.15;
                    var_ship = var_obs .* 0.85;
                end
            end
       elseif strcmp(varname,'NMAT'),
            if do_NpD == 1,
                var_rnd  = var_obs .* 0.61;
                var_ship = var_obs .* 0.39;
            else
                var_rnd  = var_obs .* 0.59;
                var_ship = var_obs .* 0.41;
            end
        end
    elseif isempty(sigma_obs),
        if do_correct == 1,
            [var_rnd,var_ship] = HM_lme_var_obs_cd(varname,method,do_NpD);
            var_rnd  = ones(1,size(DATA,2)) * var_rnd;
            var_ship = ones(1,size(DATA,2)) * var_ship;
            var_obs  = var_rnd + var_ship;
        else
            var_obs  = ones(size(var_clim));
        end
    else
        var_obs  = ones(size(var_clim)) * sigma_obs.^2;
        var_rnd  = var_obs/2;
        var_ship = var_obs/2;
    end

    if do_correct == 1,
        [~,~,pow] = HM_lme_var_obs_cd(varname,method,do_NpD);
    end

    % **********************************
    % Assign weights to pairs of SSTs **
    % **********************************
    if do_eqwt == 1,
        weight = ones(1,size(DATA,2));
    else
        weight = 1./(2*var_obs + var_clim);
    end

    % **********************************
    % Assign Effects to pairs of SSTs **
    % **********************************
    disp(['Assigning effects ...'])
    % ------------------------
    % Assign regional effect |
    % ------------------------
    if P.do_region == 1,
        mx = HM_function_mean_period([DATA(id_lon,:); DATA(id_lon + N_data,:)],360);
        my = nanmean([DATA(id_lat,:); DATA(id_lat + N_data,:)],1);
        group_region = HM_lme_effect_regional(mx,my,5);

        % -----------------------------------------------
        % remove pairs that are too close to the coasts |
        % -----------------------------------------------
        if do_refit == 0,
            clear('logic_remove')
            logic_remove = isnan(group_region) | isnan(weight);
            weight(logic_remove) = [];
            var_obs(logic_remove) = [];
            var_clim(logic_remove) = [];
            DATA(:,logic_remove) = [];
            group_region(logic_remove) = [];
            clear('dt','dx','dy','index','logic_remove')
        end

    else
        group_region = zeros(1,size(DATA,2));
    end

    if do_refit == 0,
        % Collect statistics ...
        Stats(2) = size(DATA,2);
    end

    % ------------------------
    % Assign seasonal effect |
    % ------------------------
    my = nanmean([DATA(id_lat,:); DATA(id_lat + N_data,:)],1);
    if P.do_season == 1,
        group_season = HM_lme_effect_seasonal(my,DATA(2,:));
    else
        group_season = zeros(1,size(DATA,2));
    end

    % -----------------------
    % Assign decadal effect |
    % -----------------------
    if P.do_decade == 1,
        group_decade = HM_lme_effect_decadal(DATA(1,:),yr_start,P.yr_interval);
    else
        group_decade = zeros(1,size(DATA,2));
    end
    clear('mx','my')

    % ************************************
    % Prepare for the data to be binned **
    % ************************************
    clear('data_cmp')
    kind_cmp_1 = DATA([id_nat id_dck],:)';
    kind_cmp_2 = DATA([id_nat id_dck] + N_data,:)';

    if do_refit == 0,
        kind_cmp_1 = HM_function_preprocess_deck(kind_cmp_1,1);
        kind_cmp_2 = HM_function_preprocess_deck(kind_cmp_2,1);
    end

    if do_NpD == 0,
        kind_cmp_1 = kind_cmp_1(:,1:2);
        kind_cmp_2 = kind_cmp_2(:,1:2);
    end

    % **********************************
    % Find the data to be binned      **
    % **********************************
    if do_refit == 1,
        data_cmp = data_dif_lme_in - (BIAS_1(1,:) - BIAS_2(1,:))';
        clear('data_dif_lme_in','BIAS_1','BIAS_2')
    else
        data_cmp = DATA(id_sst,:)' - DATA(id_sst_clim,:)' - ...
                   DATA(id_sst + N_data,:)' + DATA(id_sst_clim + N_data,:)' - ...
                   DATA(id_da,:)' + DATA(id_da + 1,:)';
    end

    % **********************************
    % Trim the data by 3 sigmas       **
    % **********************************
    if do_trim == 1,
        do_grid_season = 1;
        mx = HM_function_mean_period([DATA(id_lon,:); DATA(id_lon + N_data,:)],360);
        my = nanmean([DATA(id_lat,:); DATA(id_lat + N_data,:)],1);
        mt = nanmean([DATA(id_utc,:); DATA(id_utc + N_data,:)],1);
        l = HM_lme_trim(data_cmp,do_grid_season,mx,my,mt);%*
        kind_cmp_1 = kind_cmp_1(l,:);        %*
        kind_cmp_2 = kind_cmp_2(l,:);        %*
        group_decade = group_decade(l);      %*
        group_region = group_region(l);      %*
        group_season = group_season(l);      %*
        var_obs  = var_obs(l);               %*
        var_rnd  = var_rnd(l);               %*
        var_ship = var_ship(l);              %*
        var_clim = var_clim(l);              %*
        weight   = weight(l);                %*
        data_cmp = data_cmp(l);              %*
    end

    % **********************************
    % Generate BINs                   **
    % **********************************
    [kind_bin_uni,~,group_nation] = unique([kind_cmp_1 kind_cmp_2],'rows');

    [kind_binned_uni,~,~] = unique([group_decade', group_nation,...
                                    group_region', group_season'],'rows');

    disp(['A total of ',num2str(size(kind_binned_uni,1)),' combinations'])

    if do_refit == 0,
        % Collect statistics ...
        Stats(3) = size(kind_binned_uni,1);

        % ***************************************
        % Compute the weights in the constrain **
        % ***************************************
        [J_uni,~,J_points] = unique([kind_cmp_1;kind_cmp_2],'rows');
        var_obs = [var_obs var_obs];
        for i = 1:size(J_uni,1)
            W_X(1,i) = nansum(1./var_obs(J_points == i));
        end
        W_X = W_X./repmat(nansum(W_X,2),1,size(W_X,2));
    end

    % *********************************
    % Bin the pairs in a fast manner **
    % *********************************
    disp(['Binning ...'])
    BINNED = [];
    for ct_nat = 1:max(group_nation)

        if rem(ct_nat,100) == 0,
            disp(['Starting the ',num2str(ct_nat),'th Pairs'])
        end

        if nnz(group_nation == ct_nat) > 0,

            clear('temp_weight_ly_nat','temp_data_cmp_ly_nat','temp_group_region_ly_nat','temp_decade_uni')
            clear('temp_group_decade_ly_nat','temp_group_season_ly_nat','temp_group_nation_ly_nat')
            temp_weight_ly_nat       = weight(group_nation == ct_nat);
            temp_data_cmp_ly_nat     = data_cmp(group_nation == ct_nat);
            temp_group_region_ly_nat = group_region(group_nation == ct_nat);
            temp_group_season_ly_nat = group_season(group_nation == ct_nat);
            temp_group_decade_ly_nat = group_decade(group_nation == ct_nat);
            temp_var_clim_ly_nat     = var_clim(group_nation == ct_nat);
            if do_correct == 1,
                temp_var_rnd_ly_nat      = var_rnd(group_nation == ct_nat);
                temp_var_ship_ly_nat     = var_ship(group_nation == ct_nat);
            end

            clear('temp_decade_uni','J_decade')
            [temp_decade_uni,~,J_decade] = unique(temp_group_decade_ly_nat);

            for ct_dcd = 1:max(J_decade)

                if nnz(J_decade == ct_dcd) > 0,

                    clear('temp_weight_ly_dcd','temp_data_cmp_ly_dcd','temp_group_region_ly_dcd')
                    clear('temp_group_decade_ly_dcd','temp_group_season_ly_dcd','temp_group_nation_ly_dcd')
                    temp_weight_ly_dcd       = temp_weight_ly_nat(J_decade == ct_dcd);
                    temp_data_cmp_ly_dcd     = temp_data_cmp_ly_nat(J_decade == ct_dcd);
                    temp_group_region_ly_dcd = temp_group_region_ly_nat(J_decade == ct_dcd);
                    temp_group_season_ly_dcd = temp_group_season_ly_nat(J_decade == ct_dcd);
                    temp_var_clim_ly_dcd     = temp_var_clim_ly_nat(J_decade == ct_dcd);
                    if do_correct == 1,
                        temp_var_rnd_ly_dcd      = temp_var_rnd_ly_nat(J_decade == ct_dcd);
                        temp_var_ship_ly_dcd     = temp_var_ship_ly_nat(J_decade == ct_dcd);
                    end

                    clear('temp_region_uni','J_region')
                    [temp_region_uni,~,J_region] = unique(temp_group_region_ly_dcd);

                    for ct_reg = 1:max(J_region)

                        if nnz(J_region == ct_reg) > 0,

                            clear('temp_weight_ly_reg','temp_data_cmp_ly_reg','temp_group_region_ly_reg')
                            clear('temp_group_decade_ly_reg','temp_group_season_ly_reg','temp_group_nation_ly_reg')
                            temp_weight_ly_reg       = temp_weight_ly_dcd(J_region == ct_reg);
                            temp_data_cmp_ly_reg     = temp_data_cmp_ly_dcd(J_region == ct_reg);
                            temp_group_season_ly_reg = temp_group_season_ly_dcd(J_region == ct_reg);
                            temp_var_clim_ly_reg     = temp_var_clim_ly_dcd(J_region == ct_reg);
                            if do_correct == 1,
                                temp_var_rnd_ly_reg      = temp_var_rnd_ly_dcd(J_region == ct_reg);
                                temp_var_ship_ly_reg     = temp_var_ship_ly_dcd(J_region == ct_reg);
                            end

                            clear('temp_season_uni','J_season')
                            [temp_season_uni,~,J_season] = unique(temp_group_season_ly_reg);

                            for ct_sea = 1:max(J_season)

                                if nnz(J_season == ct_sea) > 0,

                                    clear('temp_weight_ly_sea','temp_data_cmp_ly_sea','temp_group_region_ly_sea')
                                    clear('temp_group_decade_ly_sea','temp_group_season_ly_sea','temp_group_nation_ly_sea')
                                    temp_weight_ly_sea       = temp_weight_ly_reg(J_season == ct_sea);
                                    temp_data_cmp_ly_sea     = temp_data_cmp_ly_reg(J_season == ct_sea);
                                    temp_var_clim_ly_sea     = temp_var_clim_ly_reg(J_season == ct_sea);
                                    if do_correct == 1,
                                        temp_var_rnd_ly_sea      = temp_var_rnd_ly_reg(J_season == ct_sea);
                                        temp_var_ship_ly_sea     = temp_var_ship_ly_reg(J_season == ct_sea);
                                    end

                                    clear('temp_w','temp_y','temp_ww','temp_binned')
                                    temp_w = temp_weight_ly_sea ./ nansum(temp_weight_ly_sea);
                                    temp_y = nansum(temp_data_cmp_ly_sea' .* temp_w);

                                    temp_n = numel(temp_weight_ly_sea);
                                    temp_var_clim_bin = nanmean(temp_var_clim_ly_sea) ./ temp_n;

                                    if do_correct == 0,
                                        temp_ww = nansum(temp_weight_ly_sea);
                                    else
                                        temp_var_rnd_bin  = 2 * nanmean(temp_var_rnd_ly_sea)  ./ temp_n;
                                        temp_var_ship_bin = 2 * nanmean(temp_var_ship_ly_sea) ./ (temp_n.^pow);
                                        temp_sigma_2 = temp_var_clim_bin + temp_var_rnd_bin + temp_var_ship_bin;
                                        temp_ww = 1./temp_sigma_2;
                                    end

                                    if do_refit == 0,
                                        temp_binned = [temp_y, temp_ww, temp_decade_uni(ct_dcd), ...
                                                       temp_region_uni(ct_reg), temp_season_uni(ct_sea), ...
                                                       kind_bin_uni(ct_nat,:),temp_n];

                                    else
                                        temp_binned = [temp_y, temp_ww, temp_decade_uni(ct_dcd), ...
                                                       temp_region_uni(ct_reg), temp_season_uni(ct_sea), ...
                                                       kind_bin_uni(ct_nat,:),temp_n,temp_var_clim_bin];
                                    end
                                    BINNED = [BINNED; temp_binned];
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    % *************************
    % Post-processing BINNED **
    % *************************
    clear('data_cmp','kind_cmp_1','kind_cmp_2','group_season',...
          'group_region','group_decade','weigh_use')
    logic = isnan(BINNED(:,1)) | isnan(BINNED(:,2));
    BINNED(logic,:) = [];

    if do_NpD == 1,
        kind_cmp_1 = double(BINNED(:,6:8));
        kind_cmp_2 = double(BINNED(:,9:11));
    else
        kind_cmp_1 = double(BINNED(:,6:7));
        kind_cmp_2 = double(BINNED(:,8:9));
    end

    logic = all(kind_cmp_1 == kind_cmp_2,2);
    BINNED(logic,:) = [];

    if do_refit == 0,
        Stats(4) = size(BINNED,1);
    end

    if do_refit == 1,
        Stats = [];
        W_X = [];
    end

end
