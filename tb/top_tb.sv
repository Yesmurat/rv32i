`timescale 1ns/1ps

module top_tb;

  logic clk;
  logic clr;

  logic [31:0] ALUResultM, WriteDataM;

  top dut(
      .clk(clk),
      .clr(clr),
      .WriteDataM(WriteDataM)
  );

  initial begin
        clk <= 1'b0;
        clr <= 1'b1; #2; clr <= 1'b0;
	    #200; $stop;
  end

    always #5 clk = ~clk;

endmodule