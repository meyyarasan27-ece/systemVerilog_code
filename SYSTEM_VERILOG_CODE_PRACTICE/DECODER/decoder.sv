module decoder2_4(decoder_intf intff);
  
  always_comb begin
    
    if(!intff.enb)
      intff.data_out = 4'b0000 ;
    else
      intff.data_out = 4'b0001 << intff.data_in ;
    
  end
  
endmodule
