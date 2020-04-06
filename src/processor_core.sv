module processor_core(
    input   logic clk,
    input   logic rst,

    input   logic [1:0] command,

    input   logic [7:0] doutb_A,
    output  logic enb_A,
    output  logic [9:0] addrb_A,

    input   logic tx_ongoing,
    output  logic tx_start,
    output  logic [7:0] byte_to_send,

    output  logic coprocessor_busy
);

    //FSM
    enum logic [1:0]{IDLE, READ_A} master_state, master_state_next;
    logic   busy;
    assign  coprocessor_busy = busy;

    always_comb begin
        master_state_next[1:0] = IDLE;
        busy = 1'b0;
        case(state)
            IDLE:   begin
                        if (command[1:0]==READ_A)
                            master_state_next[1:0] = READ_A;
                    end
            READ_A: begin
                        master_state_next = READ_A;
                        busy = 1'b1;
                        if (read_done)
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


    //Read Controller
    logic read_done;
    read_controller read_bramA_inst(
        .clk(clk),
        .rst(rst),

        .doutb(doutb_A[7:0]),
        .enb(enb_A),
        .addrb(addrb_A[9:0]),

        .tx_ongoing(tx_ongoing),
        .tx_start(tx_start),
        .byte_to_send(byte_to_send[7:0]),

        .read_done(read_done)
    );
endmodule