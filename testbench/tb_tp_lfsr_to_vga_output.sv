module tb_tp_lfsr_to_vga_output;

logic clk, rst;
logic [4:0] vgaRed, vgaBlue;
logic [5:0] vgaGreen;
logic hsync, vsync;

parameter P_CLOCK_FREQ = 1000.0 / 125.0; // 1250MHz

tp_lfsr_to_vga_output tp_lfsr_to_vga_output(
    .clk (clk), 
    .rst (rst), 
    .vgaRed (vgaRed), 
    .vgaBlue (vgaBlue), 
    .vgaGreen (vgaGreen), 
    .hsync   (hsync), 
    .vsync   (vsync)
);

initial begin
    clk <= 1'b0;
    rst <= 1'b0;
end

always #(P_CLOCK_FREQ / 2) begin
    clk <= ~clk;
end

initial begin   
    repeat(320) @(posedge clk);
    rst <= 1'b1;
    repeat(20)@(posedge clk);
    rst <= 1'b0;
 end 
 
initial begin
    @(posedge clk);
    while(rst) @(posedge clk);
    repeat(4*800 * 600 + 4) @(posedge clk);

    $finish;
end 
endmodule