`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFSM
// Engineer: Jairo Gonzalez
// 
// Create Date: 04.04.2020 10:17:43
// Design Name: coprocessor
// Module Name: top
// Project Name: coprocessor
// Target Devices: Nexys4 DDR
// Description: coprocesssor
// 
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
        input 	logic CLK100MHZ,
        input   logic CPU_RESETN,
        input   logic UART_TXD_IN,
        output  logic UART_RXD_OUT
    );

    //Reset
    logic rst_status;
    logic rst_press;
    logic rst_release;
    PB_Debouncer #(.DELAY(60)) cpu_reset_debouncer(
        .clk(CLK100MHZ),
        .rst(1'b0),
        .PB(~CPU_RESETN),
        .PB_pressed_status(rst_status),
        .PB_pressed_pulse(rst_press),
        .PB_released_pulse(rst_release)
    );

    //UART
    //RX
    logic [7:0] byte_received;
    logic rx_data_ready;
    rx_uart #(.BAUD_RATE(9600)) uart_rx_inst(
        .clk(CLK100MHZ),
        .reset(rst_press),
        .rx(UART_TXD_IN),
        .rx_data(byte_received[7:0]),
        .rx_ready(rx_data_ready)
    );
    //TX
    logic tx_start;
    logic [7:0] byte_to_send;
    logic tx_ongoing;
    tx_uart #(.BAUD_RATE(9600)) uart_tx_inst(
        .clk(CLK100MHZ),
        .reset(rst_press),
        .tx(UART_RXD_OUT),
        .tx_start(tx_start),
        .tx_data(byte_to_send[7:0]),
        .tx_busy(tx_ongoing)
    );

    //BRAM A
    logic ena;
    logic wea;
    logic [9:0] addra;
    logic [7:0] dina;
    logic enb;
    logic [9:0] addrb;
    logic [7:0] doutb;
    blk_mem_gen_0 bram_a (
        .clka(CLK100MHZ),    // input wire clka
        .ena(ena),      // input wire ena
        .wea(wea),      // input wire [0 : 0] wea
        .addra(addra[9:0]),  // input wire [9 : 0] addra
        .dina(dina[7:0]),    // input wire [7 : 0] dina
        .clkb(CLK100MHZ),    // input wire clkb
        .enb(enb),      // input wire enb
        .addrb(addrb[9:0]),  // input wire [9 : 0] addrb
        .doutb(doutb[7:0])  // output wire [7 : 0] doutb
    );

    //Write Controller A
    write_controller write_A_inst(
        .clk(CLK100MHZ),
        .rst(rst_press),
        .byte_received(byte_received[7:0]),
        .rx_data_ready(rx_data_ready),
        .en(ena),
        .we(wea),
        .addr(addra[9:0]),
        .din(dina[7:0]),
        .status(),
        .status_next(),
        .array()
    );

    //BRAM B
    logic ena_B;
    logic wea_B;
    logic [9:0] addra_B;
    logic [7:0] dina_B;
    logic enb_B;
    logic [9:0] addrb_B;
    logic [7:0] doutb_B;
    blk_mem_gen_0 bram_B (
        .clka(CLK100MHZ),    // input wire clka
        .ena(ena_B),      // input wire ena
        .wea(wea_B),      // input wire [0 : 0] wea
        .addra(addra_B[9:0]),  // input wire [9 : 0] addra
        .dina(dina_B[7:0]),    // input wire [7 : 0] dina
        .clkb(CLK100MHZ),    // input wire clkb
        .enb(enb_B),      // input wire enb
        .addrb(addrb_B[9:0]),  // input wire [9 : 0] addrb
        .doutb(doutb_B[7:0])  // output wire [7 : 0] doutb
    );
    
    //Write Controller AB
    write_controller #(.MEM("b")) write_B_inst(
        .clk(CLK100MHZ),
        .rst(rst_press),
        .byte_received(byte_received[7:0]),
        .rx_data_ready(rx_data_ready),
        .en(ena_B),
        .we(wea_B),
        .addr(addra_B[9:0]),
        .din(dina_B[7:0]),
        .status(),
        .status_next(),
        .array()
    );


    //Command Decoder
    logic [2:0] command;
    logic coprocessor_busy;
    command_decoder cmd_decoder_inst(
        .clk(CLK100MHZ),
        .rst(rst_press),
        .byte_received(byte_received[7:0]),
        .rx_data_ready(rx_data_ready),
        .coprocessor_busy(coprocessor_busy),
        .command(command[2:0]),
        .command_next(),
        .array()
    );


    //Processor core
    processor_core pro_core_inst(
        .clk(CLK100MHZ),
        .rst(rst_press),

        .command(command[2:0]),

        .doutb_A(doutb[7:0]),
        .enb_A(enb),
        .addrb_A(addrb[9:0]),

        .doutb_B(doutb_B[7:0]),
        .enb_B(enb_B),
        .addrb_B(addrb_B[9:0]),

        .tx_ongoing(tx_ongoing),
        .tx_start(tx_start),
        .byte_to_send(byte_to_send[7:0]),

        .coprocessor_busy(coprocessor_busy)
    );

endmodule
 