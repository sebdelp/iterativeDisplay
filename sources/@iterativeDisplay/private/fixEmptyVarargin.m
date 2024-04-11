function  varargin=fixEmptyVarargin(varargin)
% Replace empty argumuent to plot, semilogx, etc. and surf, mesh, etc
% by NaN
if nargin>1 && isempty(varargin{1})
    varargin{1}=NaN;
end
if nargin>2 && isempty(varargin{2})
    varargin{2}=NaN;
end
if nargin>3 && isempty(varargin{3})
    varargin{3}=NaN;
end
if nargin>4 && isempty(varargin{4}) 
    varargin{4}=NaN;
end
end