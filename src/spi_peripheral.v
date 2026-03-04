module spi_peripheral (
  input wire CS_n,
  input wire SS,
  input wire COPI,
  input wire SCLK,
  output wire CIPO,
  output reg[7:0] bitsTransferred,
  output reg bitsCompleted
);
  reg[7:0] bitShifter;
  reg[2:0] bitcount;
  always @(posedge SCLK or posedge CS_n)begin
    if (CS_n)begin
      //reset values
      bitsTransferred <= 8'b0;
      bitsCompleted <= 1'b0;
      bitShifter <= 8'b0;
      bitcount <= 3'b0;
    end else begin
      bitShifter <= {bitshifter[6:0],COPI};
      bitcount <= bitcount + 1'b1;
      if bitcount == 3'b111 begin
        bitsCompleted = 1'b1;
        bitsTransferred = 
      end else begin
        bitCompleted = 1'b0;
        bitcount <= bitcount +1'b1;
      
    end
  end
  end module
