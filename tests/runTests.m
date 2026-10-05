function results = runTests
%RUNTESTS Execute all automated checks from a clean MATLAB session.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'src'));
results = runtests(fullfile(projectRoot, 'tests'));
assert(all([results.Passed]), 'DataCenterCooling:TestsFailed', ...
    'One or more automated tests failed.');
end
