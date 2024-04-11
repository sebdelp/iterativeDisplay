clearvars
close all
clc

% To do in order to publish toolbox
% Copy the examples without the blue button in the "userExamples" folder

% Structure of the toolbox (installation folder)
%\examples
%     + mlx files
%     \html 
%        + html files
%\doc
%      \GettingStarted.mlx
%      \html
%        + html files

% Generate a copy of the toolbox that only use p-coded file
CurrentDirectory=pwd;



% Uninstall current toolbox
list=matlab.addons.toolbox.installedToolboxes;
j=-1;
for i=1:length(list)
    if contains(list(i).Name,'Iterative')
        j=i;
    end
end
if j>0
    % Uninstall toolbox
    fprintf('Uninstalling : %s\n',list(j).Name)
    matlab.addons.toolbox.uninstallToolbox(list(j));
else
    warning('Toolbox not installed : nothing to uninstall')
end


% Source Folders
codeSrcFolder=fullfile(CurrentDirectory,'code');
DocSrcFolder=fullfile(CurrentDirectory,'docSources');
ExpleSrcFolder=fullfile(DocSrcFolder,'examplesSources');
UserExpleSrcFolder=fullfile(DocSrcFolder,'userExamples');

% Dst Folder
toolboxDstFolder=fullfile(CurrentDirectory,'sources');
DocDstFolder=fullfile(toolboxDstFolder,'doc');
ExpleDstFolder=fullfile(DocDstFolder,'example');
HtmlExpleDstFolder=fullfile(ExpleDstFolder,'html');

toolboxPath={toolboxDstFolder,DocDstFolder,ExpleDstFolder};
for i=1:length(toolboxPath),rmpath(toolboxPath{i});end


% Remove current doc
if isfolder(toolboxDstFolder)
    rmdir(toolboxDstFolder,'s');
end
% Rebuild folder structure
mkdir(toolboxDstFolder);
if ~isfolder(DocDstFolder)
mkdir(DocDstFolder);
end
if ~isfolder(ExpleDstFolder)
mkdir(ExpleDstFolder);
end
if ~isfolder(HtmlExpleDstFolder)
    mkdir(HtmlExpleDstFolder);
end

for i=1:length(toolboxPath)
    fprintf('Adding path %s\n',toolboxPath{i})
    addpath(toolboxPath{i});
end



%======================================================
% Sources
%======================================================
copyfile(codeSrcFolder,toolboxDstFolder);

%======================================================
% doc 
%======================================================

fprintf('Building doc html\n')
fileList=dir(fullfile(DocSrcFolder, '*.mlx'));
for noFile=1:length(fileList)
    fullInFilename=fullfile(fileList(noFile).folder,fileList(noFile).name);
    [filepath,name,ext] = fileparts(fileList(noFile).name);
    fileOutFilename=fullfile(DocDstFolder,[name '.html']);
    fprintf('  Exporting to html : %s\n',[name ext]);
    export(fullInFilename,fileOutFilename,'Run',false);
end
copyfile(fullfile(DocSrcFolder,'info.xml'),fullfile(toolboxDstFolder,'info.xml'));
copyfile(fullfile(DocSrcFolder,'helptoc.xml'),fullfile(DocDstFolder,'helptoc.xml'));


%======================================================
% Examples
%======================================================
fprintf('Building examples html\n');

List=AddAllDemos({},ExpleSrcFolder);
for i=1:length(List)
    fullInFilename=List{i};
    [filepath,name,ext] = fileparts(fullInFilename);
    fileOutFilename=fullfile(HtmlExpleDstFolder,[name '.html']);
    fprintf('   Exporting : %s\n',[name ext]);
   export(fullInFilename,fileOutFilename,'Run',false);

    % Copy example file
    copyfile(fullInFilename,ExpleDstFolder)
end

%======================================================
% User_examples
%======================================================
List=AddAllDemos({},UserExpleSrcFolder);
for i=1:length(List)
    fullInFilename=List{i};
    [filepath,name,ext] = fileparts(fullInFilename);
    fileOutFilename=fullfile(ExpleDstFolder,[name '.html']);
    fprintf('   Exporting : %s\n',[name ext]);

    % Copy example file
    copyfile(fullInFilename,toolboxDstFolder)
end


copyfile(fullfile(DocSrcFolder,'demos.xml'),fullfile(DocDstFolder,'demos.xml'));


% ==================================================
% Getting started
% ==================================================
% Was copied 
copyfile(fullfile(DocSrcFolder,'GettingStarted.mlx'),...
         DocDstFolder);


% ==================================================
% Database
% ==================================================
cd(DocDstFolder)
builddocsearchdb('.');
cd(CurrentDirectory)
    

% ==================================================
% Package toolbox
% ==================================================
toolboxVersion='0.1.0';
toolboxName='Iterative Display';
toolboxDescription='This toolbox allows accelerating the graphic plotting within loops';
toolboxSummary='This toolbox allows accelerating the graphic plotting within loops. The basic principle is that the object store handles to graphic object and then update their properties instead of recreating them. This is done with a minor modification of the code.';
toolboxAuthor='S. Delprat';
toolboxEmail='sebastien.delprat@uphf.fr';
toolboxCompany='LAMIH UMR CNRS 8201';
toolboxImageFile='logo.png';
toolboxGettingStarted=fullfile(DocDstFolder,'GettingStarted.mlx');
toolboxPlatforms.Glnxa64=true;
toolboxPlatforms.Maci64=true;
toolboxPlatforms.MatlabOnline=true;
toolboxPlatforms.Win64=true;
toolboxOutputFile='Iterative Display.mltbx';

toolboxUID='iterativeDisplayToolbox-123456-123456';
opts = matlab.addons.toolbox.ToolboxOptions(toolboxDstFolder,toolboxUID,...
    'ToolboxName',toolboxName,...
    'ToolboxVersion',toolboxVersion,...
    'Description',toolboxDescription,...
    'Summary',toolboxSummary,...
    'AuthorName',toolboxAuthor,...
    'AuthorEmail',toolboxEmail,...
    'AuthorCompany',toolboxCompany,...
    'ToolboxImageFile',toolboxImageFile,...
    'ToolboxMatlabPath',toolboxPath,...
    'ToolboxGettingStartedGuide',toolboxGettingStarted, ...
    'OutputFile',toolboxOutputFile,...
    'SupportedPlatforms',toolboxPlatforms);

% ==================================================
% Package toolbox
% ==================================================
matlab.addons.toolbox.packageToolbox(opts);

% ==================================================
% Install toolbox
% ==================================================
installedToolbox = matlab.addons.toolbox.installToolbox(toolboxOutputFile);

% Clean path
cleanPath

% Open doc
doc


function List=AddAllDemos(List,Folder)
% Add all the mlx file from the top folder to the list
C=dir([Folder filesep '*.mlx']);
for i=1:length(C)
    List{end+1}=fullfile(Folder, C(i).name);
end
% Find list of subfolder
C=dir([Folder filesep '*']);
for i=1:length(C)
    fullFolderName=fullfile(Folder,C(i).name);
    if all(~strcmp(C(i).name,{'.','..'})) && isfolder(fullFolderName)
        List=AddAllDemos(List,fullFolderName);
    end
end
end