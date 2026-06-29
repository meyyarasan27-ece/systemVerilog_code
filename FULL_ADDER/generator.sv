class generator ;
  transaction trans ;
  mailbox gen2drv ;
  
  function new(mailbox gen2drv) ;
    this.gen2drv = gen2drv ;
  endfunction
   
  task main() ;
    
    repeat(8)
      begin
        trans = new() ;
        trans.randomize() ;
        trans.display("generator class signals") ;
        gen2drv.put(trans) ;
      end
  endtask
endclass
