`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFSM
// Engineer: Jairo Gonzalez
// 
// Create Date: 07.01.2020 14:17:43
// Design Name: unsigned counter
// Module Name: unsigned_counter
// Project Name: digital_clock
// Target Devices: Nexys4 DDR
// Description: unsigned counter N bits. start, stop, forward and backwards modes
// 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module unsigned_counter #(
    parameter BITS=8)(
        input   logic clk,
        input   logic rst,
        input 	logic start, //1 to start, 0 to stop
        input   logic forward, //1 to count forward, 0 to count backwards
        output  logic [BITS-1:0] number
    );

    logic [BITS-1:0] number_next = 'b0;

    always_comb begin
        //default assignments
        number_next[BITS-1:0] = 'b0;

        if (~start)
            number_next[BITS-1:0] = number[BITS-1:0];
        else if (forward)
            number_next[BITS-1:0] = number[BITS-1:0] + 'd1;
        else
            number_next[BITS-1:0] = number[BITS-1:0] - 'd1;
    end    

    // sequential block for FSM. When clock ticks, update the state
    always_ff @(posedge clk) begin
        if(rst) 
            number[BITS-1:0] <= 'd0;
        else 
            number[BITS-1:0] <= number_next[BITS-1:0];
    end

endmodule