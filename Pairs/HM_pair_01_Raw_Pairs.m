function HM_pair_01_Raw_Pairs(yr_list,mon_list,mode,varname,method,env)

    % *******************
    % Input and Output **
    % *******************
    if ~exist('env','var'),
        env = 1;             % 1 means on odyssey
    end
    dir_home = HM_OI('home',env);
    addpath('/n/home10/dchan/Matlab_Tool_Box/');
    addpath('/n/home10/dchan/m_map/');
    addpath('/n/home10/dchan/script/Peter/ICOAD_RE/function/');
    addpath('/n/home10/dchan/script/Peter/Hvd_SST/Homo/');

    app = ['HM_',varname,'_',method];
    if app(end)=='_', app(end)=[]; end
    app(end+1) = '/';

    % # TODO
    if strcmp(varname,'SST'),
        dir_load = [HM_OI('read_raw',env),HM_OI('SST_raw')];
    elseif strcmp(varname,'NMAT'),
        dir_load = [HM_OI('read_raw',env),HM_OI('NMAT_raw')];
    end
    dir_save = [dir_home,HM_OI('raw_pairs',env,app)];

    % *****************
    % Set Parameters **   # TODO
    % *****************
    if strcmp(varname,'SST') && strcmp(method,'Bucket')
        pick_limit = 0.05;
    elseif strcmp(varname,'SST') && strcmp(method,'ERI')
        pick_limit = 0.95;
    end

    % *****************
    % Pick out pairs **
    % *****************
    for yr = yr_list
        for mon = mon_list

            % *********************************
            % File name for the loading data **
            % *********************************
            clear('Pairs','Meta')
            clear('file_load','file_save','sst_ascii')
            cmon = CDF_num2str(mon,2);
            if strcmp(varname,'SST'),
                file_load = [dir_load,'IMMA1_R3.0.0_',num2str(yr),'-',cmon,'_QCed.mat'];
            elseif strcmp(varname,'NMAT'),
                file_load = [dir_load,'IMMA1_R3.0.0_',num2str(yr),'-',cmon,'_AT_only.mat'];
            end

            % ********************************
            % File name for the saving data **     # TODO
            % ********************************
            if strcmp(varname,'SST'),
                if strcmp(method,'Bucket'),
                    if mode == 1,
                        file_save = [dir_save,'IMMA1_R3.0.0_',num2str(yr),'-',...
                        cmon,'_Bucket_Pairs_c_',num2str(pick_limit),'.mat'];
                    else
                        file_save = [dir_save,'IMMA1_R3.0.0_',num2str(yr),'-',cmon,...
                        '_Bucket_Pairs_x_',num2str(pick_limit),'.mat'];
                    end
                elseif strcmp(method,'ERI'),
                    if mode == 1,
                        file_save = [dir_save,'IMMA1_R3.0.0_',num2str(yr),'-',...
                        cmon,'_ERI_Pairs_c_',num2str(pick_limit),'.mat'];
                    else
                        file_save = [dir_save,'IMMA1_R3.0.0_',num2str(yr),'-',cmon,...
                        '_ERI_Pairs_x_',num2str(pick_limit),'.mat'];
                    end
                end
            elseif strcmp(varname,'NMAT'),
                if mode == 1,
                    file_save = [dir_save,'IMMA1_R3.0.0_',num2str(yr),'-',cmon,'_AT_Pairs_c.mat'];
                else
                    file_save = [dir_save,'IMMA1_R3.0.0_',num2str(yr),'-',cmon,'_AT_Pairs_x.mat'];
                end
            end

            % *******************
            % READ IN THE DATA **
            % *******************
            [sst_ascii] = HM_Step_01_Raw_Pairs_read(file_load,varname,yr);

            if ~isempty(sst_ascii),

                % ********************************************
                % Subset the raw data according to criteria **
                % ********************************************
                if strcmp(varname,'SST'),
                    if strcmp(method,'Bucket'),
                        logic_use = sst_ascii(16,:) == 0 | ...
                            (sst_ascii(16,:) > 0 & sst_ascii(16,:) < pick_limit);
                    elseif strcmp(method,'ERI'),
                        logic_use = sst_ascii(16,:) == 1 | ...
                            (sst_ascii(16,:) > pick_limit & sst_ascii(16,:) < 1);
                    end
                else
                    logic_use = ones(1,size(sst_ascii,2)) == 1;
                end

                % ****************
                % Pickout pairs **
                % ****************
                if nnz(logic_use),
                    clear('DATA','RECORD','grp_list')
                    DATA = sst_ascii(:,logic_use);
                    clear('sst_ascii');

                    if strcmp(varname,'SST'),
                        Markers = DATA([20 21 10],:)';
                    else
                        Markers = DATA([13 14 10],:)';
                    end

                    if mode == 1,
                        [Pairs,Meta] = re_function_general_get_pairs(DATA,Markers,8,9,6,5,[],300,3,48,mode);
                    else
                        [Pairs,Meta] = re_function_general_get_pairs(DATA,Markers,8,9,6,5,[],3,3,48,mode);
                    end
                    % re_function_general_get_pairs(in_var,index,lon_index,lat_index,time_index,reso_s,reso_t,c_lim,y_lim,t_lim)

                    if ~isempty(Pairs),
                        disp('Saving data')
                        save(file_save,'Pairs','Meta','-v7.3');
                    end
                end
            end
        end
    end
end

% -------------------------------------------------------------------------
function [sst_ascii] = HM_Step_01_Raw_Pairs_read(file_load,varname,yr)

    fid=fopen(file_load,'r');

    if(fid~=-1)

        clear('logic','kind_temp','sst_ascii_temp')
        disp([file_load,' is started!']);
        fclose(fid);

        if strcmp(varname,'SST')
            clear('C0_YR','C0_MO','C0_DY','C0_HR','C0_LCL','C0_UTC','C98_UID','C0_LON','C0_LAT',...
                'C1_DCK','C1_SID','C0_II','C1_PT','C0_SST','C0_OI_CLIM','C0_SI_1',...
                'C0_SI_2','C0_SI_3','C0_SI_4','QC_FINAL','C0_CTY_CRT')
            load (file_load,'C0_YR','C0_MO','C0_DY','C0_HR','C0_LCL','C0_UTC','C98_UID','C0_LON','C0_LAT',...
                'C1_DCK','C1_SID','C0_II','C1_PT','C0_SST','C0_OI_CLIM','C0_SI_1',...
                'C0_SI_2','C0_SI_3','C0_SI_4','QC_FINAL','C0_CTY_CRT')
            C0_OI_CLIM = double(C0_OI_CLIM);

            % -----------------------------------------------------------------
            clear('sst_ascii_temp','clim_temp')
            sst_ascii_temp = [C0_YR;C0_MO;C0_DY;C0_HR;C0_LCL;C0_UTC;C98_UID;C0_LON;C0_LAT;C1_DCK;C1_SID;C0_II;C1_PT;
                C0_SST;C0_OI_CLIM;C0_SI_4;C0_SI_1;C0_SI_2;C0_SI_3];
            % 1. C0_YR;   2.C0_MO;    3.C0_DY;    4.C0_HR;
            % 5.C0_LCL;   6.C0_UTC;   7.C98_UID;    8.C0_LON;   9.C0_LAT;
            % 10.C1_DCK;  11.C1_SID;  12.C0_II;   13.C1_PT;
            % 14.C0_SST;  15.C0_OI_CLIM;
            % 16.C0_SI_4; 17.C0_SI_1; 18.C0_SI_2; 19.C0_SI_3
            % 20-21. Country
            sst_ascii_temp = sst_ascii_temp(:,QC_FINAL);
            country_temp = C0_CTY_CRT(QC_FINAL,:);
            sst_ascii = [sst_ascii_temp; double(country_temp')];
            clear('C0_YR','C0_MO','C0_DY','C0_HR','C0_LCL','C0_UTC','C98_UID','C0_LON','C0_LAT',...
                'C1_DCK','C1_SID','C0_II','C1_PT','C0_SST','C0_OI_CLIM','C0_SI_1',...
                'C0_SI_2','C0_SI_3','C0_SI_4','QC_FINAL','C0_CTY_CRT')

        elseif strcmp(varname,'NMAT')

            clear('C0_MO','C0_LON','C0_LAT','C0_DY','C0_AT','C0_UTC','C0_LCL',...
                'C0_CTY_CRT','C7_HOP','C7_HOB','C7_HOT','C1_DCK','C0_ERA_CLIM','C98_UID');
            load(file_load,'C0_LON','C0_LAT','C0_MO','C0_DY','C0_AT','C0_UTC',...
                'C0_LCL','C0_CTY_CRT','C1_DCK','C0_ERA_CLIM','C98_UID')
            C0_YR = ones(size(C0_MO)) .* yr;
            C0_ERA_CLIM = double(C0_ERA_CLIM);

            % ------------------------------------------------------------------
            clear('sst_ascii_temp','clim_temp')
            sst_ascii_temp = [C0_YR;C0_MO;C0_DY;C0_LCL;C0_LCL;C0_UTC;C98_UID;C0_LON;C0_LAT;C1_DCK;
                              C0_AT;C0_ERA_CLIM];
            % 1. C0_YR;   2.C0_MO;    3.C0_DY;    4.C0_LCL;
            % 5.C0_LCL;   6. C0_UTC;  7.C98_UID   8.C0_LON;   9.C0_LAT;
            % 10.C1_DCK;  11.C0_AT;   12.C0_ERA_CLIM
            % 13-14. Country
            country_temp = C0_CTY_CRT;
            sst_ascii = [sst_ascii_temp; double(country_temp')];
            clear('C0_MO','C0_LON','C0_LAT','C0_DY','C0_AT','C0_UTC','C0_LCL',...
                'C0_CTY_CRT','C7_HOP','C7_HOB','C7_HOT','C1_DCK','C0_ERA_CLIM');
          end

    else
        disp([file_load ,' does not exist!']);
        sst_ascii = [];
    end
    disp(['Read Data Finished!']);
    clear('sst_ascii_temp','country_temp');
end
