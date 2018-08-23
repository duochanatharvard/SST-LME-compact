function HM_function_sig_figure_cmp(pic,sig,group,Target,title_num)

    figure(1); clf; hold on
    pic(pic == 0) = nan;
    h = pcolor([0.5:1:size(pic,1)+0.5],[0.5:1:size(pic,1)+0.5],[pic pic(:,end); pic(end,:) 0]);
    set(h,'edgecolor',[1 1 1]*.8);

    for i = 1:size(pic,1)
        for j = i+1:size(pic,1)
            if sig(i,j) == 1,
                if pic(i,j) < 0, pic_text = '-'; else  pic_text = '+'; end
                if abs(pic(i,j)) > .35, col_text = 'w'; else    col_text = 'w'; end
                if ~strcmp(Target,'Global'),
                    % plot([-.5 .5 .5 -.5 -.5]+j,[-.5 -.5 .5 .5 -.5]+i,'y-','linewi',4);
                end
                text(j,i,pic_text,'color',col_text,'HorizontalAlignment',...
                    'center','fontweight','bold','fontsize',max(14*14/size(pic,1),22));
            end
        end
    end

    if ~strcmp(Target,'Global'),
        list2 = group(:,3);
    else
        for i = 1:size(group,1)
            if group(i,1) < 100,
                list2{i} = char(group(i,:));
            else
                list2{i} = ['D ',num2str(group(i,1))];
            end
        end
    end

    caxis([-1 1]/2)
    if ~strcmp(Target,'Global'),
        CDF_panel([0.5 size(pic,1)+0.5 0.5  size(pic,1)+0.5],[],{},[Target,' Deck'],[Target,' Deck'])
        title([char(96 + title_num),'.'],'fontsize',20,'position',[0.6 size(pic,1)+.6])
    else
        CDF_panel([0.5 size(pic,1)+0.5 0.5  size(pic,1)+0.5],[],{},'Nation','Nation')
    end
    colormap_CD([ .5 .67; .05 0.93],[.95 .2],[0 0],10);
    grid off
    set(gca,'xtick',1:size(pic,1),'xticklabel',list2,'xticklabelrotation',90)
    set(gca,'ytick',1:size(pic,1),'yticklabel',list2)
    set(gca,'fontsize',14)
    daspect([1 1 1])
    h = colorbar('location','southoutside');
    if ~strcmp(Target,'Global'),
        ylabel(h,'Bucket SST offsets between decks (^oC)','fontsize',18)
    else
        ylabel(h,'Bucket SST offsets between nations (^oC)','fontsize',15)
    end

    if ~strcmp(Target,'Global'),
        set(gcf,'position',[22 14 6*1.5 8*1.5],'unit','inches')
        set(gcf,'position',[22 14 6*1.5 8*1.5],'unit','inches')
    else
        set(gcf,'position',[22 14 6*2 13],'unit','inches')
        set(gcf,'position',[22 14 6*2 13],'unit','inches')
    end
    set(gcf, 'PaperPositionMode','auto');
end
