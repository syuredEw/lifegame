module outputvga(
    input clk, 
    input rst, 

    // seed value
    input seed, 

    // v_count, h_coun
    input [9:0] v_count, 
    input [9:0] h_count,

    // output vga
    output [4:0] vgaRed, 
    output [4:0] vgaBlue, 
    output [5:0] vgaGreen, 
    output       hsync, 
    output       vsync
);

    localparam [9:0] WIDTH  = 640;
    localparam [9:0] HEIGHT = 480;

    localparam [9:0] BEGINNING_OF_HORIZONTAL_SYNC  = 16;
    localparam [9:0] END_OF_HORIZONTAL_SYNC        = BEGINNING_OF_HORIZONTAL_SYNC  + 96; // 112
    localparam [9:0] BEGINNING_OF_DISPLAY_PIXELS_H = END_OF_HORIZONTAL_SYNC        + 48; // 160
    localparam [9:0] END_OF_ROW                    = BEGINNING_OF_DISPLAY_PIXELS_H + WIDTH;

    localparam [9:0] BEGINNING_OF_VERTICAL_SYNC    = 10;
    localparam [9:0] END_OF_VERTICAL_SYNC          = BEGINNING_OF_VERTICAL_SYNC    + 2; // 12
    localparam [9:0] BEGINNING_OF_DISPLAY_PIXELS_V = END_OF_VERTICAL_SYNC          + 33; // 45
    localparam [9:0] END_OF_COLUMN                 = BEGINNING_OF_DISPLAY_PIXELS_V + HEIGHT;



    logic [4:0] VGA_R, VGA_B;
    logic [5:0] VGA_G;
    logic disp_enable;
    assign disp_enable = ((BEGINNING_OF_DISPLAY_PIXELS_H <= h_count) && (h_count < END_OF_ROW) && (BEGINNING_OF_DISPLAY_PIXELS_V <= v_count) && (v_count < END_OF_COLUMN));
   
    // output lfsr to vga
    always @(posedge clk)
    begin
        if(rst) begin
            VGA_R   <= 0;
            VGA_B  <= 0;
            VGA_G <= 0;
        end
        else 
        begin
            if((seed) && (disp_enable))
            begin
                VGA_R   <= 5'b11111;
                VGA_B  <=  5'b11111;
                VGA_G <=  6'b110111;
            end
            else
            begin 
                VGA_R   <= 0;
                VGA_B  <= 0;
                VGA_G <= 0;
            end
        end
    end

    assign vgaRed = VGA_R;
    assign vgaBlue = VGA_B;
    assign vgaGreen = VGA_G;
    // 
    assign  hsync = ~((BEGINNING_OF_HORIZONTAL_SYNC <= h_count) & (h_count < END_OF_HORIZONTAL_SYNC));
    assign  vsync = ~((BEGINNING_OF_VERTICAL_SYNC   <= v_count) & (v_count < END_OF_VERTICAL_SYNC));
endmodule 