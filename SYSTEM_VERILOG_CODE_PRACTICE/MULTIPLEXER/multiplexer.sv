module mux_8_1 (mux_intf intff) ;
  
  always_comb begin
    case(intff.select_line)
      3'd0 : intff.data_out = intff.data_in[0] ;
      3'd1 : intff.data_out = intff.data_in[1] ;
      3'd2 : intff.data_out = intff.data_in[2] ;
      3'd3 : intff.data_out = intff.data_in[3] ;
      3'd4 : intff.data_out = intff.data_in[4] ;
      3'd5 : intff.data_out = intff.data_in[5] ;
      3'd6 : intff.data_out = intff.data_in[6] ;
      3'd7 : intff.data_out = intff.data_in[7] ;
      
      default : intff.data_out = 3'd0 ;
      
    endcase
  end
  
endmodule
