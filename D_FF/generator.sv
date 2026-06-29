class generator ;
 
  transaction trans ;
  mailbox #(transaction)gen2drv ;
  
  function new(mailbox #(transaction)gen2drv);
    this.gen2drv = gen2drv ;
  endfunction
  
  task main() ;
    repeat(10)
      begin
        trans = new() ;
        assert (trans.randomize())else $error("Randomization failed") ;
        gen2drv.put(trans);
        trans.display("generator class function");
      end
  endtask
endclass
