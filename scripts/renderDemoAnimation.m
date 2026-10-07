%RENDERDEMOANIMATION Generate the animated README and listing demo.
% The animation shows the predict-before-load step for the flow-limited
% scenario, the Explorer's feedback, and then a coolant-flow slider drag.
% Every frame comes from the app running on synthetic teaching scenarios.
% Only base MATLAB functions are used.

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot);
outputFile = fullfile(projectRoot, 'docs', 'explorer-demo.gif');
outputScale = 0.75;
app = DataCenterCoolingExplorer('Visible', 'off', 'Position', [40 40 1440 880]);
frames = {};
delays_s = [];

% Baseline case.
app.SelectPreset('Moderate liquid cooling');
frames{end + 1} = captureDemoFrame(app.Figure, outputScale);
delays_s(end + 1) = 2.0;

% The learner picks a scenario; the Explorer asks for a prediction first.
app.ChoosePreset('Flow-limited loop');
frames{end + 1} = captureDemoFrame(app.Figure, outputScale);
delays_s(end + 1) = 3.0;

% Show the "Rise" button being chosen.
riseButton = app.PredictionButtons(1);
buttonColor = riseButton.BackgroundColor;
riseButton.BackgroundColor = [0.99 0.80 0.55];
frames{end + 1} = captureDemoFrame(app.Figure, outputScale);
delays_s(end + 1) = 0.7;
riseButton.BackgroundColor = buttonColor;

% The scenario loads and the Explorer explains the computed change.
app.SubmitPrediction('rise');
frames{end + 1} = captureDemoFrame(app.Figure, outputScale);
delays_s(end + 1) = 5.0;

% Drag the coolant-flow slider up and back down; every view updates.
slider = app.Controls.coolantFlow;
dragFlows_kg_s = [linspace(0.08, 0.40, 9), linspace(0.36, 0.12, 7)];
for flow_kg_s = dragFlows_kg_s
    slider.Value = flow_kg_s;
    slider.ValueChangingFcn(slider, struct('Value', flow_kg_s));
    frames{end + 1} = captureDemoFrame(app.Figure, outputScale); %#ok<SAGROW>
    delays_s(end + 1) = 0.25; %#ok<SAGROW>
end
delays_s(end) = 3.0;

writeDemoGif(frames, delays_s, outputFile);
delete(app.Figure);
clear app
fprintf('Wrote %s (%d frames).\n', outputFile, numel(frames));

function rgb = captureDemoFrame(figureHandle, scale)
imageFile = [tempname '.png'];
exportapp(figureHandle, imageFile);
rgb = imread(imageFile);
delete(imageFile);
if scale ~= 1
    rgb = downscaleImage(rgb, scale);
end
end

function scaled = downscaleImage(rgb, scale)
% Light smoothing before interpolation limits aliasing in small text.
kernel = [1 2 1] / 4;
source = double(rgb);
[rows, columns, channels] = size(source);
newRows = round(rows * scale);
newColumns = round(columns * scale);
[queryX, queryY] = meshgrid(linspace(1, columns, newColumns), linspace(1, rows, newRows));
scaled = zeros(newRows, newColumns, channels);
for channel = 1:channels
    smoothed = conv2(kernel, kernel, source(:, :, channel), 'same');
    scaled(:, :, channel) = interp2(smoothed, queryX, queryY, 'linear');
end
scaled = uint8(min(max(round(scaled), 0), 255));
end

function writeDemoGif(frames, delays_s, outputFile)
for index = 1:numel(frames)
    [indexed, colorMap] = rgb2ind(frames{index}, 256, 'nodither');
    if index == 1
        imwrite(indexed, colorMap, outputFile, 'gif', 'LoopCount', Inf, ...
            'DelayTime', delays_s(index));
    else
        imwrite(indexed, colorMap, outputFile, 'gif', 'WriteMode', 'append', ...
            'DelayTime', delays_s(index));
    end
end
end
