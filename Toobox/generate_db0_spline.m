function db0 = generate_db0_spline(img, offs, roi)
% FUNCTION:
%   To generate deltaB0 map using spline interpolation
% INPUT:
%   img: images used for deltaB0 map generation
%   offs: frequency offsets
%   roi: ROI for deltaB0 map generation
%   method: could be 'spline' or 'lorentz'
% OUTPUT:
%   db0: deltaB0 map
% REFERENCE
%   Kim M, et al., Magnetic Resonance in Medicine, 2009, 61(6): 1441-1450.
% AUTHOR:
%   Jianpan Huang, Email: jianpanhuang@outlook.com

%%
[xn, yn, ~] = size(img);
if nargin < 3
    roi = ones(xn, yn);
end
if nargin < 4
    method = 'spline';
end

% Generate deltaB0 map
db0 = zeros(xn, yn);
offs_interp = min(offs(:)):0.01:max(offs(:));
[row, col] = find(abs(roi)>0);
h = waitbar(0,'Generating \DeltaB0 map, please wait >>>>>>');
for n = 1:length(row)
    z_spec = squeeze(img(row(n),col(n),:));
    z_spec_interp = spline(offs, z_spec, offs_interp);
    [~,ind] = min(z_spec_interp);
    shift_val = offs_interp(ind);
    if abs(shift_val) > 1 % if rNOE peak is lower than water (possible for the fat region in in vivo study), this checking procedure can fix it
        offs_interp_check = -abs(shift_val)+0.4:0.01:abs(shift_val)-0.4;
        z_spec_interp_check = spline(offs, z_spec, offs_interp_check);
        [~,ind_check] = min(z_spec_interp_check);
        ratio = ind_check/length(offs_interp_check);
        if ratio>0.2 && ratio<0.8
            shift_val = offs_interp_check(ind_check);
        end
    end
    db0(row(n),col(n))= shift_val;
    waitbar(n/length(row),h)
end
delete(h)
end