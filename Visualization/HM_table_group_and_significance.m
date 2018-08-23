% This is the code for Table 1 and 2 in the method paper
function output = HM_table_group_and_significance(case_id)

    % *****************
    % Set Parameters **
    % *****************
    if 1,
        nation_list = {'DE','GB','US','JP','RU','NL','GL'};
        varname = 'SST';
        method = 'Bucket';
        yr_start = 1850;
        env = 0;
        alpha   = 0.10;
        % case_id = 1;
    end

    % *******************************************************
    % Find nations that are to be marked by '*' or '**'    **
    % *******************************************************
    [~,~,out] = HM_function_sig_read_data(varname,method,0,yr_start,case_id,env);

    % *******************************************************
    % Find nations that are to be marked by '*' or '**'    **
    % *******************************************************
    Z_stats = (1 - normcdf(abs(out.bias_fixed ./ out.bias_fixed_std)))*2;
    Sig_Nat_90 = Z_stats < alpha;
    Sig_Nat_99 = Z_stats < 0.01;
    List_Nat = out.unique_grp;
    List_Bias_Nat = out.bias_fixed;

    list = find(ismember(out.unique_grp,['DE';'GB';'JP';'NL';'RU';'US';156 156],'rows'));
    disp('National Biases')
    disp([['DE';'GB';'JP';'NL';'RU';'US';156 156],char(ones(7,2)*32),num2str(out.bias_fixed(list),'%6.2f')])
    disp(['Major Nation Range: ', num2str(max(out.bias_fixed(list)) - min(out.bias_fixed(list)),'%6.2f')])
    disp(['Total Range: ', num2str(min(out.bias_fixed),'%6.2f'), ' to ',  num2str(max(out.bias_fixed),'%6.2f')])
    disp(' ')

    output.bias_fixed_6_nat = out.bias_fixed(list);
    output.bias_fixed_range = [min(out.bias_fixed) max(out.bias_fixed)];

    if 1,
        % ***************************************
        % Prepare for the Full name of nations **
        % ***************************************
        full_name = {'AR','Argentina'; 'AU','Australia'; 'BE', 'Belgium'; ...
        'BR', 'Brazil'; 'CA', 'Canada'; 'CN', 'China'; 'DE', 'Germany'; ...
        'DK', 'Danmark'; 'EG', 'Egypt'; 'ES', 'Spain'; 'FR', 'France'; ...
        'GB', 'Great Britain'; 'HK', 'Hongkong'; 'HR', 'Croatia'; 'IE', 'Ireland'; ...
        'IL', 'Isreal'; 'IN', 'India'; 'IS', 'Iceland'; ...
        'JP', 'Japan'; 'KE', 'Kenya'; 'MY', 'Malaysia'; 'NL', 'Netherland'; ...
        'NO', 'Norway'; 'NZ', 'New Zealand'; 'PH', 'Pakistan'; 'PK', 'Philippines'; ...
        'PL', 'Poland'; 'PT', 'Portugal'; 'RU', 'Russia'; 'SE', 'Sweden';...
        'SG', 'Singapore'; 'TH', 'Thailand'; 'TZ', 'Tanzania'; 'UG', 'Uganda';...
        'US', 'United States'; 'YU', 'Uruguay'; 'ZA', 'South Africa'};
        for i = 1:size(full_name,1)
            temp = repmat(' ',1,15);
            temp(end-numel(full_name{i,2})+1:end) = full_name{i,2};
            full_name{i,2} = temp;
        end

        % ********************************************************
        % Read in the input and add up the effects to be tested **
        % ********************************************************
        [test_mean,test_random,out] = HM_function_sig_read_data...
                                            (varname,method,1,yr_start,case_id,env);

        % *****************************************************
        % Find decks that should be markerd with '+' or '++' **
        % *****************************************************
        [unique_nation,~,J] = unique(out.unique_grp(:,1:2),'rows');
        Stats = nan(5,size(out.unique_grp,1));
        Stats_2 = nan(5,size(out.unique_grp,1));
        for i = 1:max(J)
            list = find(J == i);
            if ismember(unique_nation(i,:),'JP','rows'), list(3) = []; end
            sig_exist = 1;
            while numel(list) >= 2 && sig_exist,
                out_sig = HM_function_sig(test_mean,test_random,list);
                temp = [out_sig.p_val; out_sig.raw; out_sig.QC; out_sig.Z_stats; out_sig.sd];
                if numel(list) >= 3 && nnz(temp(1,:)<alpha) > 0,
                    tem_id = find(temp(1,:) == min(temp(1,:)));
                    Stats(:,list(tem_id)) = temp(:,tem_id);
                    list(tem_id) = [];
                elseif numel(list) >= 3 && nnz(temp(1,:)<alpha) == 0,
                    sig_exist = 0;
                    Stats(:,list) = temp;
                elseif numel(list) == 2,
                    sig_exist = 0;
                    temp = repmat(temp,1,2);
                    temp(2,2) = -temp(2,2);
                    Stats(:,list) = temp;
                end
            end

            list = find(J == i);
            if numel(list) == 2,
                out_sig = HM_function_sig(test_mean,test_random,list);
                temp = [out_sig.p_val; out_sig.raw; out_sig.QC; out_sig.Z_stats; out_sig.sd];
                temp = repmat(temp,1,2);
                temp(2,2) = -temp(2,2);
                Stats_2(:,J == i) = temp;
            end
        end

        if 0,    % This is a test if no iteration is made, if the result different
                 % 2018-07-21
            for i = 1:max(J)
                list = find(J == i);

                if numel(list) >= 2,
                    out_sig = HM_function_sig(test_mean,test_random,list);
                    temp = [out_sig.p_val; out_sig.raw; out_sig.QC; out_sig.Z_stats; out_sig.sd];
                    if numel(list) == 2,
                        temp = repmat(temp,1,2);
                        temp(2,2) = -temp(2,2);
                    end
                    Stats_2(:,J == i) = temp;
                end
            end

            Sig_Deck_90_2 = Stats_2(1,:) < alpha;
        end

        Sig_Deck_90 = Stats(1,:) < alpha | Stats_2(1,:) < alpha;
        Sig_Deck_99 = Stats(1,:) < 0.01 | Stats_2(1,:) < 0.01;
        N_dck = zeros(1,158);
        for i = 1:max(J)
            N_dck(J == i) = nnz(J == i);
        end
        Sig_Deck_90_BF = Stats(1,:) < alpha./N_dck | Stats_2(1,:) < alpha./N_dck;
        List_Deck = out.unique_grp;
        disp(['Significant decks: ',num2str(nnz(Sig_Deck_90))])
        disp(['in nations: ',num2str(size(unique(List_Deck(Sig_Deck_90,1:2),'rows'),1))])
        % disp([List_Deck(Sig_Deck_90,1:2) char(ones(nnz(Sig_Deck_90),2)*32) num2str(List_Deck(Sig_Deck_90,3))])


        output.num_sig_dck_90 = nnz(Sig_Deck_90);
        output.sig_dck_90 = List_Deck(Sig_Deck_90,:);
        output.num_sig_dck_90_nat = size(unique(List_Deck(Sig_Deck_90,1:2),'rows'),1);
        output.sig_dck_90_nat = unique(List_Deck(Sig_Deck_90,1:2),'rows');

        % ************************************************
        % Prepare for list of nations assigned by decks **
        % ************************************************
        deck_nation = {'AU',[900, 750];
        'CA',[714];
        'CN',[781];
        'DE',[151, 215, 715, 721, 772, 850, 192, 196, 720];
        'GB',[152, 184, 194, 204, 205, 211, 216, 229, 239, 245, 248, 249, 902];
        'JP',[118, 119, 187, 761, 762, 898];
        'NL',[150, 189, 193];
        'NO',[188,702, 225];
        'RU',[185, 186, 731:733, 735];
        'US',[110, 116, 117, 195, 218, 281, 555, 666, 667, 701, 703:710, 888];
        'ZA',[899]};

        % ************************************************
        % Generate the Table for all nations            **
        % ************************************************
        clear('Table_Text')
        ct_nat = 0;
        for nat = find(List_Nat(:,1)' < 100)

            ct_nat = ct_nat + 1;

            table_text = [];
            table_text = [table_text, char(List_Nat(nat,:)),' & '];
            table_text = [table_text, full_name{ismember(full_name(:,1),...
                          char(List_Nat(nat,:))),2}, ' & '];
            table_text = [table_text, num2str(List_Bias_Nat(nat),'%8.2f')];
            if Sig_Nat_99(nat) == 1,
                table_text = [table_text,'$^*^*$ & '];
            elseif Sig_Nat_90(nat) == 1,
                table_text = [table_text,'$^*$   & '];
            else
                table_text = [table_text,'       & '];
            end
            Table_Text{ct_nat,1} = table_text;

            list_deck = find(ismember(List_Deck(:,1:2),List_Nat(nat,:),'rows'));
            table_text = [];
            ct = 0;

            for dck = list_deck'

                ct = ct + 1;

                if ismember(char(List_Nat(nat,:)),deck_nation(:,1)) == 1,
                    id = find(ismember(deck_nation(:,1),char(List_Nat(nat,:))));
                    if ismember(List_Deck(dck,3),deck_nation{id,2}) == 1,
                        table_text = [table_text, '  \\color{blue}{', num2str(List_Deck(dck,3)),'}'];
                    else
                        table_text = [table_text, ' \\color{black}{', num2str(List_Deck(dck,3)),'}'];
                    end
                else
                    table_text = [table_text, ' \\color{black}{', num2str(List_Deck(dck,3)),'}'];
                end

                if Sig_Deck_99(dck) == 1,
                    table_text = [table_text,'$^*^*$'];
                elseif Sig_Deck_90(dck) == 1,
                    table_text = [table_text,'$^*$  '];
                else
                    table_text = [table_text,'      '];
                end

                if dck == list_deck(end) || rem(ct,10) == 0,
                    table_text = [table_text,'\\\\'];
                    Table_Text{ct_nat,2} = table_text;
                    if dck ~= list_deck(end),
                        table_text = [];
                        ct_nat = ct_nat + 1;
                        Table_Text{ct_nat,1} = ['   &                 &          & '];
                    end
                else
                    table_text = [table_text,','];
                end
            end
        end

        % ************************************************
        % Generate the Table for no nation information  **
        % ************************************************
        clear('Table_Text_deck')
        Table_Text_deck{1,1} = ['-- &       Unknown      &          & '];
        list_deck = find(List_Nat(:,1)' >= 100);
        table_text =[];

        if 0, % Here all decks are merged together
            ct = 0;
            ct_deck = 1;
            for nat = list_deck
                ct = ct + 1;
                table_text = [table_text, ' ',num2str(List_Nat(nat,1)),'('];
                table_text = [table_text, num2str(List_Bias_Nat(nat),'%8.2f')];
                if Sig_Nat_99(nat) == 1,
                    table_text = [table_text,'$^*^*$'];
                elseif Sig_Nat_90(nat) == 1,
                    table_text = [table_text,'$^*$   '];
                else
                    table_text = [table_text,'       '];
                end
                if nat == list_deck(end) || rem(ct,4) == 0,
                    table_text = [table_text,')\\\\'];
                    Table_Text_deck{ct_deck,2} = table_text;
                    if nat ~= list_deck(end),
                        table_text = [];
                        ct_deck = ct_deck + 1;
                        Table_Text_deck{ct_deck,1} = ['   &                 &          & '];
                    end
                else
                    table_text = [table_text,'),'];
                end
            end
        else % Individual decks are listed as nations
            ct_deck = 0;
            for ct = list_deck
                ct_deck = ct_deck + 1;
                table_text = [];
                table_text = [table_text, 'Deck ', num2str(List_Nat(ct,1)),' & '];
                table_text = [table_text,  ' - -  & '];
                table_text = [table_text, num2str(List_Bias_Nat(ct),'%8.2f')];
                if Sig_Nat_99(ct) == 1,
                    table_text = [table_text,'$^*^*$ & '];
                elseif Sig_Nat_90(ct) == 1,
                    table_text = [table_text,'$^*$   & '];
                else
                    table_text = [table_text,'       & '];
                end
                Table_Text_deck{ct_deck,1} = table_text;
                Table_Text_deck{ct_deck,2} = '  - -  \\\\';
            end
        end

        % *********************************************
        % Merge All tables and generate latex files  **
        % *********************************************
        Table_all = [Table_Text; Table_Text_deck];
        Caption_1 = ['Information used to identify groups.  Countries inferred from', ...
                  ' descriptions, where country information is not explicitly given, are shown ', ...
                  'in blue.  Nations for which significant fixed effect departures from zero are ', ...
                  'indicated using a ''*'' and ''**'', respectively, for the 90\\%% and 99\\%% levels.  In ', ...
                  'the most resolved analysis, each unique combination of country and deck is ', ...
                  'considered as a group, and the same notation is used to indicate significant departures.'];

        Caption_2 = ['Continue Table~\\ref{Deck_nation1}. Numbers in the parentheses of ',...
                  'the Unknown category are the fixed effects of individual decks, when measurements are grouped only by country information.'];


        Latex = ['\n\n\n\n'];
        Latex = [Latex, '\\begin{table} [t] \n\\caption{\\label{Deck_nation1} ',Caption_1,'}\n'];
        Latex = [Latex, '\\begin{center} \n\\begin{tabular} {cccccccrc} \n \\hline\\hline \n'];
        Latex = [Latex, 'Abbreviation & Full Name & fixed effect ($^\\circ$C) & ICOADS \\ 3.0 \\ Deck \\\\ \n'];
        Latex = [Latex, '\\hline \n'];
        for i = 1:28
           Latex = [Latex, Table_all{i,1}, Table_all{i,2}, ' \n'];
        end
        Latex = [Latex, '\\hline\\hline \n\\end{tabular} \n\\end{center} \n\\end{table}'];


        Latex = [Latex, '\n\n\n\n'];
        Latex = [Latex, '\\begin{table} [t] \n\\caption{\\label{Deck_nation2} ',Caption_2,'}\n'];
        Latex = [Latex, '\\begin{center} \n\\begin{tabular} {cccccccrc} \n \\hline\\hline \n'];
        Latex = [Latex, 'Abbreviation & Full Name & fixed effect ($^\\circ$C) & ICOADS \\ 3.0 \\ Deck \\\\ \n'];
        Latex = [Latex, '\\hline \n'];
        for i = 29:size(Table_all,1)
           Latex = [Latex, Table_all{i,1}, Table_all{i,2}, ' \n'];
        end
        Latex = [Latex, '\\hline\\hline \n\\end{tabular} \n\\end{center} \n\\end{table}'];

        Latex = [Latex, '\n\n\n\n'];
        fprintf(Latex);
    end
end
