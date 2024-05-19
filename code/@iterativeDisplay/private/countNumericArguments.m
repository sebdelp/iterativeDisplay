function res=countNumericArguments(args)
% Count numeric arguments
res=0;
i=1;
% Skip non numeric arguments such as axes
while i<length(args)  && ~isnumeric(args{i})
    i=i+1;
end

while i<=length(args) && isnumeric(args{i})
    i=i+1;
    res=res+1;
end
end
