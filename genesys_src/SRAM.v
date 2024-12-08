// OpenRAM SRAM model
// Words: 8192
// Word size: 8

module SRAM_32x128_1rw(
`ifdef USE_POWER_PINS
    vdd,
    gnd,
`endif
// Port 0: W
    clk0,csb0,addr0,din0,
// Port 1: R
    clk1,csb1,addr1,dout1
  );

  parameter DATA_WIDTH = 8 ;
  parameter ADDR_WIDTH = 13 ;
  parameter RAM_DEPTH = 1 << ADDR_WIDTH;
  // FIXME: This delay is arbitrary.
  parameter DELAY = 0 ;
  parameter VERBOSE = 1 ; //Set to 0 to only display warnings
  parameter T_HOLD = 1 ; //Delay to hold dout value after posedge. Value is arbitrary
  
  parameter WRITE_WIDTH = 32;
  parameter WRITE_ADDR_WIDTH = 11;

`ifdef USE_POWER_PINS
    inout vdd;
    inout gnd;
`endif
  input  clk0; // clock
  input   csb0; // active low chip select
  input [WRITE_ADDR_WIDTH-1:0]  addr0;
  input [WRITE_WIDTH-1:0]  din0;
  input  clk1; // clock
  input   csb1; // active low chip select
  input [ADDR_WIDTH-1:0]  addr1;
  output [DATA_WIDTH-1:0] dout1;
 
  reg [WRITE_ADDR_WIDTH-1:0]  addr0_reg;
  reg [WRITE_WIDTH-1:0]  din0_reg;

  reg [DATA_WIDTH-1:0]    mem [0:RAM_DEPTH-1];

  reg  csb0_reg;

  // All inputs are registers
  always @(posedge clk0)
  begin
    csb0_reg = csb0;
    addr0_reg = addr0;
    din0_reg = din0;
    if ( !csb0_reg && VERBOSE )
      $display($time," Writing %m addr0=%b din0=%b",addr0_reg,din0_reg);
  end

  reg  csb1_reg;
  reg [ADDR_WIDTH-1:0]  addr1_reg;
  reg [DATA_WIDTH-1:0]  dout1;

  // All inputs are registers
  always @(posedge clk1)
  begin
    csb1_reg = csb1;
    addr1_reg = addr1;
    if (!csb0 && !csb1 && (addr0 == addr1))
         $display($time," WARNING: Writing and reading addr0=%b and addr1=%b simultaneously!",addr0,addr1);
    #(T_HOLD) dout1 = 8'bx;
    if ( !csb1_reg && VERBOSE ) 
      $display($time," Reading %m addr1=%b dout1=%b",addr1_reg,mem[addr1_reg]);
  end


  // Memory Write Block Port 0
  // Write Operation : When web0 = 0, csb0 = 0
  always @ (negedge clk0)
  begin : MEM_WRITE0
    if (!csb0_reg) begin
        mem[{addr0_reg, 2'b00}][7:0] = din0_reg[7:0];
        mem[{addr0_reg, 2'b01}][7:0] = din0_reg[15:8];
        mem[{addr0_reg, 2'b10}][7:0] = din0_reg[23:16];
        mem[{addr0_reg, 2'b11}][7:0] = din0_reg[31:24];
    end
  end

  // Memory Read Block Port 1
  // Read Operation : When web1 = 1, csb1 = 0
  always @ (negedge clk1)
  begin : MEM_READ1
    if (!csb1_reg)
       dout1 <= #(DELAY) mem[addr1_reg];
  end

endmodule