%% Set directory
dir = "Your Directory Here";
% We used EEGLAB (Delorme A & Makeig S, 2004) to analyze the EEG data
addpath(genpath("C:\Program Files\MATLAB\R2023a\eeglab2023.0"))
addpath(genpath(dir))
%% innitialize matrices for ersp's 
all_ersp_av = zeros(29,64,38,200);
all_ersp_ap = zeros(29,64,38,200);
%% get time frequancy measures for all channels

counter = 1;
for sub = [3:7,9:11,13:21,23:27,29:35]
    
    filename = 'Epoched_for_TF_av1.set';
    artrej_filename = convertStringsToChars(strcat(string(sub),"_ds_hpfilt_avref_ICAcorr_epoched_stim_artrej.set"));
    filepath = convertStringsToChars(strcat(dir,"\Data_",string(sub),filesep));
    EEG = pop_loadset('filename', filename, 'filepath', filepath);
    %remove trials to create a unified trials pool
    artrej = pop_loadset('filename', artrej_filename, 'filepath', filepath);
    AV_trials = find([artrej.event.bini] == 1);
    epoch = [artrej.event.epoch];
    AV_trials_id = epoch(AV_trials); %real trial nums of av trials
    rejected = find(artrej.reject.rejmanual);
    [rejected_av,rejected_av_id,~] = intersect(AV_trials_id,rejected);
    EEG = pop_select(EEG,'notrial',rejected_av_id);
    
    
    for chan = 1:64     
        [ersp,~,~,times,freqs] = pop_newtimef( EEG, 1, chan, [-1000  4998], [3  8] , 'topovec', chan, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'FCz', 'baseline',[0], 'freqs', [3 40], 'freqscale', 'log', 'plotphase', 'off', 'padratio', 1);
        all_ersp_av(counter,chan,:,:) = ersp;
    end

    filename = 'Epoched_for_TF_app1.set';
    filepath = convertStringsToChars(strcat(dir,"\Data_",string(sub),filesep));
    EEG = pop_loadset( 'filename', filename, 'filepath', filepath );
    AP_trials = find([artrej.event.bini] == 2);
    epoch = [artrej.event.epoch];
    AP_trials_id = epoch(AP_trials); %real trial nums of av trials
    rejected = find(artrej.reject.rejmanual);
    %fix scenarios where practice trials was coded as AP-AP ones
    if max(size(AP_trials_id))==151
        rejected = [[1,2,3,4],rejected];
    end
    [rejected_ap,rejected_ap_id,~] = intersect(AP_trials_id,rejected);
    EEG = pop_select(EEG,'notrial',rejected_ap_id);
    figure; 
    for chan = 1:64     
        [ersp,~,~,times,freqs] = pop_newtimef( EEG, 1, chan, [-1000  4998], [3  8] , 'topovec', chan, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'FCz', 'baseline',[0], 'freqs', [3 40], 'freqscale', 'log', 'plotphase', 'off', 'padratio', 1);
        all_ersp_ap(counter,chan,:,:) = ersp;
    end
    counter = counter+1;
    save(strcat(dir,"\data\all_ersp_av.mat"),"all_ersp_av");
    save(strcat(dir,"\data\all_ersp_ap.mat"),"all_ersp_ap");
end
save(strcat(dir,"\data\times.mat"),"times");
save(strcat(dir,"\data\freqs.mat"),"freqs");
chanlocs = EEG.chanlocs(1:64);
save(strcat(dir,"\data\chanlocs.mat"),"chanlocs");
%% Load matrices (if you want to analyze in different session)
all_ersp_av = load(strcat(dir,"\data\all_ersp_av.mat"));
all_ersp_av = all_ersp_av.all_ersp_av;
all_ersp_ap = load(strcat(dir,"\data\all_ersp_ap.mat"));
all_ersp_ap = all_ersp_ap.all_ersp_ap;
times = load(strcat(dir,"\data\times.mat"));
times = times.times;
freqs = load(strcat(dir,"\data\freqs.mat"));
freqs = freqs.freqs;
chanlocs = load(strcat(dir,"\data\chanlocs.mat"));
chanlocs = chanlocs.chanlocs;
%% Topographical plot of theta activity
tiledlayout (1,3) %create grid of 3 plots
time_idx = find(times>0 & times<3000);
theta_idx = find(freqs>3.2 & freqs < 7.7);
%define centered vectors of values for topplot
%ap-ap
theta_mat_ap = squeeze(all_ersp_ap(:,:,theta_idx,time_idx));
theta_vec_ap = mean(theta_mat_ap,[1,3,4]);
theta_vec_ap_c = theta_vec_ap-mean(theta_vec_ap);
%av-av
theta_mat_av = squeeze(all_ersp_av(:,:,theta_idx,time_idx));
theta_vec_av = mean(theta_mat_av,[1,3,4]);
theta_vec_av_c = theta_vec_av-mean(theta_vec_av);
%ap-ap - av-av
theta_vec_d = theta_vec_av-theta_vec_ap;
%find higest value for color scale definition
max_abs_value = max([max(abs(theta_vec_d)),max(abs(theta_vec_ap_c)),max(abs(theta_vec_d))]);

nexttile
topoplot(theta_vec_ap_c,chanlocs, 'maplimits',[-0.75,0.75]*max_abs_value,'style','straight')%topplot of centered theta values
title('AP-AP','FontSize',20)
%topographical plot for av-av condition
nexttile
topoplot(theta_vec_av_c,chanlocs,'maplimits',[-0.75,0.75]*max_abs_value,'style','straight')%topplot of centered theta values
title('AV-AV','FontSize',20)
%topographical plot for av-av-ap-ap
nexttile
topoplot(theta_vec_d,chanlocs,'maplimits',[-0.75,0.75]*max_abs_value,'style','straight')%topplot of centered theta values
title('AV-AV − AP-AP','FontSize',20)
a = colorbar;
a.FontSize = 18;
a.Label.String = 'Power (dB)';
a.Label.FontSize = 18;
colormap parula

%% Topographical plot of alpha activity (For SI)
tiledlayout (1,3) %create grid of 3 plots
time_idx = find(times>0 & times<3000);
alpha_idx = find(freqs>8 & freqs < 12);
%define centered vectors of values for topplot
%ap-ap
alpha_mat_ap = squeeze(all_ersp_ap(:,:,alpha_idx,time_idx));
alpha_vec_ap = mean(alpha_mat_ap,[1,3,4]);
alpha_vec_ap_c = alpha_vec_ap-mean(alpha_vec_ap);
%av-av
alpha_mat_av = squeeze(all_ersp_av(:,:,alpha_idx,time_idx));
alpha_vec_av = mean(alpha_mat_av,[1,3,4]);
alpha_vec_av_c = alpha_vec_av-mean(alpha_vec_av);
%ap-ap - av-av
alpha_vec_d = alpha_vec_av-alpha_vec_ap;
%find higest value for color scale definition
max_abs_value = max([max(abs(alpha_vec_d)),max(abs(alpha_vec_ap_c)),max(abs(alpha_vec_d))]);

nexttile
topoplot(alpha_vec_ap_c,chanlocs, 'maplimits',[-0.75,0.75]*max_abs_value,'style','straight')%topplot of centered alpha values
title('AP-AP','FontSize',20)
%topographical plot for av-av condition
nexttile
topoplot(alpha_vec_av_c,chanlocs,'maplimits',[-0.75,0.75]*max_abs_value,'style','straight')%topplot of centered alpha values
title('AV-AV','FontSize',20)
%topographical plot for av-av-ap-ap
nexttile
topoplot(alpha_vec_d,chanlocs,'maplimits',[-0.75,0.75]*max_abs_value,'style','straight')%topplot of centered alpha values
title('AV-AV − AP-AP','FontSize',20)
a = colorbar;
a.FontSize = 18;
a.Label.String = 'Power (dB)';
a.Label.FontSize = 18;
colormap parula

%% Topographical plot of beta activity (For SI)
tiledlayout (1,3) %create grid of 3 plots
time_idx = find(times>0 & times<3000);
beta_idx = find(freqs>12 & freqs < 30);
%define centered vectors of values for topplot
%ap-ap
beta_mat_ap = squeeze(all_ersp_ap(:,:,beta_idx,time_idx));
beta_vec_ap = mean(beta_mat_ap,[1,3,4]);
beta_vec_ap_c = beta_vec_ap-mean(beta_vec_ap);
%av-av
beta_mat_av = squeeze(all_ersp_av(:,:,beta_idx,time_idx));
beta_vec_av = mean(beta_mat_av,[1,3,4]);
beta_vec_av_c = beta_vec_av-mean(beta_vec_av);
%ap-ap - av-av
beta_vec_d = beta_vec_av-beta_vec_ap;
%find higest value for color scale definition
max_abs_value = max([max(abs(beta_vec_d)),max(abs(beta_vec_ap_c)),max(abs(beta_vec_d))]);

nexttile
topoplot(beta_vec_ap_c,chanlocs, 'maplimits',[-0.75,0.75]*max_abs_value,'style','straight')%topplot of centered beta values
title('AP-AP','FontSize',20)
%topographical plot for av-av condition
nexttile
topoplot(beta_vec_av_c,chanlocs,'maplimits',[-0.75,0.75]*max_abs_value,'style','straight')%topplot of centered beta values
title('AV-AV','FontSize',20)
%topographical plot for av-av-ap-ap
nexttile
topoplot(beta_vec_d,chanlocs,'maplimits',[-0.75,0.75]*max_abs_value,'style','straight')%topplot of centered beta values
title('AV-AV − AP-AP','FontSize',20)
a = colorbar;
a.FontSize = 18;
a.Label.String = 'Power (dB)';
a.Label.FontSize = 18;
colormap parula

%% Plot time frequancy images
time_idx = find(times>-1000 & times < 3000);
freq_idx_forplot = find(freqs >0  & freqs < 25);
%average and center FCz data
mean_ersp_FCz_app = squeeze(mean(all_ersp_ap(:,47,:,:),1)-mean(all_ersp_ap,"all"));
mean_ersp_FCz_avo = squeeze(mean(all_ersp_av(:,47,:,:),1)-mean(all_ersp_av,"all"));

max_abs_value_tf = max([max(abs(mean_ersp_FCz_avo(:))),max(abs(mean_ersp_FCz_app(:)))]);
tiledlayout(1,2)
nexttile
imagesc(times(time_idx),freqs(freq_idx_forplot),mean_ersp_FCz_app(freq_idx_forplot,time_idx))
set(gca,'YScale','log','YDir','normal')
caxis([-0.5 0.5]*max_abs_value_tf);
xlabel('Time (ms)', 'fontsize', 18);
ylabel('Frequency (Hz)', 'fontsize', 18);
title('AP-AP', 'fontsize', 20);
ax=gca;
ax.FontSize = 18;
ylim([3,25])
nexttile
imagesc(times(time_idx),freqs(freq_idx_forplot),mean_ersp_FCz_avo(freq_idx_forplot,time_idx))
caxis([-0.5 0.5]*max_abs_value_tf);
set(gca,'YScale','log','ydir','normal')
a = colorbar;
a.FontSize = 18;
a.Label.String = 'Power (dB)';
a.Label.FontSize = 18;
ax=gca;
ax.FontSize = 18;
ylim([3,25])

xlabel('Time (ms)', 'fontsize', 18);
title('AV-AV', 'fontsize', 20);
colormap("parula")

%% Plot image of difference between ap-ap and av-av
mean_diff_ersp_FCz = mean_ersp_FCz_avo-mean_ersp_FCz_app;
figure;
imagesc(times,freqs,mean_diff_ersp_FCz)
set(gca,'YScale','log','YDir','normal')
colorbar
colormap(parula)

%% Plot contionus theta by time and preform cluster permutations test

time_idx = find(times>-500 & times < 3400);
freq_theta_idx = find(freqs >3.2  & freqs < 7.7);
Fcz_app_theta= zeros(29,length(time_idx));
Fcz_avo_theta = zeros(29,length(time_idx));
for j = [1:29]
    Fcz_app_theta(j,:) = squeeze(mean(all_ersp_ap(j,47,freq_theta_idx,time_idx),3));
    Fcz_avo_theta(j,:) = squeeze(mean(all_ersp_av(j,47,freq_theta_idx,time_idx),3));
end

%For the cluster-based permutation testing, we used the function
%'permutest', written by Eden M. Gerber. 
% (https://www.mathworks.com/matlabcentral/fileexchange/71737-permutest)
[clusters, p_values, t_sums, permutation_distribution ] = permutest(Fcz_avo_theta',Fcz_app_theta',true,0.25);

dif_wave = Fcz_avo_theta'-Fcz_app_theta';
dif_wave = dif_wave';
STE_diff = std(squeeze(dif_wave))/sqrt(29);
x = times(time_idx);
y_ap = mean(squeeze(Fcz_app_theta));
STE_app = std(squeeze(Fcz_app_theta))/sqrt(29);
y_av = mean(squeeze(Fcz_avo_theta));
STE_avo = std(squeeze(Fcz_avo_theta))/sqrt(29);

% To plot the line with continuous errors shaeded, we used the function
% boundedline.m by Kelly Kearny, https://www.mathworks.com/matlabcentral/fileexchange/27485-boundedline-m
addpath(genpath('C:\Program Files\MATLAB\R2020b\boundedline-pkg-master'));
figure;
ax=gca;
ax.FontSize = 18;
[l,p]=boundedline(x,y_ap,STE_app,'-g',x,y_av,STE_avo,'-r','transparency', 0.2,'alpha');

title('Theta Power As a Function Of Time', 'fontsize', 20);
xlabel('Time (ms)', 'fontsize', 18);
ylabel('Theta Power (dB)', 'fontsize', 18);
legend('AP-AP','AV-AV', 'fontsize', 18);
significant_time_idx = clusters {1};
patch('Faces',[1,2,3,4],'Vertices',[times(significant_time_idx(1)) -1 ; times(significant_time_idx(1)) 1;times(significant_time_idx(end)) 1;times(significant_time_idx(end)) -1],'FaceAlpha',0.08,'HandleVisibility','off');
ylim ([-0.9,0.4]);


%% save aggeragated FCz theta data
time_idx = find(times>0 & times < 3000);
freq_theta_idx = find(freqs >3.2  & freqs < 7.7);

for i = [1:29]
   FCz_app_vec(i) = mean(sum(all_ersp_ap(i,47,freq_theta_idx,time_idx)));
   FCz_avo_vec(i) = mean(sum(all_ersp_av(i,47,freq_theta_idx,time_idx)));    
end
[h,p,confint,stats]=ttest(FCz_app_vec,FCz_avo_vec);


%% save aggeragated FCz alpha data (for SI analysis)
time_idx = find(times>0 & times < 3000);
freq_alpha_idx = find(freqs >8  & freqs < 12);

for i = [1:29] 
   FCz_app_vec_alpha(i) = mean(sum(all_ersp_ap(i,47,freq_alpha_idx,time_idx)));
   FCz_avo_vec_alpha(i) = mean(sum(all_ersp_av(i,47,freq_alpha_idx,time_idx)));    
end
[h,p,confint,stats]=ttest(FCz_app_vec_alpha,FCz_avo_vec_alpha);

%% save aggeragated alpha data for posterior electrode Oz (for SI analysis)
time_idx = find(times>0 & times < 3000);
freq_alpha_idx = find(freqs >8  & freqs < 12);

for i = [1:29] 
   Oz_app_vec_alpha(i) = mean(sum(all_ersp_ap(i,29,freq_alpha_idx,time_idx)));
   Oz_avo_vec_alpha(i) = mean(sum(all_ersp_av(i,29,freq_alpha_idx,time_idx)));    
end
[h,p,confint,stats]=ttest(Oz_app_vec_alpha,Oz_avo_vec_alpha);

%% Save aggeragated FCz beta data (for SI analysis)
time_idx = find(times>0 & times < 3000);
freq_beta_idx = find(freqs >12  & freqs < 30);

for i = [1:29]
   FCz_app_vec_beta(i) = mean(sum(all_ersp_ap(i,47,freq_beta_idx,time_idx)));
   FCz_avo_vec_beta(i) = mean(sum(all_ersp_av(i,47,freq_beta_idx,time_idx)));    
end
[h,p,confint,stats]=ttest(FCz_app_vec_beta,FCz_avo_vec_beta);



%% Plot N2 and LPC:
%load stimulus-locked ERP file 
filepath = convertStringsToChars(strcat(dir,'\Data'));
ERP = pop_loaderp( 'filename', 'grand_av_all_hpfilt30_stim.erp', 'filepath',filepath );
%plot ERPs
ERP = pop_ploterps( ERP, [ 1 2],  47 , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 1 1], 'ChLabel', 'on', 'FontSizeChan',...
  24, 'FontSizeLeg',  12, 'FontSizeTicks',  22, 'LegPos', 'none', 'Linespec', {'r-' , 'g-' }, 'LineWidth',  1, 'Maximize', 'on', 'Position',...
 [ 31.5 4.03846 106.9 31.9231], 'SEM', 'on', 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0.8, 'xscale', [ -500.0 1000   -400:400:1000 ],...
 'YDir', 'normal', 'yscale', [ -5.0 5.0  -5:2:6 ] );
ERP = pop_ploterps( ERP, [ 1 2],  31 , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 1 1], 'ChLabel', 'on', 'FontSizeChan',...
  24, 'FontSizeLeg',  12, 'FontSizeTicks',  22, 'LegPos', 'none', 'Linespec', {'r-' , 'g-' }, 'LineWidth',  1, 'Maximize', 'on', 'Position',...
 [ 31.5 4.03846 106.9 31.9231], 'SEM', 'on', 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0.8, 'xscale', [ -500.0 1000   -400:400:1000 ],...
 'YDir', 'normal', 'yscale', [ -5.0 5.5  -5:2:6 ] );
%% Plot scalplot for N2
ERP = pop_scalplot( ERP, [2], [300 330] , 'Blc', 'pre', 'Colormap', 'viridis', 'Electrodes', 'on', 'Legend', 'bn-la', 'Maplimit', 'absmax', 'Mapstyle', 'map', 'Maptype', '2D', 'Mapview', '+X', 'Plotrad',  0.55, 'Position',...
 [ 50 28.6667 514.333 390.667], 'Value', 'mean' );
colormap parula


%% Plot scalplot for LPC
ERP = pop_scalplot( ERP, [2], [650 750] , 'Blc', 'pre', 'Colormap', 'viridis', 'Electrodes', 'on', 'FontName', 'Courier New', 'Legend', 'bn-la', 'Maplimit', 'absmax', 'Mapstyle', 'map', 'Maptype', '2D', 'Mapview', '+X', 'Plotrad',  0.55, 'Position',...
 [ 50 28.6667 514.333 390.667], 'Value', 'mean' );
colormap parula

%% Plot CRN
%load response-locked ERP file (that was created in
%preprocessing_pipeline.mlx)
ERP = pop_loaderp( 'filename', 'grand_av_all_hpfilt30_res.erp', 'filepath',filepath);
%plot ERP
ERP = pop_ploterps( ERP, [ 1 2],  47 , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 1 1], 'ChLabel', 'on', 'FontSizeChan',...
  24, 'FontSizeLeg',  12, 'FontSizeTicks',  22, 'LegPos', 'none', 'Linespec', {'r-' , 'g-' }, 'LineWidth',  1, 'Maximize', 'on', 'Position',...
 [ 31.5 4.03846 106.9 31.9231], 'SEM', 'on', 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0.8, 'xscale', [ -400.0 400   -400:200:400 ],...
 'YDir', 'normal', 'yscale', [ -5.0 5.0  -5:2:6 ] );
%% Plot scalplot for CRN
ERP = pop_scalplot( ERP, [2], [ -50 50] , 'Blc', 'pre', 'Colormap', 'viridis', 'Electrodes', 'on', 'FontName', 'Courier New', 'Legend', 'bn-la', 'Maplimit', 'maxmin', 'Mapstyle', 'map', 'Maptype', '2D', 'Mapview', '+X', 'Plotrad',  0.55, 'Position',...
 [ 50 28.6667 514.333 390.667], 'Value', 'mean' );
colormap parula

%% Compute stimulus-locked peak amplitode between 250 to 350
filename = convertStringsToChars(strcat(dir,'\Data_Processing\list30.txt'));
ALLERP = pop_geterpvalues( filename,...
    [250 350], [ 1 2],  47 , 'Baseline', 'pre', 'FileFormat','wide','Filename',...
    convertStringsToChars(strcat(dir,'\peakamp_stim_FCz200400.csv')), ...
    'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'peakampbl', 'Neighborhood',  4, 'PeakOnset',  1, 'Peakpolarity', 'negative',...
    'Peakreplace', 'absolute', 'Resolution',  3, 'SendtoWorkspace', 'on' );
Ampstim250350 = squeeze(ERP_MEASURES);
Ampstim250350 = Ampstim250350';

%statistical test:
[h,p,confint,stats]=ttest(Ampstim250350(:,1),Ampstim250350(:,2));

%% Compute stimulus-locked peak latency between 250 to 350
filename = convertStringsToChars(strcat(dir,'\Data_Processing\list30.txt'));

ALLERP = pop_geterpvalues(filename, [250 350], [ 1 2],  47 , 'Baseline', 'pre', 'FileFormat', 'wide', 'Fracreplace', 'NaN', 'InterpFactor',  1,...
 'Measure', 'peaklatbl', 'Neighborhood',  5, 'PeakOnset',  1, 'Peakpolarity', 'negative', 'Peakreplace', 'absolute', 'Resolution',  3,...
 'SendtoWorkspace', 'on' );
Latstim250350 = squeeze (ERP_MEASURES);
Latstim250350 = Latstim250350';
%statistical test:
[h,p,confint,stats]=ttest(Latstim250350(:,1),Latstim250350(:,2));

%% Compute response-locked peak amplitode between -50 to 50

filename = convertStringsToChars(strcat(dir,'\Data_Processing\list30_res.txt'));
ALLERP = pop_geterpvalues( filename,...
    [-50 50], [ 1 2],  47 , 'Baseline', 'pre', 'FileFormat','wide','Filename',...
    convertStringsToChars(strcat(dir,'\peakamp_stim_FCz200400.csv')), ...
    'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'peakampbl', 'Neighborhood',  4, 'PeakOnset',  1, 'Peakpolarity', 'negative',...
    'Peakreplace', 'absolute', 'Resolution',  3, 'SendtoWorkspace', 'on' );
Ampstim5050 = squeeze(ERP_MEASURES);
Ampstim5050 = Ampstim5050';

%statistical test:
[h,p,confint,stats]=ttest(Ampstim5050(:,1),Ampstim5050(:,2));

%% Compute response-locked peak latency between -50 to 50
filename = convertStringsToChars(strcat(dir,'\Data_Processing\list30_res.txt'));
ALLERP = pop_geterpvalues(filename, [-50 50], [ 1 2],  47 , 'Baseline', 'pre', 'FileFormat', 'wide', 'Fracreplace', 'NaN', 'InterpFactor',  1,...
 'Measure', 'peaklatbl', 'Neighborhood',  5, 'PeakOnset',  1, 'Peakpolarity', 'negative', 'Peakreplace', 'absolute', 'Resolution',  3,...
 'SendtoWorkspace', 'on' );
Latstim5050 = squeeze (ERP_MEASURES);
Latstim5050 = Latstim5050';
%statistical test:
[h,p,confint,stats]=ttest(Latstim5050(:,1),Latstim5050(:,2));
%% Compute stimulus-locked mean amplitode between 650 to 750 at pz
filename = convertStringsToChars(strcat(dir,'\Data_Processing\list30.txt'));
ALLERP = pop_geterpvalues( filename,...
    [650 750], [ 1 2],  31 , 'Baseline', 'pre', 'FileFormat','wide','Filename',...
    convertStringsToChars(strcat(dir,'\meanamp_stim_Pz650750.csv')), ...
    'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'meanbl', 'Neighborhood',  4, 'PeakOnset',  1, 'Peakpolarity', 'negative',...
    'Peakreplace', 'absolute', 'Resolution',  3, 'SendtoWorkspace', 'on' );
Meanstim650750 = squeeze(ERP_MEASURES);
Meanstim650750 = Meanstim650750';
%statistical test:
[h,p,confint,stats]=ttest(Meanstim650750(:,1),Meanstim650750(:,2));


%% Create a unified table of all ERP and ERSP measures,  for further analysis in R

ampStim250350_av = Ampstim250350(:,1);
ampStim250350_ap = Ampstim250350(:,2);

latStim250350_av = Latstim250350(:,1);
latStim250350_ap = Latstim250350(:,2);

ampStim5050_av = Ampstim5050(:,1);
ampStim5050_ap = Ampstim5050(:,2);

latStim5050_av = Latstim5050(:,1);
latStim5050_ap = Latstim5050(:,2);

Meanstim650750_av = Meanstim650750(:,1);
Meanstim650750_ap = Meanstim650750(:,2);

ThetaFCz03000_av = FCz_avo_vec';
ThetaFCz03000_ap = FCz_app_vec';

AlphaFCz03000_av = FCz_avo_vec_alpha';
AlphaFCz03000_ap = FCz_app_vec_alpha';

AlphaOz03000_av = Oz_avo_vec_alpha';
AlphaOz03000_ap = Oz_app_vec_alpha';

BetaFCz03000_av = FCz_avo_vec_beta';
BetaFCz03000_ap = FCz_app_vec_beta';

subject = [3:7,9:11,13:21,23:27,29:35];
unitable = table(subject',ampStim250350_av,ampStim250350_ap,latStim250350_av,latStim250350_ap ...
    , BetaFCz03000_av, BetaFCz03000_ap, ThetaFCz03000_av,ThetaFCz03000_ap,AlphaFCz03000_av,AlphaFCz03000_ap,AlphaOz03000_av,AlphaOz03000_ap,ampStim5050_av ...
    ,ampStim5050_ap,latStim5050_av,latStim5050_ap,Meanstim650750_av,Meanstim650750_ap);

writetable(unitable,convertStringsToChars(strcat(dir,'\Data\all_eeg_measures.csv')))

%% innitialize matrix for single-trial theta
trials_fcz_theta = zeros(29,200,298);
indices = struct();
%% get time-frequancy for each trial of each subject, combined for both conditions
all_ersp = zeros(29,64,38,200);
trials_fcz_theta = zeros(29,200,298);
indices = struct();
sub_counter = 1;
chan = 47;
for sub = [3:7,9:11,13:21,23:27,29:35]
    artrej_filename = convertStringsToChars(strcat(string(sub),"_ds_hpfilt_avref_ICAcorr_epoched_stim_artrej.set"));
    filename = 'Epoched_for_TF_unified.set';
    filepath = convertStringsToChars(strcat(dir,"\Data_",string(sub),filesep));
    EEG = pop_loadset('filename', filename, 'filepath', filepath);
    %use artrej file to be able to later index clean AP-AP and AV-AV trials
    artrej = pop_loadset('filename', artrej_filename, 'filepath', filepath);
    AV_trials = find([artrej.event.bini] == 1);
    epoch = [artrej.event.epoch];
    AV_trials_id = epoch(AV_trials); %real trial nums of av trials
    rejected = find(artrej.reject.rejmanual);
    [rejected_av,rejected_av_id,ib] = intersect(AV_trials_id,rejected);
    AP_trials = find([artrej.event.bini] == 2);
    epoch = [artrej.event.epoch];
    AP_trials_id = epoch(AP_trials); %real trial nums of av trials
    %fix scenarios where practice trials was coded as AP-AP ones
    if max(size(AP_trials_id))==151
        rejected = [[1,2,3,4],rejected];
    end
    [rejected_ap,rejected_ap_id,ib] = intersect(AP_trials_id,rejected);
    %save all indices for later use:
    indices(sub).ap = AP_trials_id;
    indices(sub).av = AV_trials_id;
    indices(sub).rejected = rejected;
    indices(sub).rej_av = rejected_av_id;
    indices(sub).rej_ap = rejected_ap_id;

    [ersp,itc,powbasw,times,freqs,boot1,boot2,tfdata] = pop_newtimef( EEG, 1,chan, [-1000  4998], [3  8] , 'topovec', chan, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'FCz', 'baseline',[0], 'freqs', [3 40], 'freqscale', 'log', 'plotphase', 'off', 'padratio', 1);
    size_tf = size(tfdata);
    num_trials = size_tf(3);
    freq_theta_idx = find(freqs > 3.2 & freqs < 7.7);
    tfdata_theta = mean(tfdata(freq_theta_idx,:,:),1);
    trials_fcz_theta(sub_counter,:,299-num_trials:end) = tfdata_theta; 
    sub_counter = sub_counter+1;

    save(strcat(dir,"\data\trials_fcz_theta.mat"),"trials_fcz_theta");
end
%% Load single trial theta data (if want to analize in different session)
%x1 = load(strcat(dir,"\data\trials_fcz_theta.mat"));
%trials_fcz_theta = x1.trials_fcz_theta;
%indices = load(strcat(dir,"\data\indices.mat"));
%indices = indices.indices;
%% extract single trial theta power
%convert complex signal to power (as in cohen & cavanagh., 2011 and many others)
trials_fcz_theta_pwr = real(trials_fcz_theta).^2 + imag(trials_fcz_theta).^2;
%index only relevant timepoints (between 0 to 3000 ms)
time_idx = find(times>0 & times < 3000);
relevnt_theta = trials_fcz_theta_pwr(:,time_idx,:);
%index baseline
baseline_idx = find(times<0);
baseline_mat = trials_fcz_theta_pwr(:,baseline_idx,:);
%normalize  according to baseline
baseline_by_sub = mean(baseline_mat,[2,3]); 
norm_relevnt_theta = pow2db(relevnt_theta./baseline_by_sub); %normalization
%average across timepoints in the relevant time window
mean_relevnt_theta = squeeze(mean(norm_relevnt_theta,2));
%transpose matrix
mean_relevnt_theta = mean_relevnt_theta';
%remove practice trials (4 first trials)
mean_relevnt_theta = mean_relevnt_theta(5:end,:);
%flatten for further conveniant r processing
theta_power = mean_relevnt_theta(:);
% create subject_id vector
subject_ids = [3:7,9:11,13:21,23:27,29:35];
subject = repelem(subject_ids,294);
subject = subject';%transpose
%create trial_idx vector
trial_idx = repmat(1:294,29,1);
trial_idx = trial_idx';%transpose
trial_idx = trial_idx(:);%flatten
theta_table = table(subject,trial_idx,theta_power);
writetable (theta_table,strcat(dir,'\all_thetas2405.csv'));


