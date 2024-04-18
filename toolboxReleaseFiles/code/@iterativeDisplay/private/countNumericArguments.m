function res=countNumericArguments(args)
% Count numeric arguments
res=0;

while res<length(args) && isnumeric(args{res+1})
    res=res+1;
end
end
