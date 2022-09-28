module vga_count_hv(
    input plk, 
    input rst, 
    output logic [9:0] h_count, 
    output logic [9:0] v_count

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

 //counting height 800
    always @(posedge plk)
    begin
        if(rst)
            h_count <= 0;
        else 
            h_count <= (h_count == END_OF_ROW - 1) ? 0 : h_count + 1;
    end

    // count vertical 640
    always @(posedge plk)
    begin
        if(rst)
            v_count <= 0;
        else if(h_count == END_OF_ROW - 1)
            v_count <= (v_count == END_OF_COLUMN - 1) ? 0 : v_count + 1;
        else 
            v_count <= v_count;
    end
endmodule 
