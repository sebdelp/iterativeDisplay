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
    
    id.subplot(2,1,1);
    id.plot(x,y);
    id.grid('on');

    id.subplot(2,1,2);
    id.plot(x,y);
    id.grid('on');

    id.sgtitle(['iter' num2str(i)]);
    drawnow;
    pause(0.1);
end
    
   