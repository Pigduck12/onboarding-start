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
  reg[2:0] bitount;
  always @(posedge SCLK or posedge CS_n)begin
 
  end
