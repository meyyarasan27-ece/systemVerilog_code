class scoreboard ;
  mailbox mon2scb ;
  
  function new(mailbox mon2scb) ;
    this.mon2scb = mon2scb ;
  endfunction
  
  task main() ;
    transaction trans ;
    repeat(8)
      begin
        mon2scb.get(trans);
        trans.display("scoreboard signals") ;
        
        if(((trans.a ^ trans.b ^ trans.c ) == trans.sum) &&
           ((( trans.a & trans.b) | 
             ( trans.b & trans.c) |
             ( trans.c & trans.a)) == trans.carry))
          $display("---PASS---");
        else 
          $display("---FAIL---");
        
       $display("---TRANSACTION DONE---");         
      end
  endtask
endclass
