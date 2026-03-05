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
  always @(posedge clk or negedge rst_n)begin //this starts 
    if (!rst_n) begin
            // Total Hardware Reset
            bitcount     <= 4'b0;
            bitShifter   <= 16'b0;
            bitCompleted <= 1'b0;
            sclk_prev    <= 1'b0;
            bitsTransferred <= 8'b0; 
            reg_uo_en       <= 8'h00;
            reg_uio_en      <= 8'h00;
            reg_pwm_uo_sel  <= 8'h00;
            reg_pwm_uio_sel <= 8'h00;
            reg_pwm_duty    <= 8'h00;
    end else begin
      sclk_prev <= SCLK;
    if (CS_n)begin //closed
      bitcount     <= 4'b0;
      bitCompleted <= 1'b0;
    end else if (SCLK && !sclk_prev) begin 
      bitShifter <= {bitShifter[14:0],COPI};
        bitCompleted <= 1'b0;
        bitcount <= bitcount + 1'b1;
      if (bitcount == 4'd15) begin //close
        case (bitShifter[14:8])
            7'h00 : reg_uo_en <= {bitShifter[6:0],COPI}; 
            7'h01 : reg_uio_en <= {bitShifter[6:0],COPI};
            7'h02 : reg_pwm_uo_sel <= {bitShifter[6:0],COPI};
            7'h03 : reg_pwm_uio_sel <= {bitShifter[6:0],COPI};
            7'h04 : reg_pwm_duty <= {bitShifter[6:0],COPI};
            default : ;
        endcase
          
        bitCompleted <= 1'b1;
        bitsTransferred <= {bitShifter[6:0],COPI}; 
        bitcount <= 4'b0;
      end else begin //close
        bitCompleted <= 1'b0;
    end
  end
    end
  end
  endmodule
