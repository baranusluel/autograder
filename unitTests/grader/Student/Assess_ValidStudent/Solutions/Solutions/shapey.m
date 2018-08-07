function shapey(leng, angle) 
prevAngle = 0; 
x1 = 0; % starts at (0,0)
y1 = 0; 
for i = 1:length(leng)
    th = prevAngle + angle(i); %the new angle is the sum of all the previous angles
    vec = [leng(i); 0]; % create a vertical vector the length of the current segment
    rotatedVec = [cosd(th), -sind(th); sind(th) cosd(th)] * vec; %rotates vector 
    x2 = x1 + rotatedVec(1); % gets the second point
    y2 = y1 + rotatedVec(2);
    plot([x1, x2], [y1, y2], 'k');
    hold on
    prevAngle = th; % stores previous variable
    x1 = x2; % sets new starting point
    y1 = y2;
end 
axis equal 
axis off
hold off
end