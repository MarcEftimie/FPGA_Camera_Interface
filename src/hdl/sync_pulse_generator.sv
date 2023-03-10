`timescale 1ns / 1ps
`default_nettype none

module sync_pulse_generator 
    #(
        parameter TOTAL_COLUMNS = 800,
        parameter TOTAL_ROWS = 524,
        parameter ACTIVE_COLUMNS = 640,
        parameter ACTIVE_ROWS = 480,
        parameter FRONT_PORCH_HORIZONTAL = 16,
        parameter FRONT_PORCH_VERTICAL = 11,
        parameter BACK_PORCH_HORIZONTAL = 48,
        parameter BACK_PORCH_VERTICAL = 31
    )(
        input wire clk_i, reset_i,
        output logic hsync_o, vsync_o, video_en_o,
        output logic [$clog2(ACTIVE_COLUMNS)-1:0] x_o,
        output logic [$clog2(ACTIVE_ROWS)-1:0] y_o,
        output logic [$clog2(76800)-1:0] pixel_o
    );

    logic [9:0] row_count, column_count;
    logic [1:0] pixel_4_count;

    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            row_count <= 0;
            column_count <= 0;
            x_o <= 0;
            y_o <= 0;
            pixel_o <= 1;
            pixel_4_count <= 0;
        end else begin
            if ((column_count < ACTIVE_COLUMNS) && (row_count < ACTIVE_ROWS)) begin
                x_o <= x_o + 1;
                if (pixel_4_count == 3) begin
                    pixel_o <= pixel_o + 1;
                end
                pixel_4_count <= pixel_4_count + 1;
            end
            // Iterates through columns
            if (column_count < TOTAL_COLUMNS - 1) column_count <= column_count + 1;
            else begin
                if (row_count < ACTIVE_ROWS - 1) y_o <= y_o + 1;
                // Iterates through rows
                if (row_count < TOTAL_ROWS - 1) row_count <= row_count + 1;
                else begin
                    // Reset row count after each frame
                    row_count <= 0;
                    pixel_o <= 0;
                    pixel_4_count <= 0;
                    y_o <= 0;
                end
                // Reset column count after each row
                column_count <= 0;
                x_o <= 0;
            end 
        end
    end

    assign vsync_o = (row_count < ((ACTIVE_ROWS + FRONT_PORCH_VERTICAL))) | (row_count > ((TOTAL_ROWS - BACK_PORCH_VERTICAL - 1))) ? 1'b0 : 1'b1;
    assign hsync_o = (column_count < ((ACTIVE_COLUMNS + FRONT_PORCH_HORIZONTAL))) | (column_count > ((TOTAL_COLUMNS - BACK_PORCH_HORIZONTAL - 1))) ? 1'b0 : 1'b1;
    assign video_en_o = (column_count < ACTIVE_COLUMNS) && (row_count < ACTIVE_ROWS);
    
endmodule
