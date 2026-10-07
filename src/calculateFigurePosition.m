function position = calculateFigurePosition(screenSize_px, preferredSize_px)
%CALCULATEFIGUREPOSITION Fit and center the Explorer on an available display.
%
% screenSize_px is the MATLAB ScreenSize vector [left bottom width height]
% in pixels. The default preferred size is 1440 by 880 px. The returned
% [left bottom width height] position stays within the reported display,
% leaving up to 20 px horizontally and 45 px vertically for desktop chrome.
%
% A reported display smaller than 320 by 240 px carries no usable size
% information (MATLAB has reported [1 1 1 1] when no display is attached),
% so the preferred size is returned instead of a window shrunk to fit it.

if nargin < 2
    preferredSize_px = [1440 880];
end
validateattributes(screenSize_px, {'numeric'}, {'real', 'finite', 'vector', 'numel', 4}, ...
    mfilename, 'screenSize_px');
validateattributes(preferredSize_px, {'numeric'}, {'real', 'finite', 'positive', ...
    'vector', 'numel', 2}, mfilename, 'preferredSize_px');

screenSize_px = double(screenSize_px(:)');
preferredSize_px = double(preferredSize_px(:)');
if any(screenSize_px(3:4) <= 0)
    error('DataCenterCooling:InvalidScreenSize', ...
        'screenSize_px must have positive width and height.');
end

minimumScreenSize_px = [320 240];
if any(screenSize_px(3:4) < minimumScreenSize_px)
    position = [screenSize_px(1:2) preferredSize_px];
    return
end

outerPadding_px = min([40 90], max([0 0], screenSize_px(3:4) - [1 1]));
availableSize_px = max([1 1], screenSize_px(3:4) - outerPadding_px);
figureSize_px = min(preferredSize_px, availableSize_px);
left_px = screenSize_px(1) + round((screenSize_px(3) - figureSize_px(1)) / 2);
bottom_px = screenSize_px(2) + round((screenSize_px(4) - figureSize_px(2)) / 2);
position = [left_px bottom_px figureSize_px];
end
