function addHtml(htmlsource,code)
% This function add some custom html code to a file produced from an mlx

if ~isfile(htmlsource)
    error('File not found : %s',htmlsource);
end
% read file
lines={};
file=fopen(htmlsource,'r');
while ~feof(file)
lines{end+1}=fgetl(file);
end
fclose(file);

% Write modified file
file=fopen(htmlsource,'w');

% Search for the tite (line that starts with %%)
ended=false;i=1;
while ~ended && not(feof(file))
    fprintf(file,'%s\n',lines{i});
    ended=length(lines{i})>=4 && all(lines{i}(1:4)=='<!--');
    i=i+1;
end
if feof(file)
    fclose(file);
    error('Title not found in %s',htmlsource);
end

% Else add provided code
if ~iscell(code)
    code={code};
end
for j=1:length(code)
    fprintf(file,'%s\n',code{j});
end

% Write remaining lines
for j=i:length(lines)
    fprintf(file,'%s\n',lines{j});
end
fclose(file);
end