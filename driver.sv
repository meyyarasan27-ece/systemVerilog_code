class driver;
  virtual intf vif ;
  mailbox gen2drv ;
  
  
  function new(virtual intf vif , mailbox gen2drv) ;
    this.vif = vif;
    this.gen2drv = gen2drv ;
  endfunction
  
  task main();
    repeat(8)
      begin
        transaction trans ;
        gen2drv.get(trans) ;
        vif.a <= trans.a ;
        vif.b <= trans.b ;
        vif.c <= trans.c ;
        
        #1 ;
        trans.display(" driver class signal") ;
      end
      
  endtask
endclass
