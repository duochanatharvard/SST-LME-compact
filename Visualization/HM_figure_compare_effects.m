% *****************
% Set Parameters **
% *****************
if 1,
    nation_list = {'DE','GB','US','JP','RU','NL','GL'};
    varname = 'SST';
    method = 'Bucket';
    yr_start = 1850;
    env = 1;
    do_NpD = 0;
end

% *******************************************************
% Find nations that are to be marked by '*' or '**'    **
% *******************************************************
case_id = 1;
[test1,test_rnd1,out1] = HM_function_sig_read_data(varname,method,do_NpD,yr_start,case_id,env);

case_id = 2;
[test2,test_rnd2,out2] = HM_function_sig_read_data(varname,method,do_NpD,yr_start,case_id,env);

p1 = 2*(1-normcdf(abs(out1.bias_fixed ./ out1.bias_fixed_std),0,1));
p2 = 2*(1-normcdf(abs(out2.bias_fixed ./ out2.bias_fixed_std),0,1));
median(abs(p1-p2))

[dir_load,app] = HM_OI('Mis');
file_stats = [dir_load,'Stats_HM_SST_Bucket_Glb_deck_level_',num2str(do_NpD),'.mat'];
stats = load(file_stats);

num = squeeze(nansum(stats.Stats_glb,2));
num = squeeze(nansum(reshape(num,5,33,size(num,2)),1));

% ************************************
% Plot the fixed+random effects     **
% ************************************
a = [log10(num(:)) test1(:) test2(:)];
logic = ~isnan(a(:,2));
a = a(logic,:);
[~,I] = sort(a(:,1));
a = a(I,:);

figure(1); clf;
subplot(1,2,1); hold on
plot([-1 1],[-1 1],'--','color',[1 1 1]*.8,'linewi',3)
scatter(a(:,2),a(:,3),100,a(:,1),'.')
col = colormap_CD([.45 .7 ; 0.35  .98],[.7 .4],[0 0],6);
h = colorbar;
ylabel(h,'log10( Number of measurements )','fontsize',18,'fontweight','bold')
caxis([0 6])
CDF_panel([-1 1 -1 1]*1,[],{},'Offsets assuming i.i.d. pairs (^oC)','Offsets accounting for covariance (^oC)')
set(gca,'xtick',[-1:0.2:1])
daspect([1 1 1])
if do_NpD  == 1,
    text(-.65,.75,'a.','fontsize',18,'fontweight','bold')
else
    text(-.95,1.07,'a.','fontsize',18,'fontweight','bold')
end
set(gca,'fontsize',16)


% ************************************
% Plot the uncertainties            **
% ************************************
var_1 = nanmean((test_rnd1 - repmat(test1,1,1,10000)).^2,3);
var_2 = nanmean((test_rnd2 - repmat(test2,1,1,10000)).^2,3);
a = [log10(num(:)) var_1(:) var_2(:)];
logic = ~isnan(a(:,2));
a = a(logic,:);
[~,I] = sort(a(:,1));
a = a(I,:);

figure(1);
subplot(1,2,2); hold on
plot([1e-3 1],[1e-3 1],'--','color',[1 1 1]*.8,'linewi',3)
scatter(sqrt(a(:,2)),sqrt(a(:,3)),100,a(:,1),'.')
set(gca,'xscale','log')
set(gca,'yscale','log')
col = colormap_CD([.45 .7 ; 0.35  .98],[.7 .4],[0 0],6);
h = colorbar;
ylabel(h,'log10( Number of measurements )','fontsize',18,'fontweight','bold')
caxis([0 6])
CDF_panel([2e-2 5e-1 2e-2 5e-1],[],{},'Uncertainty of offsets assuming i.i.d. pairs (^oC)','Uncertianty of offsets accounting for covariance (^oC)')
set(gca,'xtick',[3e-2 1e-1 3e-1],'xticklabel',[0.03 0.1 0.3])
set(gca,'ytick',[3e-2 1e-1 3e-1],'xticklabel',[0.03 0.1 0.3])
daspect([1 1 1])
text(0.023,0.55,'b.','fontsize',18,'fontweight','bold')
set(gca,'fontsize',16)

if 1,
    set(gcf,'position',[-14 18 6*3 9],'unit','inches')
    set(gcf,'position',[-14 18 6*3 9],'unit','inches')
    dir_save = HM_OI('save_figure_method');
    file_save= [dir_save,'FigAA_Compare_ship_level_',num2str(do_NpD),'.png'];
    CDF_save(1,'png',300,file_save);
end
