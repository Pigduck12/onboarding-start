/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_uwasic_onboarding_eliot_tong (
  
  // Create wires to refer to the values of the registers
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    wire [7:0] spi_data;  // Holds data from SPI to pass to PWM
    wire spi_ready;       // Signal from SPI to PWM that data is updated
    wire [7:0] en_reg_out_7_0;
    wire [7:0] en_reg_out_15_8;
    wire [7:0] en_reg_pwm_7_0;
    wire [7:0] en_reg_pwm_15_8;
    wire [7:0] pwm_duty_cycle;
    wire [15:0] pwm_raw_outputs;
    wire       w_pwm_signal;
  
pwm_peripheral pwm_peripheral_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en_reg_out_7_0(en_reg_out_7_0), //
    .en_reg_out_15_8(en_reg_out_15_8),
    .en_reg_pwm_7_0(en_reg_pwm_7_0),
    .en_reg_pwm_15_8(en_reg_pwm_15_8),
  .pwm_duty_cycle(pwm_duty_cycle),  // Use data from SPI
  .spi_data_updated(spi_ready),
  .pwm_out(w_pwm_signal)
  );
  spi_peripheral spi_peripheral_inst(
    .clk(clk),
    .rst_n(rst_n),
    .SCLK(ui_in[0]), //
    .COPI(ui_in[1]),
    .CS_n(ui_in[2]),
    .CIPO(uo_out[0]),
    .reg_uo_en(en_reg_out_7_0),           // Address 0x00
    .reg_uio_en(en_reg_out_15_8),     // Address 0x01
    .reg_pwm_uo_sel(en_reg_pwm_7_0),  // Address 0x02
    .reg_pwm_uio_sel(en_reg_pwm_15_8),// Address 0x03
    .reg_pwm_duty(pwm_duty_cycle),     // Address 0x04
    .bitsTransferred(spi_data), // Bridge to PWM
    .bitCompleted(spi_ready)
  ); //create what needs to go into spiperipheral
  // All output pins must be assigned. If not used, assign to 0.
  
  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = (en_reg_pwm_15_8 & pwm_raw_outputs[15:8]) | (~en_reg_pwm_15_8 & en_reg_out_15_8);
  assign uio_oe  = 8'hFF;
  assign uo_out[7:1] = (en_reg_pwm_7_0[7:1]) ? pwm_raw_outputs[7:1] : en_reg_out_7_0[7:1];
  assign pwm_raw_outputs = {16{w_pwm_signal}};

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:3], uio_in, 1'b0,pwm_raw_outputs[0],spi_data};
    
endmodule
