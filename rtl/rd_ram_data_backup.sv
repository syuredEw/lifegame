module rd_ram_data(
    input       clk, 
    input       rst,
    input   [9:0]     v_count, 
    input   [9:0]    h_count, 
    input        lfsr_data, 

    output outdata
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

    localparam [9:0] DLY = 2;
    localparam [9:0] VGA_OUT_OF_RANGE = 900;
    // output ram data
    logic [639:0] doutb_ram0;
    logic [639:0] doutb_ram1;
    logic [639:0] doutb;
    logic [639:0] doutb_dly1;
    logic [639:0] doutb_dly2;

    // enb ram
    logic enb_ram0;
    logic enb_ram1;

    // ram address 
    logic [8:0] addrb_ram0, addrb_ram1;

    // neibor
    logic [8:0] neibor;

    // vertical, height
    logic [9:0] height;
    logic [9:0] vertical;

    // ena, wea, addra, dina
    logic ena_ram0, ena_ram1;
    logic [0:0] wea;
    logic [8:0] addra;
    logic [639:0] dina;

    // lifegame judgement output
    logic output_lifegame_jud;

    // lfsr_or_cal
    logic lfsr_or_cal;
    
    // switch_ram
    logic switch_ram;

    assign outdata = (lfsr_or_cal) ? output_lifegame_jud : lfsr_data;
    // lifegame_cal lifegame jugement module
    lifegame_cal lifegame_cal(
        .clk (clk), 
        .rst (rst), 
        .neibor (neibor), 
        .cal_enable (lfsr_or_cal), 
        .outdata (output_lifegame_jud)
    );

    // connect block_mem_ram
    blk_mem_gen_0 blk_mem_gen_0(
        .clka (clk), 
        .ena (ena_ram0), 
        .wea  (wea), 
        .addra (addra), 
        .dina (dina), 
        .clkb (clk), 
        .enb (enb_ram0),
        .addrb (addrb_ram0), 
        .doutb (doutb_ram0)
    );

    blk_mem_gen_1 blk_mem_gen_1(
        .clka (clk), 
        .ena (ena_ram1), 
        .wea (wea), 
        .addra (addra), 
        .dina (dina), 
        .clkb (clk), 
        .enb  (enb_ram1), 
        .addrb (addrb_ram1), 
        .doutb (doutb_ram1)
    );
    
    // ramdata
    always @(posedge clk)
    begin
        if(rst)
        begin
            doutb <= 0;
            doutb_dly1 <= 0;
            doutb_dly2 <= 0;
        end
        else 
        begin 
            if(h_count == 4) begin
                doutb_dly2 <= doutb_dly1;
                doutb_dly1 <= doutb;
                if(!switch_ram)begin
                    doutb <= doutb_ram0;
                end else begin
                    doutb <= doutb_ram1;
                end
            end else begin
                doutb_dly2 <= doutb_dly2;
                doutb_dly1 <= doutb_dly1;
                doutb <= doutb;  
            end
        end
    end

    // enb 
    always @(posedge clk) begin
        if(rst)begin
            enb_ram0 <= 0;
            enb_ram1 <= 0;
        end
        else begin
            if(h_count == 1 && v_count >= BEGINNING_OF_DISPLAY_PIXELS_V - 1) begin
                if(!switch_ram) begin
                    enb_ram0 <= 1;
                end else begin
                    enb_ram1 <= 1;
                end
            end else if(h_count == 2 && v_count >= BEGINNING_OF_DISPLAY_PIXELS_V - 1) begin
                if(!switch_ram) begin
                    enb_ram0 <= 1;
                end else begin
                    enb_ram1 <= 1;
                end
            end else begin
                enb_ram0 <= 0;
                enb_ram1 <= 0;
            end
        end
    end

    // addrb_ram0, addrb_ram1
    always @(posedge clk) begin
        if(rst)begin
            addrb_ram0 <= 0;
            addrb_ram1 <= 0;
        end else begin
            if(!switch_ram) begin
                if(v_count == BEGINNING_OF_DISPLAY_PIXELS_V - 1)
                    addrb_ram0 <= 1 ;
                else 
                    addrb_ram0 <= v_count + 2 - BEGINNING_OF_DISPLAY_PIXELS_V;
                addrb_ram1 <= 0;
            end else begin
                addrb_ram0 <= 0;
                if(v_count == BEGINNING_OF_DISPLAY_PIXELS_V - 1)
                    addrb_ram1 <= 1;
                else 
                    addrb_ram1 <= v_count + 2  - BEGINNING_OF_DISPLAY_PIXELS_V;
            end
        end
    end

    // height and vertical
    always @(posedge clk) begin
        if(rst) begin
            height <= 0;
            vertical <= 0;
        end else begin
            if(h_count >= BEGINNING_OF_DISPLAY_PIXELS_H - DLY - 1 && h_count < END_OF_ROW - 1)
                height <= h_count + DLY + 1 - BEGINNING_OF_DISPLAY_PIXELS_H;
            else 
                height <= VGA_OUT_OF_RANGE;
            
            //v_count
            if(v_count >= BEGINNING_OF_DISPLAY_PIXELS_V - 1)begin
                if(h_count == END_OF_ROW - 1) begin
                    vertical <= v_count + 1 - BEGINNING_OF_DISPLAY_PIXELS_V;
                end
                else begin
                    if(v_count == BEGINNING_OF_DISPLAY_PIXELS_V)
                        vertical <= 0;
                    else
                        vertical <= vertical;
                end
            end else begin
                vertical <= VGA_OUT_OF_RANGE;
            end
        end
    end

    //neibor 
    always @(posedge clk) begin
        if(rst)begin
            neibor <= 0;
        end
        else begin
            if(!switch_ram)begin
                if(v_count == BEGINNING_OF_DISPLAY_PIXELS_V) begin
                    if(h_count == BEGINNING_OF_DISPLAY_PIXELS_H - DLY)
                        neibor <= {3'b101, 1'b0, doutb_dly1[height], doutb_dly1[height+1], 1'b0, doutb_ram0[height], doutb_ram0[height+1]};
                    else if(h_count == END_OF_ROW - 1 - DLY)
                        neibor <= {3'b101, doutb_dly1[height-1], doutb_dly1[height], 1'b0, doutb_ram0[height-1], doutb_ram0[height], 1'b0};
                    else 
                        neibor <= {3'b100, doutb_dly1[height-1], doutb_dly1[height], doutb_dly1[height+1], doutb_ram0[height-1], doutb_ram0[height], doutb_ram0[height+1]};
                end else if(v_count == END_OF_COLUMN - 1 )
                begin
                    if(h_count == BEGINNING_OF_DISPLAY_PIXELS_H - DLY)
                        neibor <= {1'b0, doutb_dly2[height], doutb_dly2[height+1], 1'b0, doutb_dly1[height], doutb_dly1[height+1], 3'b101};
                    else if(h_count == END_OF_ROW - 1 - DLY)
                        neibor <= {doutb_dly2[height-1], doutb_dly2[height], 1'b0, doutb_dly1[height-1], doutb_dly1[height], 1'b0, 3'b101};
                    else 
                        neibor <= {doutb_dly2[height-1], doutb_dly2[height], doutb_dly2[height+1], doutb_dly1[height-1], doutb_dly1[height], doutb_dly1[height+1], 3'b101};
                end
                else begin
                    if(h_count == BEGINNING_OF_DISPLAY_PIXELS_H - DLY)
                        neibor <= {1'b0, doutb_dly2[height], doutb_dly2[height+1], 1'b0, doutb_dly1[height], doutb_dly1[height+1], 1'b0, doutb_ram0[height], doutb_ram0[height+1]};
                    else if(h_count == END_OF_ROW - 1 - DLY)
                        neibor <= {doutb_dly2[height-1], doutb_dly2[height], 1'b0, doutb_dly1[height-1], doutb_dly1[height], 1'b0, doutb_ram0[height-1], doutb_ram0[height], 1'b0};
                    else 
                        neibor <= {doutb_dly2[height-1], doutb_dly2[height], doutb_dly2[height+1], doutb_dly1[height-1], doutb_dly1[height], doutb_dly1[height+1], doutb_ram0[height-1], doutb_ram0[height], doutb_ram0[height+1]};
                end
            end
            else begin
                if(v_count == BEGINNING_OF_DISPLAY_PIXELS_V) begin
                    if(h_count == BEGINNING_OF_DISPLAY_PIXELS_H - DLY)
                        neibor <= {3'b101, 1'b0, doutb_dly1[height], doutb_dly1[height+1], 1'b0, doutb_ram1[height], doutb_ram1[height+1]};
                    else if(h_count == END_OF_ROW - 1 - DLY)
                        neibor <= {3'b101, doutb_dly1[height-1], doutb_dly1[height], 1'b0, doutb_ram1[height-1], doutb_ram1[height], 1'b0};
                    else 
                        neibor <= {3'b100, doutb_dly1[height-1], doutb_dly1[height], doutb_dly1[height+1], doutb_ram1[height-1], doutb_ram1[height], doutb_ram1[height+1]};
                end else if(v_count == END_OF_COLUMN - 1)
                begin
                    if(h_count == BEGINNING_OF_DISPLAY_PIXELS_H - DLY)
                        neibor <= {1'b0, doutb_dly2[height], doutb_dly2[height+1], 1'b0, doutb_dly1[height], doutb_dly1[height+1], 3'b101};
                    else if(h_count == END_OF_ROW - 1 - DLY)
                        neibor <= {doutb_dly2[height-1], doutb_dly2[height], 1'b0, doutb_dly1[height-1], doutb_dly1[height], 1'b0, 3'b101};
                    else 
                        neibor <= {doutb_dly2[height-1], doutb_dly2[height], doutb_dly2[height+1], doutb_dly1[height-1], doutb_dly1[height], doutb_dly1[height+1], 3'b101};
                end
                else begin
                    if(h_count == BEGINNING_OF_DISPLAY_PIXELS_H - DLY)
                        neibor <= {1'b0, doutb_dly2[height], doutb_dly2[height+1], 1'b0, doutb_dly1[height], doutb_dly1[height+1], 1'b0, doutb_ram1[height], doutb_ram1[height+1]};
                    else if(h_count == END_OF_ROW - 1 - DLY)
                        neibor <= {doutb_dly2[height-1], doutb_dly2[height], 1'b0, doutb_dly1[height-1], doutb_dly1[height], 1'b0, doutb_ram1[height-1], doutb_ram1[height], 1'b0};
                    else 
                        neibor <= {doutb_dly2[height-1], doutb_dly2[height], doutb_dly2[height+1], doutb_dly1[height-1], doutb_dly1[height], doutb_dly1[height+1], doutb_ram1[height-1], doutb_ram1[height], doutb_ram1[height+1]};
                end
            end
        end
    end

    // ena_ram0, ena_ram1
    always @(posedge clk)
    begin
        if(rst) begin
            ena_ram0 <= 0;
            ena_ram1 <= 0;
        end
        else
        begin
            if(v_count >= BEGINNING_OF_DISPLAY_PIXELS_V - 1) begin
                if(switch_ram) begin
                    ena_ram0 <= 1;
                    ena_ram1 <= 0;
                
                end else begin 
                    ena_ram1 <= 1;
                    ena_ram0 <= 0;
                end
            end else begin 
                ena_ram0 <= 0;
                ena_ram1 <= 0;
            end
        end
    end

    // wea 
    always @(posedge clk)
    begin
        if(rst)
            wea <= 0;
        else begin
            if(h_count == END_OF_ROW - 1 && v_count >= BEGINNING_OF_DISPLAY_PIXELS_V)
                wea <= 1;
            else begin
                wea <= 0;
            end
        end
    end

    // addra 
    always @(posedge clk)
    begin
        if(rst)
            addra <= 0;
        else begin
            if(v_count == END_OF_COLUMN - 1)
                addra <= HEIGHT;
            else if(v_count == BEGINNING_OF_DISPLAY_PIXELS_V - 1)
                addra <= 0;
            else if(vertical == VGA_OUT_OF_RANGE)
                addra <= 0;
            else if(h_count == 0)
                addra <= addra;
            else
                addra <= vertical + 1;
        end
    end

    // dina 
    always @(posedge clk)
    begin
        if(rst)
            dina <= 0;
        else begin
            if(h_count >= BEGINNING_OF_DISPLAY_PIXELS_H && v_count >= BEGINNING_OF_DISPLAY_PIXELS_V)begin
                if(!lfsr_or_cal)
                    dina[height - DLY] <= lfsr_data;
                else 
                    dina[height - DLY] <= output_lifegame_jud;
            end
            else 
                dina <= 0;
        end
    end

    // switch_ram
    always @(posedge clk) 
    begin
        if(rst)
            switch_ram <= 0;
        else begin
            if(v_count == END_OF_COLUMN - 1 && h_count == END_OF_ROW - 1)
                switch_ram <= ~switch_ram;
            else
                switch_ram <= switch_ram;
        end
    end

    // lfsr_or_cal  Low : lfsr High: lifegame cal
    always @(posedge clk)
    begin
        if(rst)
            lfsr_or_cal <= 0;
        else
        begin
            if(lfsr_or_cal)
                lfsr_or_cal <= lfsr_or_cal;
            else if(!lfsr_or_cal && v_count == END_OF_COLUMN - 1 && h_count == END_OF_ROW- 1)
                lfsr_or_cal <= 1;
            else
                lfsr_or_cal <= 0;
        end
    end

endmodule
