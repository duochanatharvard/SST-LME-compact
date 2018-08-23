% HM_Step_02_Screen_Pairs(yr,mon)
function HM_pair_02_Screen_Pairs(yr,mon,mode,varname,method,env)

    % *******************
    % Input and Output **
    % *******************
    if ~exist('env','var'),
        env = 1;            % 1 means on odyssey
    end
    dir_home = HM_OI('home',env);


    app = ['HM_',varname,'_',method];
    if app(end)=='_', app(end)=[]; end
    app(end+1) = '/';
    dir_load = [dir_home,HM_OI('raw_pairs',env,app)];
    dir_save = [dir_home,HM_OI('screen_pairs',env,app)];

    % *****************************
    % File name for loading data **     # TODO
    % *****************************
    cmon = CDF_num2str(mon,2);
    if strcmp(varname,'SST'),
        if strcmp(method,'Bucket'),
            pick_limit = 0.05;
            if mode == 1,
                file_load = [dir_load,'IMMA1_R3.0.0_',num2str(yr),'-',...
                        cmon,'_Bucket_Pairs_c_',num2str(pick_limit),'.mat'];
            else
                file_load = [dir_load,'IMMA1_R3.0.0_',num2str(yr),'-',cmon,...
                        '_Bucket_Pairs_x_',num2str(pick_limit),'.mat'];
            end
        elseif strcmp(method,'ERI'),
            pick_limit = 0.95;
            if mode == 1,
                file_load = [dir_load,'IMMA1_R3.0.0_',num2str(yr),'-',...
                          cmon,'_ERI_Pairs_c_',num2str(pick_limit),'.mat'];
            else
                file_load = [dir_load,'IMMA1_R3.0.0_',num2str(yr),'-',cmon,...
                        '_ERI_Pairs_x_',num2str(pick_limit),'.mat'];
            end
        end
    elseif strcmp(varname,'NMAT'),
        if mode == 1,
            file_load = [dir_load,'IMMA1_R3.0.0_',num2str(yr),'-',cmon,...
                        '_AT_Pairs_c.mat'];
        else
            file_load = [dir_load,'IMMA1_R3.0.0_',num2str(yr),'-',cmon,...
                        '_AT_Pairs_x.mat'];
        end
    end

    fid = fopen(file_load);
    if fid > 0,
        fclose(fid);
        load(file_load)

        % ****************************************************************
        % Reassign decks and remove pairs that come from the same group **
        % ****************************************************************
        N_data = size(Pairs,1)/2;

        clear('kind_out')
        kind_out(:,1:3) = HM_function_preprocess_deck(Meta(:,1:3),1);
        kind_out(:,4:6) = HM_function_preprocess_deck(Meta(:,4:6),1);
        % the second input "1" means connect decks
        Meta = kind_out;
        logic_remove = all(Meta(:,1:3) == Meta(:,4:6),2);
        Pairs(:,logic_remove) = [];
        Meta(logic_remove,:) = [];
        clear('logic_remove','ans')

        % *************************************
        % Compute the distance between pairs **
        % *************************************
        N_ascii = N_data;                                       %TODO
        id_lon  = 8;                                            %TODO
        id_lat  = 9;                                            %TODO
        id_utc  = 6;                                            %TODO
        id_lcl  = 5;
        dist_s = distance(Pairs(id_lat,:),Pairs(id_lon,:),...
                          Pairs(id_lat+N_ascii,:),Pairs(id_lon+N_ascii,:));
        dist_c = abs(Pairs(id_utc,:) - Pairs(id_utc+N_ascii,:));
        dist = dist_c / 12 + dist_s;
        [~,I] = sort(dist);
        clear('dist_s','dist_c')

        % ********************************
        % To transform UID into numbers **
        % ********************************
        point_pairs        = [Pairs(7,:)' Pairs(7+N_ascii,:)'];
        [point_unique,~,J] = unique(point_pairs(:));
        J_pairs            = [J(1:numel(J)/2) J(numel(J)/2+1:end)];

        % Remove ships that does not provide additional information ---------------
        disp('eliminating duplicate pairs')
        do_remove_mode = 2;                                     %TODO
        if do_remove_mode == 1,   % exclude non informative pairs

            group = sparse(0,numel(point_unique));

            logic_use = false(1,size(J_pairs,1));
            ct = 0;
            for i = I  % starting searching from the smallest distance

                clear('ct1','ct2')
                ct1 = find(group(:,J_pairs(i,1)) == 1);
                ct2 = find(group(:,J_pairs(i,2)) == 1);

                if isempty(ct1) && isempty(ct2),
                    ct = ct + 1;
                    group(ct,J_pairs(i,:)) = 1;
                    logic_use(i) = 1;
                elseif isempty(ct1) && ~isempty(ct2),
                    group(ct2,J_pairs(i,:)) = 1;
                    logic_use(i) = 1;
                elseif ~isempty(ct1) && isempty(ct2),
                    group(ct1,J_pairs(i,:)) = 1;
                    logic_use(i) = 1;
                elseif ct1 ~= ct2,
                    group(ct1,group(ct2,:) == 1) = 1;
                    group(ct2,:) = [];
                    ct = size(group,1);
                    logic_use(i) = 1;
                end
            end

        else                      % each individual data point is only used once

            group = false(1,numel(point_unique));
            logic_use = false(1,size(J_pairs,1));
            for i = I  % starting searching from the smallest distance

                clear('ct1','ct2')
                ct1 = group(J_pairs(i,1));
                ct2 = group(J_pairs(i,2));

                if ct1 == 0 && ct2 == 0,
                    group(1,J_pairs(i,:)) = 1;
                    logic_use(i) = 1;
                end
            end

        end
        clear('ct','ct1','ct2','dist_sort','dist')

        % **********************
        % Screening the pairs **
        % **********************
        Pairs   = Pairs(:,logic_use);
        Meta    = Meta(logic_use,:);
        clear('I','J','H_airs','logic_use','point_pairs')

        % ****************************
        % File name for saving data **     # TODO
        % ****************************
        cmon = CDF_num2str(mon,2);
        if strcmp(varname,'SST'),
            if strcmp(method,'Bucket'),
                if mode == 1,
                    file_save = [dir_save,'IMMA1_R3.0.0_',num2str(yr),'-',...
                            cmon,'_Bucket_Screen_Pairs_c.mat'];
                else
                    file_save = [dir_save,'IMMA1_R3.0.0_',num2str(yr),'-',cmon,...
                            '_Bucket_Screen_Pairs_x.mat'];
                end
            elseif strcmp(method,'ERI'),
                if mode == 1,
                    file_save = [dir_save,'IMMA1_R3.0.0_',num2str(yr),'-',...
                              cmon,'_ERI_Screen_Pairs_c.mat'];
                else
                    file_save = [dir_save,'IMMA1_R3.0.0_',num2str(yr),'-',cmon,...
                            '_ERI_Screen_Pairs_x.mat'];
                end
            end
        elseif strcmp(varname,'NMAT'),
            if mode == 1,
                file_save = [dir_save,'IMMA1_R3.0.0_',num2str(yr),'-',cmon,...
                            '_AT_Screen_Pairs_c.mat'];
            else
                file_save = [dir_save,'IMMA1_R3.0.0_',num2str(yr),'-',cmon,...
                            '_AT_Screen_Pairs_x.mat'];
            end
        end

        if strcmp(varname,'SST'),
            % *************************************
            % Assigning Diurnal Signal From Buoy **
            % *************************************
            dir_da = [dir_home,HM_OI('diurnal',env)];
            disp('Assign diurnal cycle')
            clear('CLIM_DASM','Diurnal_Shape')
            load([dir_da,'DA_SST_Gridded_BUOY_sum_from_grid.mat'],'CLIM_DASM');
            load([dir_da,'Diurnal_Shape_SST.mat'],'Diurnal_Shape');
            Diurnal_Shape = squeeze(Diurnal_Shape(:,:,3,:));

            % .......................
            % Locate diurnal cycle ..
            % .......................
            clear('latitude','logitude','months','hours','DA_mgntd','DA_shape',...
                  'Y','DASHP_id','shp_temp','SST_adj');
            latitude  = [Pairs(id_lat,:)     Pairs(id_lat + N_data,:)];
            longitude = [Pairs(id_lon,:)     Pairs(id_lon + N_data,:)];
            months    = [Pairs(2,:)          Pairs(2 + N_data,:)];
            hours     = [Pairs(id_lcl,:)     Pairs(id_lcl + N_data,:)];

            DA_mgntd  = HM_function_grd2pnt(longitude,latitude,months,CLIM_DASM,5,5,1);
            Y = fix((latitude+90)/5)+1; Y(Y>36)=36;
            DASHP_id = sub2ind([36 24 12], Y, hours, months);
            DA_shape  = Diurnal_Shape(DASHP_id);

            % .........................
            % Compute diurnal signal ..
            % .........................
            SST_diurnal_adj = DA_shape .* DA_mgntd;

            % ........................
            % Assign diurnal signal ..
            % ........................
            N = numel(SST_diurnal_adj)/2;
            SST_diurnal_adj  = [SST_diurnal_adj(1:N);  SST_diurnal_adj(N+1:end)];
            DA_shape = [DA_shape(1:N); DA_shape(N+1:end)];
            DA_mgntd = [DA_mgntd(1:N); DA_mgntd(N+1:end)];
            SST_diurnal_adj(isnan(SST_diurnal_adj)) = 0;

            save(file_save,'Pairs','Meta','DA_shape','DA_mgntd','SST_diurnal_adj','-v7.3')
        else
            save(file_save,'Pairs','Meta','-v7.3')
        end
    end
end
