`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment ;
  generator gen ;
  driver drv ;
  monitor mon ;
  scoreboard scb ;
  
  mailbox gen2drv ;
  mailbox mon2scb ;
  virtual intf vif ;
  
  function new(virtual intf vif);
    this.vif = vif ;
    
    gen2drv = new() ;
    mon2scb = new() ;
    gen = new(gen2drv) ;
    drv = new(vif,gen2drv) ;
    mon = new(vif ,mon2scb) ;
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
  
