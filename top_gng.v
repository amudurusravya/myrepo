//------------------------------------------------------------------------------
// This is top unit to generate gaussian noise 
// contains log, sqrt, cosine and taus_gen modules instantiated inside this top module 
// top_gng.v
//
//------------------------------------------------------------------------------


`timescale 1 ns / 1 ps


module top_gng (
  input clk,
  input reset,
  output [15:0] output_x0,
  output [15:0] output_x1
);


wire [35:0] log_out;
wire [22:0] sqrt_out;
wire [31:0] u0;
wire [31:0] u1;
reg sqrt_unit_start;
wire sqrt_unit_done;
reg log_unit_start;
wire log_unit_done;
reg cosine_unit_start;
wire cosine_unit_done;
wire [5:0] n_dec_dig;
reg [64:0] zeros;
wire [47:0] log_inp;
wire [15:0] cos_inp;
reg [1:0] state;
reg [1:0] next_state;
reg final_multiply;
reg multiply_done_x0;
reg multiply_done_x1;
reg [15:0] x0_out;
reg [15:0] x1_out;
reg [41:0] x0_out_sig;
reg [41:0] x1_out_sig;
reg [2:0] append_digits_x0;
reg [2:0] append_digits_x1;
wire [19:0] data_g0;
wire [19:0] data_g1;

reg rand_gen;

assign log_inp = {u0,u1[31:16]};
assign cos_inp = u1[15:0];

cosine_unit cosine(clk,reset,cos_inp,cosine_unit_start,cosine_unit_done,data_g0,data_g1);
log_unit log(clk,reset,log_inp,log_unit_start,log_unit_done,log_out);
sqrt_unit sqrt(clk,reset,log_out,sqrt_unit_start,sqrt_unit_done,sqrt_out,n_dec_dig);
taus_gen taus_gen_u0(clk,reset,rand_gen,u0,valid_u0);
taus_gen #(32'h28617901,32'h55555555,32'h617892ef) taus_gen_u1(clk,reset,rand_gen,u1,valid_u1);

always @* begin: FSM_TOP
  case(state)
  2'b00 : begin
          rand_gen = 1'b1;
          if(valid_u0==1'b1 && valid_u1==1'b1) begin
            //rand_gen = 1'b0;
            next_state = 2'b01;
          end else begin
            next_state = 2'b00;
          end
          end
  2'b01 :   begin
            log_unit_start <= 1'b1;
            cosine_unit_start <=1'b1;
            if(log_unit_done == 1'b1) begin
              next_state = 2'b10;
            end else begin
              next_state = 2'b01;
            end  
          end
          
  2'b10 : begin
          sqrt_unit_start = 1'b1;
          if(sqrt_unit_done == 1'b1 && cosine_unit_done == 1'b1) begin
            next_state = 2'b11;
         end else begin
           next_state = 2'b10;
         end
       end
  2'b11 :  begin 
           final_multiply = 1'b1;
            if(multiply_done_x0 && multiply_done_x1) begin
              next_state = 2'b00;
            end else begin
              next_state = 2'b11;
            end
            end
endcase
end

always @(posedge clk or posedge reset) begin
  if(reset) begin
    state <= 2'b00;
  end else begin
    state <= next_state;
  end
end

always @(posedge clk or posedge reset) begin
  if(reset) begin
    x0_out <= 16'b0000000000000000;
    x0_out_sig <= 42'b000000000000000000000000000000000000000000;
  end else begin
    if(final_multiply) begin
      x0_out_sig = sqrt_out*data_g0[18:0];
      append_digits_x0 = 4-n_dec_dig;
      //x0_out = {data_g0[19],zeros[0:append_digits_x0],x0_out_sig[41:31]};
      x0_out = {data_g0[19],x0_out_sig[41:27]};
      multiply_done_x0 = 1'b1;
    end else begin
      multiply_done_x0 = 1'b0;
    end
  end
end

always @(posedge clk or posedge reset) begin
  if(reset) begin
    x1_out <= 16'b0000000000000000;
    x0_out_sig <= 42'b000000000000000000000000000000000000000000;
  end else begin
    if(final_multiply) begin
      append_digits_x1 = 4-n_dec_dig;
      x1_out_sig = sqrt_out*data_g1[18:0];
      //x1_out = {data_g1[19],zeros[0:append_digits_x1],x1_out_sig[41:31]};
      x1_out = {data_g1[19],x1_out_sig[41:27]};
      
      multiply_done_x1 = 1'b1;
    end else begin
      multiply_done_x1 = 1'b0;
    end
  end
end
assign output_x0 = x0_out;
assign output_x1 = x1_out;

endmodule