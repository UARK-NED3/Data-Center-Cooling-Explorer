%RENDERCONTESTPREVIEWS Generate named-scenario images for a public listing.
% All images are generated from synthetic teaching scenarios.

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot);
app = DataCenterCoolingExplorer('Visible', 'off');
cleanup = onCleanup(@() deleteIfValid(app.Figure)); %#ok<NASGU>

cases = { ...
    'Moderate liquid cooling', 'explorer-preview.png'; ...
    'Flow-limited loop', 'flow-limited-loop-preview.png'; ...
    'High-density stress test', 'high-density-stress-preview.png'};

for caseIndex = 1:size(cases, 1)
    app.SelectPreset(cases{caseIndex, 1});
    exportapp(app.Figure, fullfile(projectRoot, 'docs', cases{caseIndex, 2}));
end

function deleteIfValid(graphicObject)
if isvalid(graphicObject)
    delete(graphicObject);
end
end
