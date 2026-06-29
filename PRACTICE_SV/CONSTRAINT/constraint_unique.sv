typedef enum {we , l ,s ,i}val ;
class unique_class ;
  rand bit [3:0] arr_s[5] ;
  rand bit [3:0] arr_d[] ;
  rand bit [7:0] arr_ass[] ;
  rand bit [2:0]value1 , value2 ,value3 ;
  
  val value ;
  
  constraint array_s{  unique {arr_s};}
  constraint array_d{ unique {arr_d} ;
                     arr_d.size() == 5 ;
                    }
  constraint array_ass{ unique {arr_ass};
                       arr_ass.size() == val.num ;}
  constraint val_c { unique{value1 , value2 ,value3} ;}
endclass
module unique_ex ;
  unique_class unq ;
  
  initial begin
    unq = new() ;
    assert(unq.randomize()) else $fatal("RANDOMIZATION FAILED");
    $display("---------------");
    $display("value1 = %0d | value2 = %0d | value3 = %0d ",unq.value1, unq.value2 , unq.value3);
     $display("---------------");
    foreach(unq.arr_s[i]) $display("arr_s[%0d] = %0d",i ,unq.arr_s[i]);
    $display("-------------------");
    foreach(unq.arr_d[i]) $display("arr_d[%0d] = %0d",i ,unq.arr_d[i]);
    $display("-------------------");
    foreach(unq.arr_ass[i]) $display("arr_ass[%0d] = %0d",i ,unq.arr_ass[i]);
    $display("-------------------");
    
  end
endmodule
