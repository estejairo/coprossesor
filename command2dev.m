function data = command2dev(command, com_port, BRAM)
s = serialport(com_port,115200);

if nargin>2
    b_ram = BRAM;
else
    b_ram = "#####";
end

switch command
    case "readVec"
        if b_ram == "BRAMA"
            write(s, 'c',"char");
            data = read(s,1024,"uint8");
        elseif b_ram == "BRAMB"
            write(s, 'd', "char");
            data = read(s,1024,"uint8");
        end
    case "sumVec"
        writeline(s, 'e');
        data = read(s,1024,"uint8");
        data = data*2;
    case "avgVec"
        writeline(s, 'f');
        data = read(s,1024,"uint8");
    case "manDist"
        writeline(s, 'g');
        aux = read(s,3,"uint8")';
        data = aux(1) + aux(2)*2^8 + aux(3)*2^16;
    case "eucDist"
        writeline(s, 'h');
        aux = read(s,2,"uint8");
        data = aux(1) + aux(2)*2^8;
end  
delete(s);
end

