class scoreboard ;
  mailbox #(transaction)mon2scb ;
  
  function new( mailbox #(transaction)mon2scb);
    this.mon2scb = mon2scb ;
  endfunction
  
  task main() ;
    transaction trans ;
    repeat(10)
      begin
        mon2scb.get(trans) ;
        
        if(!trans.rst)begin
          if(trans.q == 1'b0)
            $display("PASS: Reset is active, q = %0b", trans.q);
           else
             $display("FAIL: Reset is active, q = %0b (expected 0)", trans.q);
        end
        else begin
          if(trans.q == trans.data)
            $display("PASS :data = %0b, q = %0b", trans.data, trans.q);
          else 
             $display("FAIL: data = %0b, q = %0b", trans.data, trans.q);
        end
        trans.display("score class function");
      end
  endtask
endclass
