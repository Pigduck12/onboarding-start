/*
 * Copyright (c) 2024 Damir Gazizullin
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
//hi
module pwm_peripheral (
    input  wire       clk,      // clock
    input  wire       rst_n,     // reset_n - low to reset
    input  wire [7:0] en_reg_out_7_0,
    input  wire [7:0] en_reg_out_15_8,
    input  wire [7:0] en_reg_pwm_7_0,
    input  wire [7:0] en_reg_pwm_15_8,
    input  wire [7:0] pwm_duty_cycle,
    input wire spi_data_updated,
    output wire [15:0] out
);
    localparam clk_div_trig = 12; // Divide by (12+1)*256, yielding 3000 (3004.80769) Hz
    reg [10:0] clk_counter;
    reg [7:0] pwm_counter;
    reg        sync_0, sync_1, sync_2;
    reg [7:0]  safe_duty_cycle;
    reg [15:0] out_reg;
    assign out[0]  = out_reg[0];
    assign out[1]  = out_reg[1];
    assign out[2]  = out_reg[2];
    assign out[3]  = out_reg[3];
    assign out[4]  = out_reg[4];
    assign out[5]  = out_reg[5];
    assign out[6]  = out_reg[6];
    assign out[7]  = out_reg[7];
    assign out[8]  = out_reg[8];
    assign out[9]  = out_reg[9];
    assign out[10] = out_reg[10];
    assign out[11] = out_reg[11];
    assign out[12] = out_reg[12];
    assign out[13] = out_reg[13];
    assign out[14] = out_reg[14];
    assign out[15] = out_reg[15];
    wire pwm_signal = (safe_duty_cycle == 8'hFF) ? 1'b1 : (pwm_counter < safe_duty_cycle); // 253 is 98.82% 254 is 99.21%, 255 is 100%, not 99.61%
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_reg         <= 16'b0;
            pwm_counter     <= 8'h00;     // Reset PWM phase
            clk_counter     <= 11'h000;   // Reset prescaler 
            safe_duty_cycle <= 8'h00;     // Default to 0% duty 
        end else begin
            if (spi_data_updated) begin
                safe_duty_cycle <= pwm_duty_cycle; 
            end

            if (clk_counter == clk_div_trig) begin
                clk_counter <= 0;        
                pwm_counter <= pwm_counter + 1; 
            end else begin
                clk_counter <= clk_counter + 1; 
            end
            out_reg[7:0] <= en_reg_out_7_0;
            out_reg[15:8] <= en_reg_out_15_8;
            // Apply PWM to each bit individually if enabled
            // Lower 8 bits
            if (en_reg_pwm_7_0[0]) out_reg[0] <= (pwm_signal) ? en_reg_out_7_0[0] : 1'b0;
            if (en_reg_pwm_7_0[1]) out_reg[1] <= (pwm_signal) ? en_reg_out_7_0[1] : 1'b0;
            if (en_reg_pwm_7_0[2]) out_reg[2] <= (pwm_signal) ? en_reg_out_7_0[2] : 1'b0;
            if (en_reg_pwm_7_0[3]) out_reg[3] <= (pwm_signal) ? en_reg_out_7_0[3] : 1'b0;
            if (en_reg_pwm_7_0[4]) out_reg[4] <= (pwm_signal) ? en_reg_out_7_0[4] : 1'b0;
            if (en_reg_pwm_7_0[5]) out_reg[5] <= (pwm_signal) ? en_reg_out_7_0[5] : 1'b0;
            if (en_reg_pwm_7_0[6]) out_reg[6] <= (pwm_signal) ? en_reg_out_7_0[6] : 1'b0;
            if (en_reg_pwm_7_0[7]) out_reg[7] <= (pwm_signal) ? en_reg_out_7_0[7] : 1'b0;

            // Upper 8 bits
            if (en_reg_pwm_15_8[0]) out_reg[8] <= (pwm_signal) ? en_reg_out_15_8[0] : 1'b0;
            if (en_reg_pwm_15_8[1]) out_reg[9] <= (pwm_signal) ? en_reg_out_15_8[1] : 1'b0;
            if (en_reg_pwm_15_8[2]) out_reg[10] <= (pwm_signal) ? en_reg_out_15_8[2] : 1'b0;
            if (en_reg_pwm_15_8[3]) out_reg[11] <= (pwm_signal) ? en_reg_out_15_8[3] : 1'b0;
            if (en_reg_pwm_15_8[4]) out_reg[12] <= (pwm_signal) ? en_reg_out_15_8[4] : 1'b0;
            if (en_reg_pwm_15_8[5]) out_reg[13] <= (pwm_signal) ? en_reg_out_15_8[5] : 1'b0;
            if (en_reg_pwm_15_8[6]) out_reg[14] <= (pwm_signal) ? en_reg_out_15_8[6] : 1'b0;
            if (en_reg_pwm_15_8[7]) out_reg[15] <= (pwm_signal) ? en_reg_out_15_8[7] : 1'b0;
        end
    end

endmodule













