function db0 = generate_load_db0_spline(path, db0_name, img, offs, roi)
% FUNCTION:
%   To generate or load deltaB0 map
% INPUT:
%   path: file path
%   db0_name: name of deltaB0 map
%   img: images used for deltaB0 map generation
%   offs: frequency offsets
%   roi: ROI for deltaB0 map generation
% OUTPUT:
%   db0: deltaB0 map
% AUTHOR:
%   Jianpan Huang, Email: jianpanhuang@outlook.com

%%
if ~exist([path, filesep, db0_name, '.mat'], 'file') == 1
    db0 =  generate_db0_spline(img, offs, roi);
    db0(db0>2|db0<-2) = 0;
    save([path, filesep, db0_name, '.mat'], 'db0') 
else
    load([path, filesep, db0_name, '.mat'], 'db0');
end
end