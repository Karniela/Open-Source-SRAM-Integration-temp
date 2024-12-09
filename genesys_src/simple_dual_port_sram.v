module simple_dual_port_sram #(
    parameter integer WRITE_WIDTH                   = 8,
    parameter integer READ_WIDTH                    = 8,
    parameter integer BUFFER_DEPTH                  = 128,
    parameter integer READ_LATENCY_B                = 1,
    parameter integer MEMORY_SIZE                   = 1024,
    parameter integer WRITE_ADDR_WIDTH              = 8,  
    parameter integer READ_ADDR_WIDTH               = 8
) (
      input                                         clka,
      input                                         rstb,
      input [WRITE_ADDR_WIDTH - 1 : 0]              addra,
      input [READ_ADDR_WIDTH - 1 : 0]               addrb,
      input [WRITE_WIDTH - 1 : 0]                   dina,
      input                                         ena,
      input                                         enb,
      input                                         regceb,
      input                                         wea,
      output                                        dbiterrb,
      output [READ_WIDTH - 1 : 0]                   doutb,
      output                                        sbiterrb
);
    wire                                            clkb;
    
    assign dbiterrb = 1'b0;
    assign sbiterrb = 1'b0;
    assign clkb     = 1'b0;
    
    SRAM_32x128_1rw #(
        .DATA_WIDTH(READ_WIDTH),      // Data width
        .ADDR_WIDTH(WRITE_ADDR_WIDTH), // Address width
        .RAM_DEPTH(MEMORY_SIZE/READ_WIDTH), // Depth based on memory size and data width
        .VERBOSE(1)                    // Verbose mode enabled
    ) sram_inst (
        `ifdef USE_POWER_PINS
        .vdd(1'b1),                    // Power pin (assume always powered)
        .gnd(1'b0),                    // Ground pin
        `endif
        .clk0(clka),                   // Write clock
        .csb0(~ena),            // Active low chip select for write
        .addr0(addra),                 // Write address
        .din0(dina),                   // Data input for write
        .clk1(clka),                   // Read clock (common clock for simplicity)
        .csb1(~enb),                   // Active low chip select for read
        .addr1(addrb),                 // Read address
        .dout1(doutb)                  // Data output for read
    );

endmodule

   // End of xpm_memory_sdpram_inst instantiation
				
				