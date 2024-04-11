clc
clearvars
% =================================================================== 
% uninstall the toolbox
% togle path toward the "working" folder (code)
% =================================================================== 
uninstallToolbox('Iterative')
toggleFolderInPath(fullfile(pwd,'code'));



function toggleFolderInPath(folder)
    % Check if the folder is already in the MATLAB path
    inPath = any(strcmpi(folder, strsplit(path, pathsep)));

    if inPath
        % Remove the folder from the MATLAB path
        rmpath(folder);
        disp(['Removed "', folder, '" from MATLAB path.']);
    else
        % Add the folder to the MATLAB path
        addpath(folder);
        disp(['Added "', folder, '" to MATLAB path.']);
    end
end

function uninstallToolbox(partialName)
list=matlab.addons.toolbox.installedToolboxes;
j=-1;
for i=1:length(list)
    if contains(list(i).Name,partialName)
        j=i;
    end
end
if j>0
    % Uninstall toolbox
    fprintf('Uninstalling : %s\n',list(j).Name)
    matlab.addons.toolbox.uninstallToolbox(list(j));
else
    fprintf('Toolbox not installed : nothing to uninstall\n')
end
end