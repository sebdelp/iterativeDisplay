function i=findFirstData(data)
% This function inspect the data (typically a plot, surf, etc function
% varargin) in order to get the first double data to plot
i=1;
while i<length(data) && ~isnumeric(data{i})
    i=i+1;
end
end
   