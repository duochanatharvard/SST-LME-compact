% A scipt that sum all pairs into a single file

addpath('/n/home10/dchan/m_map/');

% *******************
% Fixed Parameters **
% *******************
varname = 'SST';
method = 'Bucket';
P = HM_lme_exp_para(varname,method);
yr_list = P.yr_list;

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
dir_load = [dir_home,HM_OI('screen_pairs',env,app)];
dir_save = [dir_home,app];

% *************************
% Summing Screened Pairs **
% *************************
DATA = [];
for yr = yr_list

    disp(['starting year:',num2str(yr)])

    for mon = 1:12

        % ******************************
        % File name for summing pairs **     # TODO
        % ******************************
        cmon = CDF_num2str(mon,2);
        if strcmp(varname,'SST'),
            if strcmp(method,'Bucket'),
                file_load = [dir_load,'IMMA1_R3.0.0_',num2str(yr),'-',...
                        cmon,'_Bucket_Screen_Pairs_c.mat'];
            elseif strcmp(method,'ERI'),
                file_load = [dir_load,'IMMA1_R3.0.0_',num2str(yr),'-',...
                          cmon,'_ERI_Screen_Pairs_c.mat'];
            end
        elseif strcmp(varname,'NMAT'),
            file_load = [dir_load,'IMMA1_R3.0.0_',num2str(yr),'-',cmon,...
                        '_AT_Screen_Pairs_c.mat'];
        end

        % ********************************
        % Summing up the screened pairs **
        % ********************************
        clear('Pairs','Meta','SST_diurnal_adj','DA_mgntd','DA_shape')
        fid = fopen(file_load);
        if fid > 0,
            fclose(fid);
            load(file_load)

            if strcmp(varname,'SST'),
                DATA = [DATA [Pairs; SST_diurnal_adj; DA_mgntd; DA_shape]];
            else
                % *************************************
                % Transform the NMAT into SST format **
                % *************************************
                if strcmp(varname,'NMAT')

                    Pairs_raw = Pairs;
                    clear('Pairs')
                    Pairs = zeros(48,size(Pairs_raw,2));

                    Pairs(1:10,:) = Pairs_raw(1:10,:);
                    Pairs(14:15,:) = Pairs_raw(11:12,:);
                    Pairs(20:21,:) = Pairs_raw(13:14,:);

                    Pairs([1:10]+21,:)  = Pairs_raw([1:10]+14,:);
                    Pairs([14:15]+21,:) = Pairs_raw([11:12]+14,:);
                    Pairs([20:21]+21,:) = Pairs_raw([13:14]+14,:);

                end
                DATA = [DATA [Pairs]];
            end
        end
    end
end

% ****************************************
% File name for saving the summed pairs **     # TODO
% ****************************************
cmon = CDF_num2str(mon,2);
yr_text = [num2str(yr_list(1)),'_',num2str(yr_list(end))];
file_save = [dir_save,'SUM_',app(1:end-1),'_Screen_Pairs_c_once_',yr_text,'.mat'];
save(file_save,'DATA','-v7.3')
