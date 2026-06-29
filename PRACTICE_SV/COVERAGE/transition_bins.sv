module transition_bins ;
  logic [3:0] data ;
  logic [2:0] addr ;
  
  covergroup cg_transition_bins ;
    option.per_instance = 1 ;
    option.goal = 90 ;
    
    cp1 : coverpoint data{ bins b1 = (2 => 4); // single value transition
                          bins b2 = (3 => 5 => 7 => 9);//sequence of transition
                          bins b3[] = (2,3 => 4,5) ;//set of transition
                          bins b4 = (6[*3]) ;//consecutive bins
                          bins b5 = (7[*2:4]) ;}//range of repetition
    
    cp2 :coverpoint addr{ bins b1 = (2 => 5[=3] => 7);//non consecutive repetition bins
                         bins b2 = (2 => 5[->3] => 7); } // goto repetition
  endgroup
  
  cg_transition_bins cg_bins = new() ;
  
  initial begin
    repeat(100)begin
      #1 data = $random ;
      addr = $random ;
      cg_bins.sample() ;
      
      $display("data = %0d | addr = %0d | coverage = %0.2f%%",data ,addr,cg_bins.get_coverage());
      
    end
  end
endmodule
