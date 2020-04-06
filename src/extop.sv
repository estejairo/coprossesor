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


module extop(
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

    //BRAM
    logic ena;
    logic wea;
    logic [9:0] addra;
    logic [9:0] addra_i;
    logic [7:0] dina;
    logic enb;
    logic [9:0] addrb;
    logic [9:0] addrb_i;
    logic [7:0] doutb;
    blk_mem_gen_0 bram_a (
        .clka(CLK100MHZ),    // input wire clka
        .ena(ena),      // input wire ena
        .wea(wea),      // input wire [0 : 0] wea
        .addra(addra_i[9:0]),  // input wire [9 : 0] addra
        .dina(dina[7:0]),    // input wire [7 : 0] dina
        .clkb(CLK100MHZ),    // input wire clkb
        .enb(enb),      // input wire enb
        .addrb(addrb_i[9:0]),  // input wire [9 : 0] addrb
        .doutb(doutb[7:0])  // output wire [7 : 0] doutb
    );
    assign addra_i[9:0] = addra[9:0];
    assign addrb_i[9:0] = addra[9:0];


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


    enum logic [7:0]{IDLE, COMMAND, WRITE, WA, READ,  RA, RESPONSE, END} state, state_next;
    logic [9:0] addra_next = 10'd0;
    logic [9:0] addrb_next = 10'd0;
    logic [7:0] number = 8'd0;
    logic [7:0] number_next = 8'd0;
    always_comb begin
        
        tx_start = 1'b0;
        byte_to_send[7:0] = 8'h00;
        state_next = IDLE;

        addra_next[9:0] = addra[9:0];
        ena=1'b0;
        wea=1'b0;
        dina[7:0]=8'd0;

        enb=1'b0;
        addrb_next[9:0]=addrb[9:0];
        doutb[7:0]=8'd0;
        number_next[7:0] = number[7:0];

        case(state)
            IDLE:       begin
                            if (rx_data_ready&&(byte_received[7:0]=="@")) begin
                                state_next = COMMAND;
                            end
                        end
            COMMAND:    begin
                            state_next = COMMAND;
                            if (rx_data_ready&&(byte_received[7:0]=="w")) begin
                                state_next = WRITE;
                            end
                            else if (rx_data_ready&&(byte_received[7:0]=="r")) begin
                                state_next = READ;
                            end
                            else if (rx_data_ready) begin
                                state_next = RESPONSE;
                                byte_to_send[7:0] = "E";
                                tx_start = 1'b1;
                            end
                        end
            WRITE:      begin
                            state_next = WRITE;
                            if (rx_data_ready&&(byte_received[7:0]==8'hA)) begin
                                state_next = WA;
                            end
                            else if (rx_data_ready&&(byte_received[7:0]!="a")) begin
                                state_next = RESPONSE;
                                byte_to_send[7:0] = "E";
                                tx_start = 1'b1;
                            end
                        end
            WA:         begin
                            state_next = WA;
                            if (rx_data_ready&&("0"<=byte_received[7:0])&&(byte_received[7:0]<="9")) begin
                                number_next[7:0] = number[7:0]*'d10+(byte_received[7:0]-'d48);
                            end
                            else if (rx_data_ready&&(byte_received[7:0]==8'hA)) begin
                                ena=1'b1;
                                wea=1'b1;
                                addra_next[9:0]=addra[9:0]+'d1;
                                dina[7:0]=number[7:0];
                                number_next[7:0]=8'd0;
                            end
                            else if (rx_data_ready&&(byte_received[7:0]=="$")) begin
                                state_next = RESPONSE;
                                byte_to_send[7:0] = "D";
                                tx_start = 1'b1;
                            end
                            else if (rx_data_ready) begin
                                state_next = RESPONSE;
                                byte_to_send[7:0] = "E";
                                tx_start = 1'b1;
                            end
                        end
            READ:      begin
                            state_next = READ;
                            if (rx_data_ready&&(byte_received[7:0]==8'hA)) begin
                                state_next = RA;
                                enb=1'b1;
                                addrb_next[9:0]=addrb[9:0]+'d1;
                                byte_to_send[7:0] = doutb[7:0];
                                tx_start = 1'b1;
                            end
                            else if (rx_data_ready&&(byte_received[7:0]!="a")) begin
                                state_next = RESPONSE;
                                byte_to_send[7:0] = "E";
                                tx_start = 1'b1;
                            end
                        end
            RA:         begin
                            state_next = RA;
                            if (!tx_ongoing && (addrb[9:0]<='d1023)) begin
                                enb=1'b1;
                                addrb_next[9:0]=addrb[9:0]+'d1;
                                byte_to_send[7:0] = doutb[7:0];
                                tx_start = 1'b1;
                            end
                            else if (!tx_ongoing && (addrb[9:0]='d1024) )begin
                                state_next=RESPONSE;
                                addrb_next[9:0]=10'd0;
                                byte_to_send[7:0] = "D";
                                tx_start = 1'b1;
                            end
                        end
            RESPONSE:   begin
                            state_next = RESPONSE;
                            if (!tx_ongoing) begin
                                byte_to_send[7:0] = 8'hA;
                                tx_start = 1'b1;
                                state_next = END;
                            end
                        end
            END:        begin
                            state_next = END;
                            if (!tx_ongoing)
                                state_next = IDLE;
                        end
                    
        endcase
    end

    always_ff @(posedge CLK100MHZ) begin
        if (rst_press) begin
            state <= IDLE;
            addra[9:0] <= 10'd0;
            addrb[9:0] <= 10'd0;
        end
        else begin
            state <= state_next;
            addra[9:0] <= addra_next[9:0];
            addrb[9:0] <= addrb_next[9:0];
        end
    end

endmodule
