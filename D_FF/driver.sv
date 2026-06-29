class driver ;
  mailbox #(transaction)gen2drv ;
  virtual intf.TB vif ;
  
  
  function new( mailbox #(transaction)gen2drv , virtual intf.TB vif);
    this.gen2drv = gen2drv ;
    this.vif = vif ;
  endfunction
  
  task main() ;
    transaction trans ;
    repeat(10)
      begin
       
        gen2drv.get(trans);
        vif.rst <= trans.rst ;
        vif.data <= trans.data ;
        
        trans.display(" driver class function");
        @(posedge vif.clk );
      end
  endtask
endclass
