`timescale 1ns / 1ps

module write_controller_tb();
    logic clk,rst,rx_data_ready,en,we;
    logic   [31:0] i;
    logic   [7:0] byte_received;
    logic   [9:0] addr;
    logic   [7:0] din;
    logic   [2:0] status;
    logic [2:0] status_next;
    logic [23:0] array;

    initial begin
        status[2:0] = 3'd0;
        status_next[2:0] = 3'd0;
        i[31:0] = 32'd0;
        clk = 1'b0;
        rst = 1'b0;
        rx_data_ready = 1'd0;
        byte_received[7:0] = 8'd0;
        addr[9:0] = 10'd0;
        din[7:0] = 8'd0;
        array[23:0] = 24'd0;
    end

    always 
        #1 clk = ~ clk;

    always begin
        #1
        #10     byte_received[7:0] = 8'h32;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #10     byte_received[7:0] = 8'h31;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #10     byte_received[7:0] = 8'h77;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #10     byte_received[7:0] = 8'h61;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #10     byte_received[7:0] = 8'h0A;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;

        for (i=0; i<1024; i=i+1) begin
            #10     byte_received[7:0] = i/4;
                    rx_data_ready = 1'd1;
            #2      rx_data_ready = 1'd0;
        end

        #20
        #10     byte_received[7:0] = 8'h32;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #10     byte_received[7:0] = 8'h31;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #10     byte_received[7:0] = 8'h77;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #10     byte_received[7:0] = 8'h32;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #10     byte_received[7:0] = 8'h31;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #201;
    end

    write_controller write_inst(
        .clk(clk),
        .rst(rst),
        .byte_received(byte_received[7:0]),
        .rx_data_ready(rx_data_ready),
        .en(en),
        .we(we),
        .addr(addr[9:0]),
        .din(din[7:0]),
        .status(status[2:0]),
        .status_next(status_next[2:0]),
        .array(array[23:0])
    );
endmodule