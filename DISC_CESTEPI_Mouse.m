clear all, close all, clc
addpath(genpath(pwd));

%% Set parameters
file_path = 'Data';
folder_name = 'Mouse';
data_path = [file_path,filesep,folder_name];
if ~exist("data_path","dir")
    mkdir(data_path);
end
bcg_thres = 0.5; % Threshold (normally 0~1) set for backgroud removal
roi_subj_name = 'roi_bcg'; % ROI name of subject for background removal
db0_name = ['db0','_',roi_subj_name]; % Name of deltaB0 map
b0 = 3; % 3T
gama = 42.576; % *1e6

%% Load data
load([file_path, filesep, 'MouseEPI.mat']);
[xn, yn, wn] = size(img_all);

%% Process the CEST-EPI data
[img, offs, img_m0] = separate_z_m0(img_all, offs_all);
% remove background
roi = draw_load_roi(data_path, img_m0, [roi_subj_name, '_cestepi'], 'auto', bcg_thres);
img_nobcg = img.*repmat(roi, [1,1,size(img, 3)]);
% generate deltaB0
db0 = generate_load_db0_spline(data_path, [db0_name, '_cestepi'], img_nobcg, offs, roi);
sigma = 1.7;
db0 = imgaussfilt(db0,sigma,'Padding',0);

%% Perform distortion self correction
esp = 43.3392/xn*1e-3; % in sec, effective echo spacing
for m = 1:wn
    img_all_disc(:,:,m) = cestepi_disc(img_all(:,:,m), db0, b0, esp, 'y'); 
end

%% Process the DISC-CEST-EPI data
[img_disc, offs, img_m0_disc] = separate_z_m0(img_all_disc, offs_all);
% remove background
roi_disc = draw_load_roi(data_path, img_m0_disc, [roi_subj_name, '_cestepi_disc'], 'auto', bcg_thres);
img_disc_nobcg = img_disc.*repmat(roi_disc, [1,1,size(img_disc, 3)]);
% generate deltaB0
db0_disc = generate_load_db0_disc(data_path, [db0_name,'_cestepi_disc'], img_disc_nobcg, offs, roi_disc);
db0_disc = imgaussfilt(db0_disc,sigma,'Padding',0);

%% Display the results
% deltaB0 maps
figure,set(gcf,'unit','normalized','position',[0.2,0.1,0.6,0.8]);
subplot(2,2,1), imagesc(db0*gama*b0), colormap(gray); axis off; caxis([-100, 100]); colorbar; hold on;
title('\DeltaB_0 before correction'); hold off;
subplot(2,2,2), imagesc(db0_disc*gama*b0), colormap(gray); axis off; caxis([-100, 100]); colorbar; hold on; 
title('\DeltaB_0 after correction'); hold off; 
% images
subplot(2,2,3), imagesc(img_m0), colormap(gray); axis off; colorbar; hold on;
title('M_0 before correction'); hold off;
subplot(2,2,4), imagesc(img_m0_disc), colormap(gray); axis off; colorbar; hold on;
title('M_0 after correction'); hold off; 