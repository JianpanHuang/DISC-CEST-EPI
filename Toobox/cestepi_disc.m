function img_corr = cestepi_disc(img, db0, b0, esp, pha_orien)
% FUNCTION:
%   To perform distortion self correction (DISC) for CEST-EPI
% INPUT:
%	img: CEST image to correct
%   db0: B0 field inhomogeneity
%   b0: field strength
%   esp: effective echo spacing
%   pha_orien: phase encoding orientation, can be 'x' or 'y'
% OUTPUT:
%   img_corr: DISC CEST image
% AUTHOR
%   Jianpan Huang, Email: jianpanhuang@outlook.com

    if strcmp(pha_orien, 'x')
        img = imrotate(img, 90);
        db0 = imrotate(db0, 90);
    end
    [xn, yn] = size(img);
    gama = 42.58e6;
    pix_shift = db0*1e-6*gama*b0*esp*yn; % db0(Hz)*ESP(effective echo spacing)*Npe, transfer db0 in ppm to db0 in pixel
    pe_x = (1:yn)';
    img_corr = zeros(xn, yn);
    for m = 1:xn
    %     intensity_line = img(m,:);
        intensity_line = img(:,m);
%         intensity_line_max = max(intensity_line(:));
        pix_shift_line = pix_shift(:,m);
        intensity_line_corr = interp1(pe_x-pix_shift_line, intensity_line, pe_x, 'pchip', 'extrap'); % 'extrap'
        img_corr(:,m) = intensity_line_corr;
    end
    img_corr(img_corr>max(img(:))) = max(img(:));
    img_corr(img_corr<min(img(:))) = min(img(:));
    if strcmp(pha_orien, 'x')
        img_corr = imrotate(img_corr, -90);
    end
end