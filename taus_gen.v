//------------------------------------------------------------------------------
// This unit generates normally distributed random numbers 
// takes 3 seeds as arguments
// taus_gen.v
//
//------------------------------------------------------------------------------


`timescale 1 ns / 1 ps


module taus_gen (
  input clk,
  input reset,
  input rand_gen,
//  input [31:0] seed0,
//  input [31:0] seed1,
//  input [31:0] seed2,
  output [31:0] random_num,
  output reg rand_valid
);

parameter seed0 = 32'hffffffff;
parameter seed1 = 32'hcccccccc;
parameter seed2 = 32'h00ff00ff;

wire [31:0] b0,b1,b2;
wire [31:0] next_s0,next_s1,next_s2;
reg [31:0] s0,s1,s2;

assign b0      = (((s0 << 13) ^ s0) >> 19);
assign next_s0 = (((s0 & 32'hfffffffe) << 12) ^ b0);
assign b1      = (((s1 << 2 ) ^ s1) >> 25);
assign next_s1 = (((s1 & 32'hfffffff8) << 4 ) ^ b1);
assign b2      = (((s2 << 3 ) ^ s2) >> 11);
assign next_s2 = (((s2 & 32'hfffffff0) << 17) ^ b2);

assign random_num = s0 ^ s1 ^ s2;

always @(posedge clk or posedge reset)
    if(reset) begin
       s0 <= seed0;
       s1 <= seed1;
       s2 <= seed2;
       rand_valid <=1'b0;
     end else begin
       if(rand_gen) begin      
        s0 <= next_s0;
        s1 <= next_s1;
        s2 <= next_s2;
        rand_valid <= 1'b1;
      end
     end
endmodule