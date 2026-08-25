function system=plotLevitador(h,fig)
l=40;
clf(fig)
h=3.1111e+03*h;
system.floor=rectangle('Position',[-100 -5 +200 5],'FaceColor',[0 0 0]); %floor
system.rect1=rectangle('Position',[-20 0 5 50],'FaceColor',[151 56 0]/255); %haste
system.rect2=rectangle('Position',[-20 50 45 5],'FaceColor',[151 56 0]/255); %haste
system.rect3=rectangle('Position',[20 0 5 50],'FaceColor',[151 56 0]/255); %haste
system.rect4=rectangle('Position',[-2.5 30 10 20],'FaceColor',[255 128 0]/255); %bobina
system.l1=line([-100 100],[30-9 30-9],'LineWidth',1,'Color',[0 0 0],'linestyle','--'); %ref
system.ball=rectangle('Position',[-2.5 30-h 10 10],'Curvature',[1,1],'FaceColor',[192 192 192]/255); 
% r=1;
% xc=x+l*sin(theta);
% yc=7+l*cos(theta);
% d = r*2;
% px = xc-r;
% py = yc-r;

axis equal
axis off
%axis([-100 100 -35 70])
xlabel('x (cm)')
drawnow
end
