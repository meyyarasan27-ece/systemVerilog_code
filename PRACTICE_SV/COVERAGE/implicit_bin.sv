module func_coverage_implicit_bin ;
  logic [3:0]addr ;
  logic [2:0]data ;
  logic en ;
  
  covergroup cg_name ;
    cp1 : coverpoint addr ;
    cp2 : coverpoint data ;
    cp3 : coverpoint en ;
    endgroup
  
  cg_name cg = new() ;
  initial begin
    addr = 4'd5;
    data = 3'd2;
    en   = 1;

    cg.sample();

    addr = 4'd10;
    data = 3'd6;
    en   = 0;

    cg.sample();
  end
endmodule
