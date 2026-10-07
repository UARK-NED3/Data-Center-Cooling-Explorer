%RENDERPREVIEW Regenerate the README and listing previews from the interactive MATLAB app.
% This script writes the four still images and the animated demo in docs/,
% all derived only from synthetic model inputs.

scriptFolder = fileparts(mfilename('fullpath'));
run(fullfile(scriptFolder, 'renderContestPreviews.m'));
run(fullfile(scriptFolder, 'renderDemoAnimation.m'));
