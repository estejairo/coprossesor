`timescale 1ns / 1ps
module command_decoder(
    input   logic clk,
    input   logic rst,
    input   logic [7:0] byte_received,
    input   logic rx_data_ready,
    input   logic coprocessor_busy,
    output  logic [2:0] command,
    output  logic [2:0] command_next,
    output  logic [23:0] array
);  

    //Not sure why, but registering those signals helps in FSM
    logic rx_data_ready_r       = 1'd0;
    logic coprocessor_busy_r    = 1'd0;
    always_ff @(posedge clk) begin
        if (rst) begin
            rx_data_ready_r     <= 1'd0;
            coprocessor_busy_r  <= 1'd0;
        end
        else begin
            rx_data_ready_r     <= rx_data_ready;
            coprocessor_busy_r  <= coprocessor_busy;
        end
    end

    // Last 3 data bytes concatenation
    logic [23:0] data_array = 24'd0;
    assign array[23:0] = data_array[23:0];

    always_ff @(posedge clk) begin
        if (rst)
            data_array[23:0] <= 24'd0;
        else
            if (rx_data_ready_r)
                data_array[23:0] <= {data_array[15:0],byte_received[7:0]};
    end

    //FSM
    enum logic [2:0]{IDLE, READ_A = 'd1, READ_B = 'd2, BUSY} state, state_next;
    assign  command[2:0] = state[2:0];
    assign  command_next[2:0] = state_next[2:0];

    always_comb begin
        state_next[2:0] = IDLE;
        case(state)
            IDLE:   begin
                        if (data_array[23:0]=={"ra",8'h0A})
                            state_next[2:0] = READ_A;
                        else if (data_array[23:0]=={"rb",8'h0A})
                            state_next[2:0] = READ_B;
                    end
            READ_A: begin
                        state_next = BUSY;
                    end
            READ_B: begin
                        state_next = BUSY;
                    end
            BUSY:   begin
                        state_next = BUSY;
                        if (!coprocessor_busy_r)
                            state_next[2:0] = IDLE;
                    end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst)
            state[2:0] <= IDLE;
        else
            state[2:0] <= state_next[2:0];
    end

endmodule