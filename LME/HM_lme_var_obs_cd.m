function [var_rnd,var_ship,pow] = HM_lme_var_obs_cd(varname,method,do_NpD)

    if strcmp(varname,'SST'),
        if strcmp(method,'Bucket'),
            if do_NpD == 1,
                var_rnd  = 0.84;   var_ship = 1.60;    pow = 0.65;
            else
                var_rnd  = 1.11;   var_ship = 1.55;    pow = 0.61;
            end
        elseif strcmp(method,'ERI'),
            if do_NpD == 1,
                var_rnd  = 1.45;   var_ship = 1.97;    pow = 0.58;
            else
                var_rnd  = 0.5;   var_ship = 2.92;    pow = 0.64;
            end
        end
    elseif strcmp(varname,'NMAT'),
        if do_NpD == 1,
            var_rnd  = 2.00;   var_ship = 1.24;    pow = 0.57;
        else
            var_rnd  = 2.00;   var_ship = 1.40;    pow = 0.54;
        end
    end

    var_rnd = var_rnd / 2;
    var_ship = var_ship / 2;
end
