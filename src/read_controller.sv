module read_controller(
    input   logic clk,
    input   logic rst,
    input   logic [1:0] master_state,

    input   logic [7:0] doutb,
    output  logic enb,
    output  logic [9:0] addrb,

    input   logic tx_ongoing,
    output  logic tx_start,
    output  logic [7:0] byte_to_send,

    output  logic [2:0] status,
    output  logic read_done
);

    //FSM
    enum logic [2:0] {IDLE, WAIT, READ} state, state_next;
    logic   addrb_reset;
    logic   [9:0] addrb_next = 10'd0;

    assign  status[2:0] = state;

    always_comb begin
        state_next[2:0] = IDLE;
        enb = 1'b0;
        addrb_reset = 1'd1;
        read_done = 1'b0;
        tx_start = 1'd0;
        case(state)
            IDLE:    begin
                                if (master_state==2'd2) begin
                                    state_next[2:0] = WAIT;
                                    addrb_reset = 1'd0;
                                end
                            end
            WAIT:    begin
                                state_next = WAIT;
                                addrb_reset = 1'd0;
                                if (!tx_ongoing) begin
                                    state_next[2:0] = READ;
                                    addrb_reset = 1'd0;
                                end

                            end
            READ:    begin
                                enb = 1'b1;
                                addrb_reset = 1'd0;
                                addrb_next[9:0] = addrb[9:0] + 1'd1;
                                tx_start = 1'b1;
                                byte_to_send[7:0]=doutb[7:0];
                                state_next[2:0] = WAIT;
                                if (addrb[9:0]==10'd1023) begin
                                    state_next = IDLE;
                                    addrb_next[9:0] = 10'd0;
                                    read_done = 1'b1;
                                end
                            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst||addrb_reset) 
            addrb[9:0] <= 10'd0;
        else
            addrb[9:0] <= addrb_next[9:0];
    end
    
    always_ff @(posedge clk) begin
        if (rst) begin
            state[2:0] <= IDLE;
        end
        else begin
            state[2:0] <= state_next[2:0];
        end
    end
endmodule