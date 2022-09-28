module tb_lifegame_cal;

logic clk, rst;
logic [8:0] neibor;
logic cal_enable;
logic outdata;
parameter P_CLOCK_FREQ = 1000.0 / 50.0; // cal_enable

lifegame_cal lifegame_cal(
    .clk(clk), 
    .rst(rst), 
    .neibor(neibor),
    .cal_enable(cal_enable), 
    .outdata(outdata)
);

initial begin
    clk <= 1'b0;
    rst <= 1'b0;
end

always #(P_CLOCK_FREQ / 2) begin
    clk <= ~clk;
end

initial begin   
    repeat(3) @(posedge clk);
    rst <= 1'b1;
    @(posedge clk);
    rst <= 1'b0;
    cal_enable <= 1'b1;
    neibor <= 9'b111000000;
    @(posedge clk);
    neibor <=9'b000_000_111;
    @(posedge clk);
    neibor <= 9'b111000000;@(posedge clk);
    neibor <= 9'b111100000;@(posedge clk);
    neibor <= 9'b111010000;@(posedge clk);
    neibor <= 9'b011000000;@(posedge clk);
    neibor <= 9'b111110000;@(posedge clk);
    neibor <= 9'b000000111;@(posedge clk);
    neibor <= 9'b100010011;@(posedge clk);
    neibor <= 9'b010_100_010;@(posedge clk);
    neibor <= 9'b111010111;
    @(posedge clk);
    $finish;
end 
endmodule 