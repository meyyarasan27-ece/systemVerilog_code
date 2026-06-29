`include "environment.sv"

program test(intf intff);
  
  environment env ;
  
  initial begin
    
    env = new(intff) ;
    env.test_run() ;
    $display("Functional Verification Completed");
    $finish;
    
  end
  
endprogram
