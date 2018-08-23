function output = HM_figure_Bias_fixed_and_yearly(case_id,do_science)

    % *****************
    % Set Parameters **
    % *****************
    if ~exist('do_science','var'), do_science = 0; end
    if 1,
        nation_list = {'DE','GB','US','JP','RU','NL','GL'};
        varname = 'SST';
        method = 'Bucket';
        yr_start = 1850;
        env = 1;
        alpha    = 0.1;

        if do_science == 0, % parameters for method paper
            do_NpD = 0;
            yint = 5;
            ysrt = 1850;
            do_sort = 0;
            num_col = 1;
        else                % parameters for science paper
            do_NpD = 1;
            yint = 1;
            app_version = 'cor_err';
            do_sort = 1;
            num_col = 3;
            ysrt = 1850;
        end
    end

    % *******************************************************
    % Read in the data to be plotted                       **
    % *******************************************************
    if yint == 5,
        [test,~,out] = HM_function_sig_read_data(varname,...
                                                method,do_NpD,yr_start,case_id,env);
    elseif yint == 1,
        [test,~,out] = HM_function_sig_read_data_yearly(varname,...
                                                method,do_NpD,app_version,env);
    end

    % *******************************************************
    % Find nations that are to be marked by '*' or '**'    **
    % *******************************************************
    if yint == 1,
        temp = out.bias_fixed_random;
        temp  = temp - repmat(nanmean(temp,1),size(temp,1),1);
        out.bias_fixed_std = sqrt(nansum(temp.^2,1) / (size(temp,1) - 1))';
    end
    Z_stats = (1 - normcdf(abs(out.bias_fixed ./ out.bias_fixed_std)))*2;
    Sig_Nat_90 = Z_stats < alpha;
    Sig_Nat_99 = Z_stats < 0.01;
    List_Nat = out.unique_grp;

    disp(['90% level significant: ',num2str(nnz(Sig_Nat_90))])
    disp(['99% level significant: ',num2str(nnz(Sig_Nat_99))])

    if do_NpD == 0
        output.num_sig_90_nat = nnz(Sig_Nat_90);
        output.num_sig_99_nat = nnz(Sig_Nat_99);
        output.nat_sig_90 =     List_Nat(Sig_Nat_90,:);
        output.nat_sig_99 =     List_Nat(Sig_Nat_99,:);

        l = find(ismember(out.unique_grp,...
            ['DE';'GB';'JP';'NL';'RU';'US';156,156],'rows'));
        output.bias_fixed_6_nat = out.bias_fixed(l);
        output.bias_fixed_range = [min(out.bias_fixed) max(out.bias_fixed)];
    else
        output = [];
    end

    if 1,
        % *******************************************************
        % Prepare Data to be plotted                           **
        % *******************************************************
        if do_sort == 1;
            [~,I] = sort(out.bias_fixed);
            test = test(:,I);
            Sig_Nat_90 = Sig_Nat_90(I);
            Sig_Nat_99 = Sig_Nat_99(I);
            List_Nat   = List_Nat(I,:);

            l = nansum(~isnan(test),1) > 5;
            test = test(:,l);
            Sig_Nat_90 = Sig_Nat_90(l);
            Sig_Nat_99 = Sig_Nat_99(l);
            List_Nat   = List_Nat(l,:);
        end

        % *******************************************************
        % Find the color scheme                                **
        % *******************************************************
        col = colormap_CD([ .5 .67; .05 0.93],[.95 .2],[0 0],10);
        cc = discretize(test',[-inf -0.45:0.05:0.45 inf]);

        % *******************************************************
        % Generate Figures                                     **
        % *******************************************************
        figure(1);clf;hold on;
        num_row = 20;
        pic = test';
        if do_NpD == 0,
            out = CDF_layout([num_row,3],{[1 18 1 3],[num_row num_row 1 3]});
        else
            out = CDF_layout([num_row,3],{[1 18 1 1],[1 18 2 2],[1 18 3 3],[num_row num_row 1 3]});
        end
        for i = 1:size(pic,1)
            [p1,p2] = ind2sub([ceil(size(test,2)/num_col), num_col],i);

            subplot(num_row,3,out{p2}),
            for j = 1:size(pic,2)
                if ~isnan(cc(i,j)),
                    patch(ysrt + [0 1 1 0]*yint + yint * (j-1),[-1 -1 1 1]*.35 - p1,...
                            col(cc(i,j),:),'linest','none');
                end
            end

            if Sig_Nat_99(i),
                surfix = '** ';
            elseif Sig_Nat_90(i),
                surfix = '* ';
            else
                surfix = '';
            end

            if do_NpD == 0,
                if all(List_Nat(i,1) > 100),
                    y_label_text{i} = [surfix,'D ',num2str(List_Nat(i,1))];
                else
                    y_label_text{i} = [surfix,char(List_Nat(i,1:2))];
                end
                set(gca,'ytick',[-ceil(size(test,2)/num_col):1:-1],'yticklabel',fliplr(y_label_text));
                set(gca,'fontsize',8);
            else
                if all(List_Nat(i,1) > 100),
                    y_label_text{i,p2} = [surfix,'---- Dck ',num2str(List_Nat(i,1))];
                else
                    y_label_text{i,p2} = [surfix,char(List_Nat(i,1:2)),' Dck ',num2str(List_Nat(i,3))];
                end
                set(gca,'ytick',[-ceil(size(test,2)/num_col):1:-1],'yticklabel',flipud(y_label_text(:,p2)));
                set(gca,'fontsize',10);
            end

            set(gca,'xtick',1850:10:2010,'xticklabel',{'1850','','','','','1900','','','','','1950','','','','','2000',''});
            if do_science == 0,
                CDF_panel([1850 2015 -ceil(size(test,2)/num_col)-1 -0],[],{},'Year','Nation');
            else
                CDF_panel([1850 2015 -ceil(size(test,2)/num_col)-1 -0],[],{},'Year','');
            end

            set(gca,'fontsize',12);
        end

        subplot(num_row,3,out{end}),
        for i = 1:size(col,1)
            patch([0 1 1 0]+i - 1,[0 0 1 1],col(i,:),'linewi',1);
        end
        set(gca,'xtick',0:2:20,'xticklabel',[-0.5:0.1:0.5]);
        set(gca,'ytick',[]);
        set(gca,'fontsize',15,'fontweight','bold')
        if do_NpD == 0,
            xlabel('Bucket SST offsets between nations (^oC)');
        else
            xlabel('Bucket SST offsets between groups (^oC)')
        end

        if yint == 5,
            set(gcf,'position',[1 12 12 13],'unit','inches');
            set(gcf,'position',[1 12 12 13],'unit','inches');
            dir_save = HM_OI('save_figure_method');
            CDF_save(1,'png',300,[dir_save,'20180725_Fixed_Yearly_Effects_case_',num2str(case_id),'.png'])
        else
            set(gcf,'position',[0 0 14 13],'unit','inches');
            set(gcf,'position',[0 0 17 11],'unit','inches');
            dir_save = HM_OI('save_figure_science');
            CDF_save(1,'png',300,[dir_save,'FigS3_Biases_',varname,'_',method,'.png'])
        end
    end
end
