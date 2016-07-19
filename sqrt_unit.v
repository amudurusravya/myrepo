//------------------------------------------------------------------------------
// This unit computes f=sqrt(e) 
// where u0 is 
// sqrt_unit.v
//
//------------------------------------------------------------------------------


`timescale 1 ns / 1 ps


module sqrt_unit (
  input clk,
  input reset,
  input [35:0] data_e, 
  input sqrt_unit_start,
  output sqrt_unit_done,
  output [22:0] data_out_f,
  output [5:0] n_dec_dig
);
  
// local variables
wire [47:0] data_e_lzd;
wire [34:0] data_in;
reg [5:0] exp_f; // exp_f = 5-lzd(e)
reg [5:0] exp_f_a; // exp_f = 5-lzd(e)
reg [5:0] exp_f_b; // exp_f = 5-lzd(e)

reg [34:0] x_f;
reg [34:0] x_f_a;
reg [29:0] x_f_sig;
reg [22:0] out_f;
reg [5:0] n_decimal;
reg [40:0] mul_temp_c1x;
reg [20:0] c1x;
reg [20:0] c0;
wire [20:0] res_y_f;
reg [19:0] y_f;

reg sqrt_done;  
wire [5:0] lzd_output;
wire [11:0] sqrt1_c1;
wire [19:0] sqrt1_c0;
wire [11:0] sqrt2_c1;
wire [19:0] sqrt2_c0;
reg [5:0] data_in_sqrt;

reg [11:0] sqrt_c1;
reg [19:0] sqrt_c0;
reg [1:0] state_sqrt = 2'b00;
reg [1:0] next_state_sqrt = 2'b00;
reg reduce_range;
reg reduce_range_done;
reg compute_sqrt;
reg compute_sqrt_done;
reg range_reconstruction;
reg range_reconstruction_done;

assign data_in = data_e[34:0]; //ignore sign bit
assign data_e_lzd = {data_in,13'b1111111111111};
lzd lzd_u0(data_e_lzd,lzd_output);
sqrt_unit_lut_1 sqrt_lookup_table1(data_in_sqrt,sqrt1_c1,sqrt1_c0);
sqrt_unit_lut_2 sqrt_lookup_table2(data_in_sqrt,sqrt2_c1,sqrt2_c0);
fixed_point_adder #(21) add_c1x_c0(c1x,c0,res_y_f);


always @(posedge clk) begin
  if(reduce_range == 1'b1) begin
    //exp_f = 5-LeadingZeroDetector(e);
    //x_f? = e >> exp_f;
    //x_f = if(exp_f[0], x_f?>>1, x_f?);
    exp_f = 6'b000101 - lzd_output; 
    x_f_a = data_in >> exp_f;
    x_f = x_f_a >> exp_f[0];
    reduce_range_done = 1'b1;
  end
end

always @(posedge clk) begin
  if(compute_sqrt == 1'b1) begin
     // do the multiplication part
     //y_e = sqrt_c1*x_f+sqrt_c0;
     if(exp_f[0] == 1'b1) begin
       data_in_sqrt = x_f[27:22];
       sqrt_c1 = sqrt1_c1;
       sqrt_c0 = sqrt1_c0;
       c0 = {2'b00,sqrt_c0[19:1]};
       x_f_sig = {1'b0,x_f[28:0]};
       mul_temp_c1x = sqrt_c1[10:0] * x_f_sig; //x_f - 2 decimal and 28 fraction
       c1x = {sqrt_c1[11],mul_temp_c1x[40:21]}; // 3 decimal and 17 fraction
     end else begin
       data_in_sqrt = x_f[27:22];
       sqrt_c1 = sqrt2_c1;
       sqrt_c0 = sqrt2_c0;
       mul_temp_c1x = sqrt_c1[10:0] * x_f[29:0]; // x_f - 2 decimal and 28 fraction
       c1x = {1'b0,mul_temp_c1x[40:21]}; // 3 decimal and 17 fraction
       c0 = {2'b00,sqrt_c0[19:1]};
     end
      y_f = res_y_f[19:0];
      compute_sqrt_done = 1'b1;
  end else begin
      compute_sqrt_done = 1'b0;
  end     
      //sign_bit_c1x = sqrt_c1[11] ^ x_f[35];
      //temp_sqrt_c1 = sqrt_c1 & 13'b0111111111111; // to make sign bit 0   
      
  
end

always @(posedge clk) begin
  if(range_reconstruction == 1'b1) begin
    //exp_f? = if(exp_f[0], exp_f+1>>1, exp>>1);
    //f = y_f << exp_f?;
    if(exp_f[0] == 1'b1) begin
      exp_f_a = exp_f+1;
    end else begin
      exp_f_a = exp_f;
    end
      exp_f_b = exp_f_a/2;
      out_f = y_f << exp_f_b;
      n_decimal = 2'b10+exp_f_b; 
      range_reconstruction_done = 1'b1;
  end else begin
      range_reconstruction_done = 1'b0;
  end
end

 
always @* begin: FSM
  case(state_sqrt)
  2'b00 :if(sqrt_unit_start == 1'b1) begin
            reduce_range = 1'b1;
            next_state_sqrt = 2'b01;
          end else begin
            next_state_sqrt = 2'b00;
          end
  2'b01 :if(reduce_range_done == 1'b1) begin
            compute_sqrt = 1'b1;
            next_state_sqrt = 2'b10;
          end else begin
            next_state_sqrt = 2'b01;
          end  
  2'b10 :if(compute_sqrt_done == 1'b1) begin
          range_reconstruction = 1'b1;
          next_state_sqrt = 2'b11;
         end else begin
           next_state_sqrt = 2'b10;
         end
  2'b11 :if(range_reconstruction_done == 1'b1) begin
            sqrt_done = 1'b1;
            next_state_sqrt = 2'b00;
          end else begin
            next_state_sqrt = 2'b11;
          end
endcase
end

always @(posedge clk or posedge reset) begin
  if(reset) begin
    state_sqrt <= 2'b00;
  end else begin
  state_sqrt <= next_state_sqrt;
end
end
assign sqrt_unit_done = sqrt_done;
assign data_out_f = out_f;
assign n_dec_dig = n_decimal;    
endmodule

  
  


