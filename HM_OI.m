
function [output,app] = HM_OI(input,env,app,varname,method)

    % set working enviroment, "env" maps to different home directories
    if ~exist('env','var'),        env = 1;        end
    if isempty(env),               env = 1;        end
    if ~exist('app','var'),        app = '';       end

    % *********************************************************************
    % Do not change this part
    % *********************************************************************
    if exist('varname','var'),
        app = ['HM_',varname,'_',method];
        if app(end)=='_', app(end)=[]; end
        app(end+1) = '/';
    end

    if isempty(app), app = ''; end

    % *********************************************************************
    % Make changes in the following part!
    % *********************************************************************
    % Folders of this code
    if strcmp(input,'code'),
        output = '/Users/zen/Research/Git_Code/SST_Homo_compact/';
    
    % Home directory of HVD_SST
    elseif strcmp(input,'home')
        if env == 1,
           output = ['/Volumes/My Passport Pro/SST/Test_Homo_compact/',app];
        end
        
    % Home directory of pre-processed ICOADS DATA
    elseif strcmp(input,'read_raw')
        if env == 1,
            output = '/Volumes/My Passport Pro/ICOADS_RE/';
        end

    % folders to put the pre-processed ICOADS SST mat files
    elseif strcmp(input,'SST_raw')
        output = 'Step_0_pre_step_3_QCed_data_ICOADS_RE/';
          
    % *********************************************************************
    % Do not suggest to change the following
    % *********************************************************************    

    % folders to put pairs that are picked out
    elseif strcmp(input,'raw_pairs')
        output = [app,'Step_01_Raw_Pairs/'];

    % folders to put pairs that are screened
    elseif strcmp(input,'screen_pairs')
        output = [app,'Step_02_Screen_Pairs/'];

    % folders to put LME outputs
    elseif strcmp(input,'LME_run')
        output = [app,'Step_04_run/'];

    % folders to put diurnal cycle lookup tables
    elseif strcmp(input,'diurnal')
        output = ['Miscellaneous/'];
        
    % folders to put OI-SST statistics
    elseif strcmp(input,'mis')
        output = ['Miscellaneous/'];

    elseif strcmp(input,'Mis')
        output = [HM_OI('home',env),'Miscellaneous/'];

    % folders to output figures
    elseif strcmp(input,'save_figure_method');
        output = [HM_OI('code'),'/Figures/'];

    end

end
