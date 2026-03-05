module spi_peripheral (
  input wire CS_n,
  input wire COPI,
  input wire SCLK,
  input wire clk,
  input wire rst_n,
  output wire CIPO,
  output reg[7:0] bitsTransferred,
  output reg bitCompleted
);
  reg[15:0] bitShifter;
  reg[3:0] bitcount;
  reg sclk_prev; // To store the previous state of SCLK
  assign CIPO = bitShifter[7];
  always @(posedge clk or negedge rst_n)begin //this starts 
    if (!rst_n) begin
            // Total Hardware Reset
            bitcount     <= 4'b0;
            bitShifter   <= 8'b0;
            bitCompleted <= 1'b0;
            sclk_prev    <= 1'b0;
            bitsTransferred <= 8'b0; 
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
        case ()
          
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
