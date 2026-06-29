class monitor ;
  mailbox #(transaction)mon2scb ;
  virtual intf.MON vif ;
  
  function new( virtual intf.MON vif , mailbox #(transaction)mon2scb);
    this.vif = vif ;
    this.mon2scb = mon2scb ;
  endfunction
  
  task main() ;
    transaction trans ;
    repeat(10)
      begin
        @(posedge vif.clk) ;
        
        
        trans = new() ;
        trans.rst = vif.rst ;
        trans.data = vif.data ;
        trans.q = vif.q ;
        
        mon2scb.put(trans) ;
        
        trans.display("Monitor class function");
      end
  endtask
endclass
