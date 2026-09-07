function pendulo=updatePendulo(x_vet,pendulo)
l=40;
x=x_vet(1);
if x>50
    x=50;
end
if x<-50
    x=-50;
end
theta=-x_vet(3);
pendulo.rect1.Position=[-6+x 0 2 2];
pendulo.rect2.Position=[4+x 0 2 2];
pendulo.rect3.Position=[-6+x 2 12 5];
r=1;
xc=x+l*sin(theta);
yc=7+l*cos(theta);
d = r*2;
px = xc-r;
py = yc-r;
pendulo.l1.XData=[x xc];
pendulo.l1.YData=[7 yc];
pendulo.ball.Position=[px py d d];
drawnow
end