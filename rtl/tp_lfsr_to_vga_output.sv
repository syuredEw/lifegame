module tp_lfsr_to_vga_output(
    input clk, 
    input rst, 
    output [4:0] vgaRed, 
    output [4:0] vgaBlue, 
    output [5:0] vgaGreen, 
    output       hsync, 
    output       vsync
);

    logic plk;
    logic [15:0] outseed;

    pckgen pckgen(.SYSCLK(clk), .PCK(plk));

    lfsr lfsr(
        .clk (plk), 
        .rst (rst), 
        .outseed(outseed)
    );

    outputvga VGA(
        .clk (plk), 
        .rst (rst), 
        .seed (outseed[0]), 
        .vgaRed (vgaRed), 
        .vgaBlue (vgaBlue), 
        .vgaGreen (vgaGreen), 
        .hsync (hsync),
        .vsync (vsync)
    );
endmodule 