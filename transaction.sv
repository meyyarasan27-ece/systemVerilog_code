class transaction ;
  rand bit a ;
  rand bit b ;
  rand bit c ;
       
       bit sum ;
       bit carry ;
  function void display(string name ) ;
    $display("_________%s________",name) ;
    $display("a = %b , b = %b , c = %b , sum = %b , carry = %b", a , b ,c , sum ,carry);
    $display("....................") ;
  endfunction
endclass
