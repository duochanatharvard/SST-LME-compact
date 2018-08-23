function output = HM_figure_pair_wise_sig_and_time_series(do_NpD,case_id)

    % *****************
    % Set Parameters **
    % *****************
    if 1,
        nation_list = {'DE','GB','US','JP','RU','NL','GL'};
        varname = 'SST';
        method = 'Bucket';
        yr_start = 1850;
        env = 1;
        alpha  = 0.1;
    end

    date_mark = '20180725';

    % ********************************************************
    % Read in the input and add up the effects to be tested **
    % ********************************************************
    [test_mean,test_random,out] = HM_function_sig_read_data...
                                        (varname,method,do_NpD,yr_start,case_id,env);

    if do_NpD == 1, % change US 110 -> US 281
        out.unique_grp(find(ismember(out.unique_grp,['US',110],'rows')),:) = ['US',281];
        list = unique(out.unique_grp,'rows');
        [~,I] = ismember(list,out.unique_grp,'rows');
        out.unique_grp = out.unique_grp(I,:);
        test_mean = test_mean(:,I);
        test_random = test_random(:,I,:);
    end

    % ********************************************************
    % Test2: Pair-wise test for decks with in big nations   **
    % ********************************************************
    nation_list = {'NL','GB','US','DE','JP','RU','Global'};
    if do_NpD == 1,
        nat_list = 1:6;
    else
        nat_list = 7;
    end
    for ct = nat_list

        Target = nation_list{ct};

        clear('list')
        if ~strcmp(Target,'Global'),
            list = find(ismember(out.unique_grp(:,1:2),Target,'rows'));
        else
            list = 1:size(out.unique_grp,1);
        end

        % Do the test ...
        clear('tab')
        tab = nan(numel(list),numel(list),5);
        for i = 1:numel(list)
            for j = i+1:numel(list)
                out_sig = HM_function_sig(test_mean,test_random,list([i j]));
                tab(i,j,:) = [out_sig.p_val; out_sig.raw; out_sig.QC; out_sig.Z_stats; out_sig.sd];
            end
        end
        sig = tab(:,:,1) < alpha;
        group = out.unique_grp(list,:);
        disp(['Significant pairs: ',num2str(nnz(sig))])
        disp(['Total pairs: ',num2str(nnz(~isnan(tab(:,:,1))))])
        output.num_sig_pairs = nnz(sig);
        output.num_total_pairs = nnz(~isnan(tab(:,:,1)));

        if 1,
            % Plot the comparison ...
            HM_function_sig_figure_cmp(tab(:,:,2),sig,group,Target,ct);
            dir_save = HM_OI('save_figure_method');
            if strcmp(Target,'Global'),  set(gca,'fontsize',10);  end
            file_save = [dir_save,date_mark,'_Significant_test_',Target,'_start_',...
                                         num2str(yr_start),'_case_',num2str(case_id),'.png'];
            CDF_save(1,'png',300,file_save);


            % Plot time series ...
            if ~strcmp(Target,'Global'),
                figure(2);clf; hold on;
                l = any(sig,1) | any(sig,2)';
                HM_function_sig_figure_ts(test_random(:,list,:),group,l,ct,Target);
                file_save = [dir_save,date_mark,'_time_series_',Target,'_start_',...
                              num2str(yr_start),'_case_',num2str(case_id),'.png'];
                CDF_save(2,'png',300,file_save);
            end
        end
    end

    % ******************************************************************************
    % This is to summarize all the subpanels into one figure ***********************
    % ******************************************************************************
    if 1,
        if do_NpD == 1,

            nation_list = {'NL','GB','US','DE','JP','RU','Global'};
            clear('a')
            for i = 1:6
                file = [dir_save,date_mark,'_Significant_test_',nation_list{i},'_start_1850_case_',num2str(case_id),'.png'];
                a(:,:,:,i) = imread(file);
            end

            b = a(350:end-800,100:end-200,:,:);
            c = [b(:,:,:,1) b(:,:,:,2);b(:,:,:,3) b(:,:,:,4); b(:,:,:,5) b(:,:,:,6)];
            d = ones(size(a(end-800:end-500,100:end-200,:,1)))*255;
            d = uint8([d d]);
            d(:,1200+[1:2401],:) = a(end-800:end-500,100:end-200,:,1);
            picture = [c;d];
            imwrite(picture,[dir_save,date_mark,'_SUM_sig_case_',num2str(case_id),'.png'])

            clear('a')
            for i = 1:6
                file = [dir_save,date_mark,'_time_series_',nation_list{i},'_start_1850_case_',num2str(case_id),'.png'];
                if ct == 1 && i == 6,
                    temp = a(:,:,:,1);
                    temp(:) = 255;
                    a(:,:,:,i) = temp;
                else
                    a(:,:,:,i) = imread(file);
                end
            end
            b = a(200:end-250,150:end-150,:,:);
            c = [b(:,:,:,1) b(:,:,:,2);b(:,:,:,3) b(:,:,:,4); b(:,:,:,5) b(:,:,:,6)];
            picture = [c];
            imwrite(picture,[dir_save,date_mark,'_SUM_time_series',num2str(case_id),'.png'])

        end
    end
    % cd('/Users/zen/Research/Git_Code/Homo/')
end
