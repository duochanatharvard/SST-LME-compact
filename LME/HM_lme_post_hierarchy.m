function out = HM_lme_post_hierarchy(M,lme,unique_nat,unique_grp,do_hierarchy_random,...
                            N_nat,N_groups,do_sampling,do_region,do_season,do_decade)

    N_rnd = do_sampling;
    clear('out')

    % ***********************
    % Assigning parameters **
    % ***********************
    if do_region == 1,
        N_region = M.N_region;
    end
    if do_season == 1,
        N_season = M.N_season;
    end
    if do_decade == 1,
        N_decade = M.N_decade;
    end

    % ****************
    % fixed effects **
    % ****************
    disp('Staring Post Process ...')
    clear('b_fixed','b_fixed_std','b_random','b_random_std')
    clear('bias_temp','bias_std_temp')
    [b_fixed,~,STATS_fixed] = fixedEffects(lme);
    b_fixed_std = STATS_fixed.SE;
    out.bias_fixed = b_fixed(1:end);
    out.bias_fixed_std = b_fixed_std(1:end);
    out.unique_grp = unique_grp;
    out.unique_nat = unique_nat;

    if do_sampling ~= 0,
        out.Covariance_fixed = lme.CoefficientCovariance;
        out.bias_fixed_random = mvnrnd(b_fixed,out.Covariance_fixed,N_rnd);
    end

    N_dck = nnz(M.logic_fixed);
    out.bias_fixed_nat = out.bias_fixed(1:end-N_dck);
    out.bias_fixed_dck = zeros(numel(M.logic_fixed),1);
    out.bias_fixed_dck(M.logic_fixed) = out.bias_fixed(end-N_dck+1:end);

    out.bias_fixed_std_nat = out.bias_fixed_std(1:end-N_dck);
    out.bias_fixed_std_dck = zeros(numel(M.logic_fixed),1);
    out.bias_fixed_std_dck(M.logic_fixed) = out.bias_fixed_std(end-N_dck+1:end);

    out.bias_fixed_rnd_nat = out.bias_fixed_random(:,1:end-N_dck);
    out.bias_fixed_rnd_dck = zeros(N_rnd,numel(M.logic_fixed),1);
    out.bias_fixed_rnd_dck(:,M.logic_fixed) = out.bias_fixed_random(:,end-N_dck+1:end);
    
    % Prepare for the variables for correction that is in the same format
    % as in the nation-only version, and is compatible with all other
    % existing scripts...
    [~,Pos]= ismember(out.unique_grp(:,1:2),out.unique_nat,'rows');
    out.bias_fixed = out.bias_fixed_nat(Pos) + out.bias_fixed_dck;
    out.bias_fixed_random = out.bias_fixed_rnd_nat(:,Pos) + out.bias_fixed_rnd_dck;
    out.bias_fixed_std = sqrt(out.bias_fixed_std_nat(Pos).^2 + out.bias_fixed_std_dck.^2);
    
    % *****************
    % Random effects **
    % *****************
    if M.do_random ~= 0,
        [b_random,b_name,STATS_random] = randomEffects(lme);

        if do_sampling ~= 0,
            % Compute the conditional covariance structure ----------------------------
            O = diag(1 ./ M.W) .* lme.MSE;
            V = zeros(size(M.X_in,1));
            Z_sum = [];
            for i = 1:numel(M.Z_in)
                V = V + M.Z_in{i} * lme.covarianceParameters{i} * M.Z_in{i}';
                Z_sum = [Z_sum M.Z_in{i}];
                N_rnd_eff(i) = size(M.Z_in{i},2);
            end
            V = V + O;
            disp('Computing the Matrix Inversion')
            inv_V = inv(V);
            disp('Matrix Inversion Computed')

            clear('G')
            for i = 1:numel(N_rnd_eff)
                dim = [1:N_rnd_eff(i)] + sum(N_rnd_eff(1:i-1));
                G(dim,dim) = lme.covarianceParameters{i};
            end

            out.Covariance_conditional = G - G * Z_sum' * inv_V * Z_sum * G;

            b_random_std = sqrt(diag(out.Covariance_conditional));
            temp = (out.Covariance_conditional + out.Covariance_conditional')/2;
            b_random_random = mvnrnd(b_random,temp,N_rnd);

        end

        % Prepare to put the things into the field --------------------------------
        [~,~,J]=unique(b_name(:,1));
        for i = 1:max(J)
            BB.bias_temp{i} = b_random(J == i);
            if do_sampling ~= 0,
                BB.bias_std_temp{i} = b_random_std(J == i);
                BB.bias_random_temp{i} = b_random_random(:,J == i);
            end
        end

        % -------------------------------------------------------------------------
        if do_region == 1,
            if do_hierarchy_random == 1,
                temp = HM_lme_post_random(BB,M.logic_region,M.reg_id,...
                                          N_region,N_nat,do_sampling);
                out.bias_region_nat = temp.bias_random;
                if do_sampling ~= 0,
                    out.bias_region_std_nat = temp.bias_random_std;
                    out.bias_region_rnd_nat = temp.bias_random_rnd;
                end
            end
            temp = HM_lme_post_random(BB,M.logic_region_dck,M.reg_id_dck,...
                                      N_region,N_groups,do_sampling);
            out.bias_region_dck = temp.bias_random;
            if do_sampling ~= 0,
                out.bias_region_std_dck = temp.bias_random_std;
                out.bias_region_rnd_dck = temp.bias_random_rnd;
            end
        end

        % -------------------------------------------------------------------------
        if do_season == 1,
            if do_hierarchy_random == 1,
                temp = HM_lme_post_random(BB,M.logic_season,M.sea_id,...
                                          N_season,N_nat,do_sampling);
                out.bias_season = temp.bias_random;
                if do_sampling ~= 0,
                    out.bias_season_std = temp.bias_random_std;
                    out.bias_season_rnd = temp.bias_random_rnd;
                end
            end
            temp = HM_lme_post_random(BB,M.logic_season_dck,M.sea_id_dck,...
                                      N_season,N_groups,do_sampling);
            out.bias_season_dck = temp.bias_random;
            if do_sampling ~= 0,
                out.bias_season_std_dck = temp.bias_random_std;
                out.bias_season_rnd_dck = temp.bias_random_rnd;
            end
        end

        % -------------------------------------------------------------------------
        if do_decade == 1,
            if do_hierarchy_random == 1,
                temp = HM_lme_post_random(BB,M.logic_decade,M.dcd_id,...
                                          N_decade,N_nat,do_sampling);
                out.bias_decade_nat = temp.bias_random;
                if do_sampling ~= 0,
                    out.bias_decade_std_nat = temp.bias_random_std;
                    out.bias_decade_rnd_nat = temp.bias_random_rnd;
                end
            end
            temp = HM_lme_post_random(BB,M.logic_decade_dck,M.dcd_id_dck,...
                                      N_decade,N_groups,do_sampling);
            out.bias_decade_dck = temp.bias_random;
            if do_sampling ~= 0,
                out.bias_decade_std_dck = temp.bias_random_std;
                out.bias_decade_rnd_dck = temp.bias_random_rnd;
            end
        end
    end

    out.MSE = lme.MSE;
    out.Y_hat = lme.fitted;
end
