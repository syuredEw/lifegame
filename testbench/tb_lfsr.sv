`timescale 1ns/100ps

module tb_lfsr;

reg clk;
reg  load;
reg [15:0] seed;
wire [15:0] out;
lfsr lfsr(
    .clk (clk), 
    .load (load), 
    .seed (seed),
    .outseed (out)
);

parameter P_CLOCK_FREQ = 1000.0 / 50.0; // 50MHz

initial begin
    clk <= 1'b0;
end

always #(P_CLOCK_FREQ / 2) begin
    clk <= ~clk;
end

initial begin
    load <= 1;
    seed <= 1;
    repeat(2) @(posedge clk);
    load <= 0;
end 

initial begin
    @(posedge clk);
    while(load) @(posedge clk);
    repeat(255 + 4) @(posedge clk);

    $finish;
end 
endmodule
