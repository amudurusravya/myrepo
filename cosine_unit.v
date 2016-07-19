//------------------------------------------------------------------------------
// This unit computes g0 = sine(2*pi*u1) and g1 = cos(2*pi*u1) 
// where u1 is from tausworthe generator 
// cosine_unit.v
//
//------------------------------------------------------------------------------


`timescale 1 ns / 1 ps


module cosine_unit (
  input clk,
  input reset,
  input [15:0] data_in,
  input cosine_unit_start,
  output cosine_unit_done,
  output [19:0] data_out_g0,
  output [19:0] data_out_g1
);
  
// local variables
wire [11:0] cos_c1;
wire [19:0] cos_c0;
wire [11:0] sin_c1;
wire [19:0] sin_c0;

reg [24:0] temp_y_ga;
reg [24:0] temp_y_gb;
reg [19:0] y_ga;
reg [19:0] y_gb;
wire [19:0] res_y_ga;
wire [19:0] res_y_gb;
reg [19:0] g0;
reg [19:0] g1;
//reg [19:0] g0_out;
//reg [19:0] g1_out;
reg [13:0] x_g_a;
reg [13:0] x_g_b;

reg [1:0] state_cos = 2'b00;
reg [1:0] next_state_cos = 2'b00;
reg reduce_range;
reg reduce_range_done;
reg compute_cos;
reg compute_cosine_done;
reg compute_sin;
reg compute_sine_done;
reg range_reconstruction;
reg range_reconstruction_g0_done;
reg range_reconstruction_g1_done;
reg cos_done;
wire res_y_ga_neg_sign;
wire res_y_gb_neg_sign;

wire [6:0] data_in_sin;
wire [6:0] data_in_cos;

cosine_unit_lut cosine_lookup_table(data_in_cos,cos_c1,cos_c0);
cosine_unit_lut sine_lookup_table(data_in_sin,sin_c1,sin_c0);
fixed_point_adder #(20) add_c1x_c0_cos(y_ga,cos_c0,res_y_ga);
fixed_point_adder #(20) add_c1x_c0_sin(y_gb,sin_c0,res_y_gb);


assign data_in_cos = x_g_a[13:7];
assign data_in_sin = x_g_b[13:7];

always @(posedge clk or posedge reset) begin
  if(reset) begin
    x_g_a <= 14'b00000000000000;
    x_g_b <= 14'b11111111111111;
  end else begin
  if(reduce_range == 1'b1) begin
    //quad = u1[15:14];
    //x_g_a = u1[13:0];
    //x_g_b = (1-2?-14)-u1[13:0];
     
    x_g_a <= data_in[13:0];
    x_g_b <= 14'b11111111111111 - data_in[13:0];
    reduce_range_done = 1'b1;
  end
  end
end

always @(posedge clk) begin
  if(compute_sin == 1'b1) begin
     // do the multiplication part
     //y_e = sqrt_c1*x_f+sqrt_c0;
     temp_y_gb = sin_c1[10:0] * x_g_b;
     //sign_bit_c1x_cos = cos_c1[11];
     y_gb = {sin_c1[11],temp_y_gb[24:6]};
     compute_sine_done = 1'b1;
   end else begin
     compute_sine_done = 1'b0;
   end
end


always @(posedge clk) begin
  if(compute_cos == 1'b1) begin
     // do the multiplication part
     //y_e = sqrt_c1*x_f+sqrt_c0;
     temp_y_ga = cos_c1[10:0] * x_g_a;
     //sign_bit_c1x_cos = cos_c1[11];
     y_ga = {cos_c1[11],temp_y_ga[24:6]};
     compute_cosine_done = 1'b1;
  end else begin
    compute_cosine_done = 1'b0;
  end
end
   
assign res_y_gb_neg_sign = res_y_gb[19] ^ 1'b1;
assign res_y_ga_neg_sign = res_y_ga[19] ^ 1'b1;

always @(posedge clk) begin
  if(range_reconstruction == 1'b1) begin
      //switch(seg)
      //case 0: g0 = y_g_b; g1 = y_g_a;
      //case 1: g0 = y_g_a; g1 = -y_g_b;
      //case 2: g0 = -y_g_b; g1 = -y_b_a;
      //case 3: g0 = -y_g_a; g1 = y_g_b;
      case(data_in[13:12]) 
        2'b00 : g0 = res_y_gb; 
        2'b01 : g0 = res_y_ga; 
        2'b10 : g0 = {res_y_gb_neg_sign,res_y_gb[18:0]}; 
        2'b11 : g0 = {res_y_ga_neg_sign,res_y_ga[18:0]};
      endcase 
      range_reconstruction_g0_done = 1'b1;
  end else begin
      range_reconstruction_g0_done = 1'b0;
  end
end
always @(posedge clk) begin
  if(range_reconstruction == 1'b1) begin

case(data_in[13:12]) 
        2'b00 : g1 = res_y_ga;
        2'b01 : g1 = {res_y_gb_neg_sign,res_y_gb[18:0]};
        2'b10 : g1 = {res_y_ga_neg_sign,res_y_ga[18:0]};
        2'b11 : g1 = res_y_gb;
        endcase
      range_reconstruction_g1_done = 1'b1;
  end else begin
      range_reconstruction_g1_done = 1'b0;
  end
end


always @* begin: FSM
  case(state_cos)
  2'b00 :if(cosine_unit_start == 1'b1) begin
            reduce_range = 1'b1;
            next_state_cos = 2'b01;
          end else begin
            next_state_cos = 2'b00;
          end
  2'b01 :if(reduce_range_done == 1'b1) begin
            compute_cos <= 1'b1;
            compute_sin <= 1'b1;
            next_state_cos = 2'b10;
          end else begin
            next_state_cos = 2'b01;
          end  
  2'b10 :if(compute_sine_done == 1'b1 && compute_cosine_done == 1'b1) begin
          range_reconstruction = 1'b1;
          next_state_cos = 2'b11;
         end else begin
           next_state_cos = 2'b10;
         end
  2'b11 :if(range_reconstruction_g0_done == 1'b1 && range_reconstruction_g1_done == 1'b1) begin
            cos_done = 1'b1;
            next_state_cos = 2'b00;
          end else begin
            next_state_cos = 2'b11;
          end
endcase
end

always @(posedge clk) begin
  state_cos <= next_state_cos;
end
assign cosine_unit_done = cos_done;
assign data_out_g0 = g0;
assign data_out_g1 = g1;
endmodule

  
  



