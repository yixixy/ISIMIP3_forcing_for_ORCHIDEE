
%%% function for calculate trend map
%%% contact: yixi@pku.edu.cn
%%% 2018.03.09
%{
function [new] = imresize_meanORsum3D(old, times, opt)
% imresize_meanORsum3D % imresize for global grids
% 
new = nan(size(old, 1)/times, size(old, 2)/times, size(old, 3));
for ln = 1:size(new, 1)
    for col = 1:size(new, 2)
        x = old(1+(ln-1)*times:ln*times, 1+(col-1)*times:col*times, :);
        for tt = 1:size(x, 3)
            temp = reshape(squeeze(x(:, :, tt)), [times*times, 1]);
            temp(isnan(temp)) = [];
            if ~isempty(temp)
                if opt==1
                    new(ln, col, tt) = mean(temp);
                else
                    new(ln, col, tt) = sum(temp);
                end
            end
        end
    end
end
end
%}
function [new] = imresize_meanORsum3D(old, times, opt)
% imresize_meanORsum3D % imresize for global grids
% 
temp = permute(reshape(old, ...
    [times size(old, 1)/times times size(old, 2)/times size(old, 3)]), [1 3 2 4 5]);
temp = reshape(temp, [times^2 size(old, 1)/times size(old, 2)/times size(old, 3)]);
if opt==1
    new = squeeze(nanmean(temp, 1));
else
    new = squeeze(nansum(temp, 1));
end
end