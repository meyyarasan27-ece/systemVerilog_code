`define START_VALUE 14 
`define END_VALUE 20

class seq_item #(parameter int p1 = 4 , p2 = 10) ;
  rand bit [7:0] value1 ;
  rand bit [7:0] value2 ;
  rand bit [7:0] value3 ;
  rand bit [7:0] value4 ;
  rand bit [3:0] value5 ;
  rand bit [7:0] value6 ;
  rand bit [7:0] value7 ;
  
  constraint valu1_c {value1 inside {[10:20]} ;
                     }
  constraint value2_c{ value2 inside{10,20,25};
                     }
  constraint value3_c{value3 inside {[`START_VALUE:`END_VALUE]};
                     }
  constraint value4_c{ value4 inside{[10:20], 22 , 28 ,40} ;}
  constraint value5_c{ !(value5 inside {[5:15]}) ;}
  constraint value6_c{ value6 inside {p1,p2};}
  constraint value7_c{value7 inside{[p1:p2]};}

endclass
module const_ex ;
  
  seq_item ex ;
  initial begin 
    ex = new() ;
    repeat(5) begin
      assert (ex.randomize()) else $fatel("random value not generated") ;
      $display("value1 = %0d , value2 = %0d , value3 = %0d , value4 = %0d , value5 = %0d , value6 = %0d , value7 = %0d ",ex.value1 , ex.value2 , ex.value3 ,ex.value4 ,ex.value5 , ex.value6 , ex.value7);
    end
  end
endmodule
