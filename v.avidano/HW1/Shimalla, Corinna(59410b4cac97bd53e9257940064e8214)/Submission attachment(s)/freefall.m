function[pos, veloc] = freefall(time)
acc = 9.807; %value for acceloration
pos = (acc .* time.^2)./2;
veloc = acc .* time;
pos = round(pos, 3);
veloc = round(veloc, 3);
end