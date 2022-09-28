module lfsr(
    input         clk, 
    input         rst, 
    output [255:0] outseed
);
    logic [255:0] r;
    logic      tmp_xor;

    always @(posedge clk) begin
        if(rst)
            r <= 256'h13253213;
        else begin
            r <= (r << 1) | tmp_xor;
        end
    end

    // 16bit tap 11, 13, 14, 16
    assign tmp_xor = r[10]^r[12]^r[13]^r[15];
    assign outseed = r;
endmodule