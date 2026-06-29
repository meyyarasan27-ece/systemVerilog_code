`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment ;
  mailbox #(transaction)gen2drv ;
  mailbox #(transaction)mon2scb ;
  generator gen ;
  driver drv ;
  monitor mon ;
  scoreboard scb ;
  
  virtual intf vif ;
  
  function new(virtual intf vif);
    this.vif = vif ;
    
    gen2drv = new() ;
    mon2scb = new() ;
    
    gen = new(gen2drv);
    drv = new(gen2drv,vif) ;
    mon = new(vif , mon2scb) ;
    scb = new(mon2scb);
    
  endfunction
  
  task test_run() ;
    fork
      gen.main() ;
      drv.main() ;
      mon.main() ;
      scb.main() ;
    join
    
  endtask
endclass
