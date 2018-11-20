server = tcpip('127.0.0.1', 60003, 'NetworkRole', 'server');
while true
    fopen(server);
    while server.BytesAvailable > 0
        fread(server, server.BytesAvailable);
    end
    fwrite(server, 'HTTP/1.1 200 OK');
    fwrite(server, newline);
    fwrite(server, 'Content-Type: text/plain');
    fwrite(server, newline);
    fwrite(server, 'Connection: close');
    fwrite(server, newline);
    fwrite(server, newline);
    fclose(server);
end