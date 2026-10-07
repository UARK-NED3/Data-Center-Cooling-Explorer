%RENDERCONTESTPREVIEWS Generate named-scenario images for a public listing.
% All images are generated from synthetic teaching scenarios. The
% flow-limited and lower-resistance images show the Explorer after a learner
% has committed to a prediction, so the feedback text is visible.

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot);
docsFolder = fullfile(projectRoot, 'docs');
app = DataCenterCoolingExplorer('Visible', 'off', 'Position', [40 40 1440 880]);

app.SelectPreset('Moderate liquid cooling');
exportapp(app.Figure, fullfile(docsFolder, 'explorer-preview.png'));

app.ChoosePreset('Flow-limited loop');
app.SubmitPrediction('rise');
exportapp(app.Figure, fullfile(docsFolder, 'flow-limited-loop-preview.png'));

app.ChoosePreset('Lower thermal resistance');
app.SubmitPrediction('fall');
exportapp(app.Figure, fullfile(docsFolder, 'lower-resistance-preview.png'));

app.SelectPreset('High-density stress test');
exportapp(app.Figure, fullfile(docsFolder, 'high-density-stress-preview.png'));

delete(app.Figure);
clear app
