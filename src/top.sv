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

    // //BRAM
    // blk_mem_gen_0 bram_a (
    //     .clka(clka),    // input wire clka
    //     .ena(ena),      // input wire ena
    //     .wea(wea),      // input wire [0 : 0] wea
    //     .addra(addra),  // input wire [9 : 0] addra
    //     .dina(dina),    // input wire [7 : 0] dina
    //     .clkb(clkb),    // input wire clkb
    //     .enb(enb),      // input wire enb
    //     .addrb(addrb),  // input wire [9 : 0] addrb
    //     .doutb(doutb)  // output wire [7 : 0] doutb
    // );


    //UART
    logic rx_data_ready;
    logic tx_start;
    logic [7:0] byte_received;
    logic [7:0] byte_to_send;
    logic tx_ongoing;
    uart_basic #(.BAUD_RATE(9600)) uart_inst(
        .clk(CLK100MHZ),
        .reset(rst_press),
        .rx(UART_TXD_IN),
        .rx_data(byte_received[7:0]),
        .rx_ready(rx_data_ready),
        .tx(UART_RXD_OUT),
        .tx_start(tx_start),
        .tx_data(byte_to_send[7:0]),
        .tx_busy(tx_ongoing)
    );


    enum logic {IDLE, SENDING} state, state_next;

    always_comb begin
        
        tx_start = 1'b0;
        byte_to_send[7:0] = 8'h00;
        state_next = IDLE;
        case(state)
            IDLE:       begin
                            if (rx_data_ready) begin
                                state_next = SENDING;
                                byte_to_send[7:0] = byte_received[7:0];
                                tx_start = 1'b1;
                            end
                        end
            SENDING:    begin
                            byte_to_send[7:0] = byte_received[7:0];
                            state_next = SENDING;
                            if (!tx_ongoing)
                                state_next = IDLE;
                        end
                    
        endcase
    end

    always_ff @(posedge CLK100MHZ) begin
        if (rst_press)
            state <= IDLE;
        else
            state <= state_next;
    end

endmodule
