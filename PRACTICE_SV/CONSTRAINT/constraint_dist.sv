class dist_class ;
  
  rand int value1 ;
  rand int value2 ;
  rand int value3 ;
  
  constraint const_name1{ value1 dist {1 := 4 , 0 := 7}; }
  constraint const_name2{ value2 dist{50 :/ 5 , [30:35] :/ 6 };}
  constraint const_name3{ value3 dist{2 := 5 , 5 :/ 4 , [3:8] :/ 8 , [7:9] :/9};}
  
endclass

module dist_keyword ;
  dist_class dist_handler ;
  
  initial begin
    dist_handler = new() ;
    repeat(10)begin
      assert(dist_handler.randomize()) else $fatal("RANDOMIZATION FAILED") ;
      $display("value1 = %0d | value2 = %0d | value3 = %0d",dist_handler.value1,dist_handler.value2,dist_handler.value3);
    end
  end
endmodule
