function P = HM_lme_exp_para(varname,method)

    if strcmp(varname,'SST') & strcmp(method,'Bucket'),
        P.yr_list = [1850:2014];
    elseif strcmp(varname,'SST') & strcmp(method,'ERI'),
        P.yr_list = [1930:2014];
    elseif strcmp(varname,'NMAT'),
        P.yr_list = [1880:2014];
    end

    P.do_region = 1;
    P.do_season = 0;
    P.do_decade = 1;
    P.yr_interval = 5;
end
