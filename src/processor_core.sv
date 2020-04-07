`timescale 1ns / 1ps
module processor_core(
    input   logic clk,
    input   logic rst,

    input   logic [2:0] command,

    input   logic [7:0] doutb_A,
    output  logic enb_A,
    output  logic [9:0] addrb_A,

    input   logic [7:0] doutb_B,
    output  logic enb_B,
    output  logic [9:0] addrb_B,

    input   logic tx_ongoing,
    output  logic tx_start,
    output  logic [7:0] byte_to_send,

    output  logic coprocessor_busy
);
    //Not sure why, but registering those signals helps in FSM
    logic [2:0] command_r    = 2'd0;
    always_ff @(posedge clk) begin
        if (rst) begin
            command_r[2:0]  <= 3'd0;
        end
        else begin
            command_r[2:0]  <= command[2:0];
        end
    end

    //FSM
    enum logic [1:0]{IDLE, READ_A = 'd1, READ_B = 'd2} master_state, master_state_next;
    logic   busy;
    assign  coprocessor_busy = busy;

    logic read_done_A;
    logic read_done_B;
    logic [7:0] byte_to_send_next = 8'd0;
    logic tx_start_next = 1'b0;
    logic [7:0] byte_to_send_A;
    logic tx_start_A;
    logic [7:0] byte_to_send_B;
    logic tx_start_B;

    always_comb begin
        master_state_next[1:0] = IDLE;
        busy = 1'b0;
        tx_start_next = 1'd0;
        byte_to_send_next[7:0] = 8'd0;
        case(master_state)
            IDLE:   begin
                        if (command_r[2:0]==READ_A)
                            master_state_next[1:0] = READ_A;
                        else if (command_r[2:0]==READ_B)
                            master_state_next[1:0] = READ_B;
                    end
            READ_A: begin
                        master_state_next = READ_A;
                        byte_to_send_next[7:0] = byte_to_send_A[7:0];
                        tx_start_next = tx_start_A;
                        busy = 1'b1;
                        if (read_done_A)
                            master_state_next[1:0] = IDLE;
                    end
            READ_B: begin
                        master_state_next = READ_B;
                        byte_to_send_next[7:0] = byte_to_send_B[7:0];
                        tx_start_next = tx_start_B;
                        busy = 1'b1;
                        if (read_done_B)
                            master_state_next[1:0] = IDLE;
                    end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst)
            master_state[1:0] <= IDLE;
        else
            master_state[1:0] <= master_state_next[1:0];
    end


    //Read A Controller
    read_controller read_bramA_inst(
        .clk(clk),
        .rst(rst),
        .master_state(master_state[1:0]),
        .doutb(doutb_A[7:0]),
        .enb(enb_A),
        .addrb(addrb_A[9:0]),

        .tx_ongoing(tx_ongoing),
        .tx_start(tx_start_A),
        .byte_to_send(byte_to_send_A[7:0]),
        .status(),
        .status_next(),
        .read_done(read_done_A)
    );

    //Read B Controller
    read_controller #(.M_STATE(2)) read_bramB_inst(
        .clk(clk),
        .rst(rst),
        .master_state(master_state[1:0]),
        .doutb(doutb_B[7:0]),
        .enb(enb_B),
        .addrb(addrb_B[9:0]),

        .tx_ongoing(tx_ongoing),
        .tx_start(tx_start_B),
        .byte_to_send(byte_to_send_B[7:0]),
        .status(),
        .status_next(),
        .read_done(read_done_B)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            tx_start <= 1'd0;
            byte_to_send[7:0] <= 8'd0;
        end
        else begin
            tx_start <= tx_start_next;
            byte_to_send[7:0] <= byte_to_send_next[7:0];
        end
    end

endmodule