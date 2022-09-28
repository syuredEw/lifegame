module tb_tp_lifegame();
    logic clk, rst;

    logic [4:0] vgaRed;
    logic [4:0] vgaBlue;
    logic [5:0] vgaGreen;
    logic hsync, vsync;

    parameter P_CLOCK_FREQ = 1000.0 / 125.0; // 1250MHz

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
    repeat(4*4*640*900+5000) @(posedge clk);
    $finish;
end

tp_lifegame tp_lifegame(
    .clk(clk), 
    .rst(rst),
    .vgaRed(vgaRed), 
    .vgaBlue(vgaBlue), 
    .vgaGreen(vgaGreen),
    .hsync(hsync), 
    .vsync(vsync)
);

endmodule