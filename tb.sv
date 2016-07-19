`timescale 1ns/1ps
module tb();
  reg clk,reset;
  wire [15:0] x0,x1;
  //reg [15:0] x_0,x_1;
  integer f,i;
  
  initial begin
    f=$fopen("output_gng.txt","w");
    
    clk = 1'b0;
    reset = 1'b1;
    repeat(2) #5 clk = ~clk;
    reset = 1'b0;
    forever #5 clk = ~clk;
  end
  top_gng gng(clk,reset,x0,x1);
 /*
  initial begin
    @(posedge clk);
    for (i=0;i<100;i=1+1) begin
      x_0[i] <= x0;
      x_1[i] <= x1;
      @(posedge clk);
    end
  end
  */
  initial begin
    @(posedge clk)
      @(posedge clk)
      @(posedge clk)
      @(posedge clk)
      
    for(i=0;i<10000;i=1+1) begin
      @(posedge clk)
      $fwrite(f,"%b %b\n",x0,x1);
    end
    $fclose(f);
    $finish;
  end
  
      

endmodule
  



