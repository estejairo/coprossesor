function write2dev(vectors,BRAM,com_port)
h = fopen(vectors, 'r');
% Arreglo de 1024x1 con los numeros.
s = serialport(com_port,115200);

if BRAM == "BRAMA"
    write(s, 'a', 'char');
elseif BRAM == "BRAMB"
    write(s, 'b', 'char');

end 
c = fscanf(h, "%i\n", [1 1024]); 
write(s, c,'uint8')

end
