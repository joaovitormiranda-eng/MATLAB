function pendulo=plotPendulo(x_vet,fig)
l=40;
x=x_vet(1);
theta=-x_vet(3);
clf(fig)
pendulo.floor=rectangle('Position',[-100 -1 +200 1],'FaceColor',[0 0 0]); %floor
pendulo.floor=rectangle('Position',[-50-6 0 1 3],'FaceColor',[1 0 0]); %limit-switch 1
pendulo.floor=rectangle('Position',[+50+6 0 1 3],'FaceColor',[1 0 0]); %limit-switch 2
pendulo.rect1=rectangle('Position',[-6+x 0 2 2],'Curvature',[1 1],'FaceColor',[0 0 0]); %roda1
pendulo.rect2=rectangle('Position',[4+x 0 2 2],'Curvature',[1 1],'FaceColor',[0 0 0]); % roda2
pendulo.rect3=rectangle('Position',[-6+x 2 12 5],'FaceColor',[0.1 0.5 1]); %car
pendulo.l1=line([x x+l*sin(theta)],[7 7+l*cos(theta)],'LineWidth',5,'Color',[1 0 0]); %haste
r=1;
xc=x+l*sin(theta);
yc=7+l*cos(theta);
d = r*2;
px = xc-r;
py = yc-r;
pendulo.ball=rectangle('Position',[px py d d],'Curvature',[1,1],'FaceColor',[1 0 0]);
axis equal
axis([-100 100 -35 40])
xlabel('x (cm)')
drawnow
end
