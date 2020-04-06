module command_decoder(
    input   logic clk,
    input   logic rst,
    input   logic [7:0] byte_received,
    input   logic rx_data_ready,
    input   logic coprocessor_busy,
    output  logic [1:0] command
);

    // Last 3 data bytes concatenation
    logic [23:0] data_array = 24'd0;
    logic [23:0] data_array_next = 24'd0;

    always_comb begin
        if (rx_data_ready)
            data_array_next[23:0] = {data_array_next[15:0],byte_received[7:0]};
    end

    always_ff @(posedge clk) begin
        if (rst)
            data_array[23:0] <= "000";
        else
            data_array[23:0] <= data_array_next[23:0];
    end

    //FSM
    enum logic [1:0]{IDLE, READ_A, BUSY} state, state_next;
    assign  command[1:0] = state[1:0];

    always_comb begin
        state_next[1:0] = IDLE;
        case(state)
            IDLE:   begin
                        if (data_array=={"ra",8'h0A})
                            state_next[1:0] = READ_A;
                    end
            READ_A: begin
                        state_next = BUSY;
                    end
            BUSY:   begin
                        state_next = BUSY;
                        if (!coprocessor_busy)
                            state_next[1:0] = IDLE;
                    end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst)
            state[1:0] <= IDLE;
        else
            state[1:0] <= state_next[1:0];
    end

endmodule