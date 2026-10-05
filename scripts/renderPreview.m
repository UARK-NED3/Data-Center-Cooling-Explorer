%RENDERPREVIEW Regenerate the README preview from the interactive MATLAB app.
% This script writes an image derived only from synthetic model inputs.

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot);
app = DataCenterCoolingExplorer('Visible', 'off');
cleanup = onCleanup(@() deleteIfValid(app.Figure)); %#ok<NASGU>
exportapp(app.Figure, fullfile(projectRoot, 'docs', 'explorer-preview.png'));

function deleteIfValid(graphicObject)
if isvalid(graphicObject)
    delete(graphicObject);
end
end
