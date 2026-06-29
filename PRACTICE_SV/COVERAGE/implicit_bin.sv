module func_coverage_implicit_bin ;
  logic [3:0]addr ;
  logic [2:0]data ;
  logic en ;
  
  covergroup cg_name ;
    
    option.per_instance = 1 ;
    cp1 : coverpoint addr ;
    cp2 : coverpoint data ;
    cp3 : coverpoint en ;
    endgroup
  
  cg_name cg = new() ;
  
  initial begin
    repeat(30) begin
      #1 addr = $random ;
      data = $random ;
      en = $random ;
      
      cg.sample() ;
      
      $display("addr = %0d | data = %0d | en = %0d",addr ,data,en);
    end
  end
endmodule
