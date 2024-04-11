clearvars
close all
clc

id=iterativeDisplay;

hFig=id.figure;
set(hFig,'visible','on'); % Undock the figure from the live editor

x=linspace(-10,10,20);
y=linspace(-10,10,21);
z=x.*y';


for i=1:100
    if i<100
        id.newIteration;
    else
        id.finalIteration;
    end
   
    id.surf(x,y,z);
    id.xlim([0 i]);
    id.ylim([0 i]);
    id.zlim([0 i]);
    
    xx=id.xlim;
    yy=id.ylim;
    zz=id.zlim;
    drawnow;
    pause(0.01)
end