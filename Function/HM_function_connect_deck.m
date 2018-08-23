% grp_out = HM_function_connect_deck(grp_in)
function grp_out = HM_function_connect_deck(grp_in)

    list{1} = double(['JP',118;'JP',119;'JP',762]);
    list{2} = double([156 156 156; 'DE',156]);
    list{3} = double(['DE',192;'DE',196;'DD',192;'DD',196]);
    list{4} = double(['NL',193;'NL',189]);
    list{5} = double(['US',708;'US',709]);
    list{6} = double(['JP',187;'JP',761]);
    list{7} = double(['GB',184;'GB',194;'GB',902]);
    list{8} = double(['GB',204;'GB',229;'GB',239]);
    list{9} = double(['GB',203;'GB',207;'GB',209;'GB',213;'GB',223;'GB',227;'GB',233]);
    list{10} = double(['GB',208;'GB',212;'GB',222]);
    list{11} = double(['GB',206;'GB',210;'GB',214;'GB',224;'GB',226;'GB',234]);
    list{12} = double(['GB',205;'GB',211]);
    list{13} = double(['US',110;'US',281;'US',195;'US',555;'US',708;'US',709]);
    % list{14} = double(['US',116;'US',705;'US',706;'US',707]);
    list{14} = double([792 792 792; 892 892 892]);
    list{15} = double([927,927,927; 128,128,128; 254,254,254]);  % Added on 20180512

    grp_out = grp_in;
    for i = 1:numel(list)
        logic = ismember(grp_in(:,1:3),double(list{i}),'rows');
        grp_out(logic,1:3) = repmat(double(list{i}(1,:)),nnz(logic),1);
    end

    logic = ismember(grp_in(:,3),[927, 128, 254]);
    grp_out(logic,3) = 927;                                      % Added on 20180512

end
