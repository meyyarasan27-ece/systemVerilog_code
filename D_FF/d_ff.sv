module d_ff ( intf.DUT intff) ;
  
  always_ff @( posedge intff.clk or negedge intff.rst) 
    begin
      
      if(!intff.rst)
        intff.q <= 1'b0 ;
      else
        intff.q <= intff.data ;
    end
endmodule
