clearvars
close all
clc


x=linspace(0,10,100);
y=x.^2;

id=iterativeDisplay;

for i=1:10
    if i<10
        id.newIteration;
    else
        id.finalIteration;
    end

    id.figure;

    if i==1
        id.mesh([],[],[],[]);
    else
        id.mesh(x,y,x.*y',x.*y'*0);
    end
    id.grid('on');

    drawnow;
    pause(0.1);
end
