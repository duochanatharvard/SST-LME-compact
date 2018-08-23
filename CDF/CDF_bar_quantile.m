% [h,RGB] = CDF_bar_quantile(x,y,col,q_list,input_type,bar_width)
% The input of this version is data rather than quantile
% input_type 1: data & quantile
% input_type 2: quantile
% var_width

function [h,RGB] = CDF_bar_quantile(x,y,col,q_list,input_type,bar_width)

    if(size(col,2)==1)
        col = [col col];
    end
    hold on;
    
    if input_type == 1,

        Tab = quantile(y,q_list);
        for ct = 1:numel(Tab)/2
            ct = ct + 1;
            temp = [Tab(ct) Tab(end-ct+1)];
            h1 = patch(x + [-0.5 -0.5 +0.5 +0.5] * bar_width,[temp fliplr(temp)],col,'linest','none');
            alpha(h1,0.08)
        end
        h = plot(x + [-0.5 0.5] * bar_width,[1 1] * median(y),'color',col,'linewi',3);
        
    else
        
        num = fix(numel(y)/2) + 1;
        RGB = CDF_colormap(col,[.9 .5],[1 1],num-1,0);
        
        hold on;
        ct = 0;
        for i = 1:num-1
            ct = ct + 1;
            temp = [y(i) y(end-i+1)];
            patch(x + [-0.5 -0.5 +0.5 +0.5] * bar_width,[temp fliplr(temp)],RGB(ct,:),'linest','none');
        end
        h = plot(x + [-0.5 +0.5] * bar_width,[y(num) y(num)],'k-','linewi',2);
    end
end