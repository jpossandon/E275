%%
im = 85;
image = imread(sprintf('image_%d.jpg',im));
%%
figure,imshow(image)
hold on
indxfix = find(eyedata.events.type==1 &eyedata.events.image==im & eyedata.events.origstart>0);
plot(eyedata.events.posx(indxfix),eyedata.events.posy(indxfix),'.r','Markersize',16)
plot(eyedata.events.posx(indxfix),eyedata.events.posy(indxfix))
indxsac = find(eyedata.events.type==2 &eyedata.events.image==im & eyedata.events.origstart>0);

plot([eyedata.events.posinix(indxsac);eyedata.events.posendx(indxsac)],[eyedata.events.posiniy(indxsac);eyedata.events.posendy(indxsac)],'y')
for t = 1:length(indxfix)
    text(double(20+eyedata.events.posx(indxfix(t))),double(20+eyedata.events.posy(indxfix(t))),num2str(t),'Color',[1 0 0])
end
