function openIDexample(no)
exampleList={"simple_example","imshow_demo","non_available_data","optimization_desactivation",...
    "setting_properties","skipping_function_call"};
if no>length(exampleList)
    error('Invalid example number. Valid numbers are 1..%i',length(exampleList));
end
file=exampleList{no};
if ~isstring(file)
    file=string(file);
end
inFile=which("user_"+ file +".mlx");
outFile=fullfile(pwd,file +".mlx");
copyfile(inFile,outFile);
open(outFile);
end