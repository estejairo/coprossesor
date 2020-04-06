`timescale 1ns / 1ps

module command_decoder_tb();
    logic clk,rst,rx_data_ready,coprocessor_busy;

    logic [7:0] byte_received;
    logic [1:0] command;

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        rx_data_ready = 1'd0;
        coprocessor_busy = 1'd0;
        byte_received[7:0] = 8'd0;
        command[1:0] = 2'b0;
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
        #10     byte_received[7:0] = 8'h72;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #10     byte_received[7:0] = 8'h61;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #2      coprocessor_busy = 1'd1;
        #10     byte_received[7:0] = 8'h0A;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #20     byte_received[7:0] = 8'h35;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #50     coprocessor_busy = 1'd0;
        #10     byte_received[7:0] = 8'h32;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #10     byte_received[7:0] = 8'h31;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #10     byte_received[7:0] = 8'h72;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #10     byte_received[7:0] = 8'h61;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #10     byte_received[7:0] = 8'h32;
                rx_data_ready = 1'd1;
        #2      rx_data_ready = 1'd0;
        #100;
    end

    command_decoder decoder_inst(
        .clk(clk),
        .rst(rst),
        .byte_received(byte_received[7:0]),
        .rx_data_ready(rx_data_ready),
        .coprocessor_busy(coprocessor_busy),
        .command(command[1:0])
    );

endmodule