% CDF_save(panel,app,reso,file_name)
function CDF_save(panel,app,reso,file_name)

    dir_save = '/Users/zen/Desktop/Peter/Figures/';

    c = clock;
    time_text = [num2str(c(1)*10000+c(2)*100+c(3)),'_',num2str(c(4)),';',num2str(c(5)),';',num2str(round(c(6)))];

    if ~exist('file_name','var');
        file_save = [dir_save,time_text,'.',app];
    else
        file_save = file_name;
    end

    if strcmp(app,'png')

        if exist('reso','var') == 0,
            reso = 300;
        end

        print(panel,'-dpng',['-r',num2str(reso)],file_save);

    elseif strcmp(app,'eps')

        print(panel, '-depsc2',file_save);

    else
        
        H = figure(panel);
        savefig(H,file_save);
    end
    
end