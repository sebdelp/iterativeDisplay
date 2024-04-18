function  varargin=fixEmptyVarargin3D(varargin)
% Replace emptyargument to 3D functions
% by NaN
if nargin>=1 && isempty(varargin{1})
    varargin{1}=[NaN NaN];
end
if nargin>=2 && isempty(varargin{2})
    varargin{2}=[NaN NaN];
end
if nargin>=3 && isempty(varargin{3})
    varargin{3}=[NaN NaN;NaN NaN];
end
if nargin>=4 && isempty(varargin{4}) 
    varargin{4}=[NaN NaN;NaN NaN];
end
end