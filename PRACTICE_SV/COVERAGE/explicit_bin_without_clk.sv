module cg_explicit_bin ;
  logic [3:0]addr ;
  logic [2:0]data ;
  logic en ;
  
  covergroup cg_explicit ;
    option.per_instance = 1;
    
    cp1 : coverpoint addr{bins b1 = {10,12,15} ;
                          bins b2 = {[2:10],12};}
    cp2 : coverpoint data{ bins b1 = {1,3,5} ;
                          bins b2 = {[6:$]};}
    cp3 : coverpoint en {bins b1 = {1} ;
                         bins b2 = {0};}
  endgroup
  
  cg_explicit cg = new() ;
  
  initial begin
    repeat(10)begin
      #1 addr = $random ;
      data = $random ;
      en = $random ;
      
      cg.sample() ;
      $display("addr = %0d | data = %0d | en = %0d | total coverage in percentage %0.2f%%",addr,data,en,cg.get_coverage());
    end
  end
endmodule
