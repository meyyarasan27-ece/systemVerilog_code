`include "interface.sv"
`include "test.sv"

module d_ff_tb ;
  intf intff() ;
  test tst(intff) ;
  
  d_ff dut(intff) ;
  initial begin
    intff.clk = 0 ;
    forever #5 intff.clk = ~intff.clk ;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,d_ff_tb) ;
  end
  
endmodule
