
`timescale 1ns/1ps
`default_nettype none

module clk_200KHz_tb;

    parameter CLK_PERIOD_NS = 10;
    
    logic clk_i;
    wire k_o;

    clk_200KHz #(
    ) UUT(
        .*
    );

    always #(CLK_PERIOD_NS/2) clk_i = ~clk_i;

    initial begin
        $dumpfile("clk_200KHz.fst");
        $dumpvars(0, UUT);
        clk_i = 0;
        reset_i = 1;
        repeat(1) @(negedge clk_i);
        reset_i = 0;
        $finish;
    end

endmodule