module tp_lifegame (
    input clk, 
    input rst, 
    output [4:0] vgaRed, 
    output [4:0] vgaBlue, 
    output [5:0] vgaGreen, 
    output       hsync, 
    output       vsync
);

    logic pck;
    logic [255:0] outseed;
    logic [9:0] h_count, v_count;
    logic seed_data;


    pckgen pckgen(.SYSCLK(clk), .PCK(pck));

    
    lfsr lfsr(
        .clk(clk), 
        .rst(rst), 
        .outseed(outseed)
    );

    vga_count_hv vga_count_hv(
        .plk(pck), 
        .rst(rst), 
        .v_count(v_count), 
        .h_count(h_count)
    );

    rd_ram_data rd_ram_data(
        .clk(pck),
        .rst(rst), 
        .v_count(v_count), 
        .h_count(h_count), 
        .lfsr_data(outseed[0]), 
        .outdata(seed_data)
    );

    outputvga outputvga(
        .clk(pck), 
        .rst(rst), 
        .seed(seed_data), 
        .v_count(v_count), 
        .h_count(h_count), 
        .vgaRed (vgaRed), 
        .vgaBlue (vgaBlue), 
        .vgaGreen (vgaGreen), 
        .hsync(hsync), 
        .vsync (vsync)
    );
    
endmodule