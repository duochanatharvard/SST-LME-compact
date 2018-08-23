% *********************************************************
% A function that tests the significance of difference   **
%   between on group and all other groups being compared **
% *********************************************************
function out_sig = HM_function_sig(test_mean,test_random,list)

    % *****************
    % Set Parameters **
    % *****************
    N_yr = size(test_mean,1);
    N_itr = numel(list);
    N_rnd = size(test_random,3);
    if N_itr == 2, N_itr = 1; end

    % ***********************************************
    % Look up table for generating indexing matirx **
    % ***********************************************
    sub_look_up = test_mean(:,list);

    % ***************************
    % Vectorize the comparison **
    % ***************************
    sub_mean = reshape(test_mean(:,list),N_yr * nnz(list),1);
    sub_random = reshape(test_random(:,list,:),N_yr * nnz(list),N_rnd);

    % ********************************
    % Compute the covariance matrix **
    % ********************************
    sub_anm = sub_random - repmat(nanmean(sub_random,2),1,N_rnd);
    sub_cov = sub_anm * sub_anm' / (N_rnd-1);

    clear('out')
    for col = 1:N_itr

        clear('vector','temp_mean','temp_cov')
        % ******************************
        % Prepare the indexing matrix **
        % ******************************
        M_id = - sub_look_up./sub_look_up;
        M_id(:,col) = - M_id(:,col);
        M_id(M_id(:,col) ~= 1,:) = nan;
        M_id(:,col) = M_id(:,col) - nansum(M_id,2);

        % ********************************
        % Prepare the comparison vector **
        % ********************************
        vector = M_id(:) ./ nansum(M_id(:,col));
        vector(isnan(vector)) = 0;
        out_sig.QC(col) = any(vector);

        % ********************
        % Remove nan values **
        % ********************
        temp_mean = sub_mean;
        temp_mean(isnan(sub_mean)) = 0;
        temp_cov = sub_cov;
        temp_cov(isnan(sub_cov))   = 0;

        % **************************************
        % Compute the significance statistics **
        % **************************************
        out_sig.raw(col) = vector' * temp_mean;
        out_sig.sd(col) = sqrt(vector' * temp_cov * vector);
        out_sig.Z_stats(col) = abs(out_sig.raw(col)) ./ out_sig.sd(col);
        out_sig.p_val(col) = (1 - normcdf(out_sig.Z_stats(col)))*2;
    end
end
