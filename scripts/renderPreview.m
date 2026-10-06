%RENDERPREVIEW Regenerate the README preview from the interactive MATLAB app.
% This script writes an image derived only from synthetic model inputs.

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot);
run(fullfile(projectRoot, 'scripts', 'renderContestPreviews.m'));

function deleteIfValid(graphicObject)
if isvalid(graphicObject)
    delete(graphicObject);
end
end
