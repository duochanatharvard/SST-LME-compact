% A scipt that pick out ICOADS pairs and 
% subset pairs by distance in each month

% *******************
% Fixed Parameters **
% *******************
varname = 'SST';
method = 'Bucket';
P = HM_lme_exp_para(varname,method);
yr_list = P.yr_list;
mode = 1;     % use great circle distance to compute spatial displacement
env  = 1;     % see HM_OI.m

for yr = yr_list
    for mon = 1:12
        disp(['Year: ',num2str(yr), '   Month: ',num2str(mon)])
        HM_pair_01_Raw_Pairs(yr,mon,mode,varname,method,env);
        HM_pair_02_Screen_Pairs(yr,mon,mode,varname,method,env);
    end
end
