function[candyk, candyw] = candy( pieces, kids)

candy1 = pieces ./kids;
candyk = floor(candy1);
candy2 = candyk .*kids;
candyw = pieces - candy2;

end
