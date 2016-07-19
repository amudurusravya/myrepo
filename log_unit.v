//------------------------------------------------------------------------------
// This unit computes -2*ln(u0) 
// where u0 is 
// log_unit.v
//
//------------------------------------------------------------------------------


`timescale 1 ns / 1 ps


module log_unit (
  input clk,
  input reset,
  input [47:0] data_u0,
  input log_unit_start,
  output log_unit_done,
  output [35:0] data_out_e
);
  
// local variables
reg [5:0] exp_e; // exp_e = lzd(u0)+1
reg [47:0] x_e;
reg log_done;  
wire [5:0] lzd_output;
wire [12:0] log_c2;
wire [21:0] log_c1;
wire [29:0] log_c0;
reg [49:0] temp_x_e;
reg sign_bit_c2x;
reg [12:0] temp_log_c2;
reg [60:0] mul_temp_c2x;
reg [61:0] temp_y_e_1;
reg [61:0] temp_log_c1;
reg [61:0] c2x;
reg [61:0] c1;
reg sign_bit_c2x_c1;
reg [61:0] temp_res_c2x_c1;
wire [61:0] res_c2x_c1;
reg [109:0] mul_temp;
reg [31:0] temp_y_e_2; 
reg [31:0] temp_log_c0;
reg [31:0] c2x_c1;
reg [31:0] c0;
wire [31:0] res_y_e;
reg [38:0] temp_e_a;
reg [35:0] e_a;
reg [35:0] temp_e;
wire [35:0] res_e;
reg [35:0] out_e;

reg [1:0] state = 2'b00;
reg [1:0] next_state = 2'b00;
reg [32:0] ln2;
reg reduce_range;
reg reduce_range_done;
reg compute_ln;
reg compute_ln_done;
reg range_reconstruction;
reg range_reconstruction_done;

lzd lzd_u0(data_u0,lzd_output);
log_unit_lut logarithm_lookup_table(x_e[47:40],log_c2,log_c1,log_c0);
fixed_point_adder #(62) add_c2x_c1(c2x,c1,res_c2x_c1);
fixed_point_adder #(32) add_c2x_c1_c0(c2x_c1,c0,res_y_e);
fixed_point_adder #(36) recons(e_a,temp_e,res_e);

always @(posedge clk) begin
  if(reduce_range == 1'b1) begin
    exp_e = lzd_output + 1'b1; // loosing Most significant 1 is we shift left by lzd+1 times
    x_e = data_u0 << exp_e;
    reduce_range_done = 1'b1;
    //y_e = (log_c2*x_e+log_c1)*x_e+log_c0;
    //e'=exp_e*ln2;
    //e=(e'-y_e)<<1;
    //log_done = 1'b1;
  end
end


always @(posedge clk) begin
  if(compute_ln == 1'b1) begin
     // do the multiplication part
     //y_e = (log_c2*x_e+log_c1)*x_e+log_c0;
      //temp_y_e = c2*x;
      temp_x_e = x_e | 50'b01000000000000000000000000000000000000000000000000;
      sign_bit_c2x = log_c2[12] ^ temp_x_e[49];
      temp_log_c2 = log_c2 & 13'b0111111111111; // to make sign bit 0
      mul_temp_c2x = temp_log_c2[11:0] * temp_x_e[48:0];
      temp_y_e_1 = {sign_bit_c2x,mul_temp_c2x};
      //c2*x+c1
      temp_log_c1[61] = log_c1[21];
      temp_log_c1[60:59] = {1'b0,log_c1[20]};
      temp_log_c1[58:0] = {log_c1[19:0],39'b0};
      c2x = temp_y_e_1;
      c1 = temp_log_c1;
      //(c2x+c1)*x
      sign_bit_c2x_c1 = res_c2x_c1[61] ^ temp_x_e[49];
      temp_res_c2x_c1 = res_c2x_c1 & 62'b01111111111111111111111111111111111111111111111111111111111111; // to make sign bit 0
      mul_temp = temp_res_c2x_c1[60:0]*temp_x_e[48:0];
      temp_y_e_2 = {sign_bit_c2x_c1,mul_temp[109:79]}; //1 sign 3 decimal 28 fraction
      //(c2x+c1)*x+c0
      temp_log_c0[31] = log_c0[29];
      temp_log_c0[30:28] = {2'b00,log_c0[28]};
      temp_log_c0[27:0] = log_c0[27:0];
      c2x_c1 = temp_y_e_2;
      c0 = temp_log_c0;  
      compute_ln_done = 1'b1;
  end else begin
      compute_ln_done = 1'b0;
  end
end

always @(posedge clk) begin
  if(range_reconstruction == 1'b1) begin
    //e'=exp_e*ln2;
    //e=(e'+y_e)<<1;
    //log_done = 1'b1;
    ln2 = 33'b010110001011100100001011111110111;// not considering sign bit bcos its positive
    temp_e_a = exp_e * ln2; 
    e_a = {1'b0,temp_e_a[38:4]};//append sign bit
    temp_e ={res_y_e[31],4'b0000,res_y_e[30:0]};
    out_e = {res_e[35],res_e[33:0],1'b0};    
    range_reconstruction_done = 1'b1;
  end else begin
      range_reconstruction_done = 1'b0;
  end
end

 
always @* begin: FSM
  case(state)
  2'b00 :if(log_unit_start == 1'b1) begin
            reduce_range = 1'b1;
            next_state = 2'b01;
          end else begin
            next_state = 2'b00;
          end
  2'b01 :if(reduce_range_done == 1'b1) begin
            compute_ln = 1'b1;
            next_state = 2'b10;
          end else begin
            next_state = 2'b01;
          end  
  2'b10 :if(compute_ln_done == 1'b1) begin
          range_reconstruction = 1'b1;
          next_state = 2'b11;
         end else begin
           next_state = 2'b10;
         end
  2'b11 :if(range_reconstruction_done == 1'b1) begin
            log_done = 1'b1;
            next_state = 2'b00;
          end else begin
            next_state = 2'b11;
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
assign log_unit_done = log_done;
assign data_out_e = out_e;
    
endmodule

  
  

