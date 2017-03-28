function [ratio,waste]= candy(bag,kids)
ratio=floor(bag./kids);
waste= mod(bag,kids);%use comma instead of divisionsymbol for mod
end