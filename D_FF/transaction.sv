class transaction ;
  rand bit rst ;
  rand bit data ;
       bit q ;

  
  function void display(string name);
    $display("-----%s------",name) ;
    $display("reset = %0b , data = %0b , q = %0b" ,rst,data,q) ;
    $display("----------------");
  endfunction
  
endclass
