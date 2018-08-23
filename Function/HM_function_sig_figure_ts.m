function HM_function_sig_figure_ts(dd,group,l,title_num,Target)

    figure(2);clf; hold on;

    dd_sig = dd(:,l,:);
    group_sig = group(l,:);

    dd_insig = dd(:,~l,:);
    group_insig = group(~l,:);

    if size(dd_sig,2) <= 3,
        RGB = colormap_CD([0.3 0.03; 0.55 0.66],[0.5 0.5],[0 0],2);
        if size(dd_sig,2) <= 2,
            RGB = RGB([1 3],:);
        else
            RGB = RGB([1 2 4],:);
        end
    else
        RGB = colormap_CD([0.25 0.95; 0.45 0.8],[0.5 0.4],[0 0],ceil(size(dd_sig,2)/2));
    end

    if size(dd_insig,2) == 1,
        RGB_bw = [.7 .7 .7];
    else
        RGB_bw = colormap_CD([ .5 .67],[.9 .3],[1],size(dd_insig,2));
    end

    clf;
    for dck = 1:size(dd_insig,2)
        for yr = 1:size(dd_insig,1)
            pic = squeeze(dd_insig(yr,dck,:));
            if ~isnan(pic(1)),
                CDF_bar_quantile(yr*5+1852.5-5,pic,RGB_bw(dck,:),[0.05 0.95],1,5);
            end
        end
    end

    for dck = 1:size(dd_sig,2)
        for yr = 1:size(dd_sig,1)
            pic = squeeze(dd_sig(yr,dck,:));
            if ~isnan(pic(1)),
                CDF_bar_quantile(yr*5+1852.5-5,pic,RGB(dck,:),[0.05 0.95],1,5);
            end
        end
    end

    for dck = 1:size(dd_insig,2)
        CDF_histplot(1852.5:5:2014,nanmean(dd_insig(:,dck,:),3),':',RGB_bw(dck,:),1);
    end

    for dck = 1:size(dd_sig,2)
        CDF_histplot(1852.5:5:2014,nanmean(dd_sig(:,dck,:),3),':',RGB(dck,:),1);
    end

    map(l,:) = RGB(1:nnz(l),:);
    map(~l,:) = RGB_bw;
    colormap(map);
    h = colorbar;

    set(h,'ytick',1:size(dd,2),'yticklabel',num2str(group(:,3)))
    ylabel(h,'Deck')
    caxis([.5 size(dd,2)+.5])
    CDF_panel([1850 2014 -1.2 1.2],[],{},'Year',['Biases(^oC) - ',Target,' Decks']);
    title([char(96 + title_num),'.'],'fontsize',20,'position',[1851 1.25])
    daspect([1 0.02 1])

    set(gcf,'position',[22 14 8*1.5 6*1.5],'unit','inches')
    set(gcf,'position',[22 14 8*1.5 6*1.5],'unit','inches')
    set(gcf, 'PaperPositionMode','auto');
    set(gca,'GridColor',[1 1 1]*.6)

end
