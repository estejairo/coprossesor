`timescale 1ns / 1ps

module read_controller_tb();
    logic clk,rst;
    logic [31:0] i;

    logic [1:0] master_state;
    logic [7:0] doutb;
    logic enb;
    logic [9:0] addrb;
    logic tx_ongoing;
    logic tx_start;
    logic [7:0] byte_to_send;

    logic [2:0] status;

    logic read_done;

    initial begin
        i[31:0] = 32'd0;
        clk = 1'b0;
        rst = 1'b0;
        master_state[1:0] = 2'd0;
        doutb[7:0] = 8'd0;
        //enb = 1'd0;
        //addrb[9:0] = 10'd0;
        tx_ongoing = 1'd0;
        //tx_start = 1'd0;
        byte_to_send[7:0] = 8'd0;
        //read_done = 1'b0;
        status[2:0] = 3'd0;
    end

    always 
        #1 clk = ~ clk;

    always begin
        #1
        #10     master_state[1:0] = 2'd2;
        #2;
        for (i = 0;i<1023 ;i=i+1 ) begin
                  doutb[7:0] = 'd1023-i;
            #2      tx_ongoing = 1'd1;
                    doutb[7:0] = 'd1023-i;
            #14     tx_ongoing = 1'd0;
        end
              doutb[7:0] = 'd1023-i;
        #2      tx_ongoing = 1'd1;
                doutb[7:0] = 'd1023-i;
        #2      master_state[1:0] = 2'd0;
        #12     tx_ongoing = 1'd0;
        #100;
    end

    
    read_controller read_inst(
        .clk(clk),
        .rst(rst),
        .master_state(master_state[1:0]),

        .doutb(doutb[7:0]),
        .enb(enb),
        .addrb(addrb[9:0]),

        .tx_ongoing(tx_ongoing),
        .tx_start(tx_start),
        .byte_to_send(byte_to_send[7:0]),

        .status(status[2:0]),

        .read_done(read_done)
    );
endmodule