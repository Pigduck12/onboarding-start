module spi_peripheral (
  input wire CS_n,
  input wire COPI,
  input wire SCLK,
  input wire clk,
  input wire rst_n,
  output wire CIPO,
  output reg[7:0] bitsTransferred,
  output reg bitCompleted,
  output reg [7:0] reg_uo_en,       // Address 0x00
  output reg [7:0] reg_uio_en,      // Address 0x01
  output reg [7:0] reg_pwm_uo_sel,  // Address 0x02
  output reg [7:0] reg_pwm_uio_sel, // Address 0x03
  output reg [7:0] reg_pwm_duty   // Address 0x04
);
  reg[15:0] bitShifter;
  reg[3:0] bitcount;
  reg sclk_prev; // To store the previous state of SCLK
  assign CIPO = bitShifter[15];

always @(posedge clk or negedge rst_n) begin 
    if (!rst_n) begin
        // ... (Reset everything as you have it) ...
    end else begin
        sclk_prev <= SCLK;

        // 1. PRIMARY SPI LOGIC: Only shift if CS_n is LOW
        if (!CS_n) begin 
            if (SCLK && !sclk_prev) begin 
                bitShifter <= {bitShifter[14:0], COPI};
                bitcount   <= bitcount + 1'b1;

                if (bitcount == 4'd15) begin 
                    case (({bitShifter[14:0], COPI} >> 8) & 16'h007f) 
                        16'h0000 : reg_uo_en       <= {bitShifter[6:0], COPI}; 
                        16'h0001 : reg_uio_en      <= {bitShifter[6:0], COPI};
                        16'h0002 : reg_pwm_uo_sel  <= {bitShifter[6:0], COPI};
                        16'h0003 : reg_pwm_uio_sel <= {bitShifter[6:0], COPI};
                        16'h0004 : reg_pwm_duty    <= {bitShifter[6:0], COPI};
                    endcase
                    bitCompleted <= 1'b1;
                    bitcount     <= 4'b0;
                end else begin
                    bitCompleted <= 1'b0;
                end
            end
        end 
        
        // 2. IDLE/RESET LOGIC: Clear counters when CS_n is HIGH
        else begin 
            bitcount     <= 4'b0;
            bitCompleted <= 1'b0;
        end
    end // End of main else
end // End of always
endmodule
