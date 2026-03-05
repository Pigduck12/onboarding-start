module spi_peripheral (
  input wire CS_n,
  input wire SS,
  input wire COPI,
  input wire SCLK,
  input wire clk,
  input wire rst_n,
  output wire CIPO,
  output reg[7:0] bitsTransferred,
  output reg bitCompleted
);
  reg[7:0] bitShifter;
  reg[2:0] bitcount;
  
  always @(posedge SCLK or posedge CS_n)begin //this starts 
    if (CS_n)begin //closed
      //reset values
      bitCompleted <= 1'b0;
      bitShifter <= 8'b0;
      bitcount <= 3'b0;
    end else begin //close
      bitShifter <= {bitShifter[6:0],COPI};
      if (bitcount == 3'b111) begin //close
        bitCompleted <= ~bitCompleted;
        bitsTransferred <= {bitShifter[6:0],COPI}; 
        bitcount <= 3'b0;
      end else begin //close
        bitCompleted <= 1'b0;
        bitcount <= bitcount + 1'b1;
    end
  end
  end
  endmodule
