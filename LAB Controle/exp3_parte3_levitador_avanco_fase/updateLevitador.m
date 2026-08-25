function system=updateLevitador(h,system)
l=40;
h=3.1111e+03*h;
%pendulo.rect1.Position=[-6+x 0 2 2];
system.ball.Position=[-2.5 30-h 10 10];
% r=1;
% xc=x+l*sin(theta);
% yc=7+l*cos(theta);
% d = r*2;
% px = xc-r;
% py = yc-r;
drawnow
end