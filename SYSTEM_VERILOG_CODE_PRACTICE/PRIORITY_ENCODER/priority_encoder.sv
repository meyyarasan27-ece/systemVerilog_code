module priority_encoder(priority_encoder_intf intff);
  
  always_comb begin
    
    intff.grant = 2'b00 ;
    intff.valid = 1'b0 ;
    
    if(intff.req[3])begin
      
      intff.grant = 2'b11 ;
      intff.valid = 1'b1  ;
   
    end
    
    else if (intff.req[2]) begin
      
      intff.grant = 2'b10 ;
      intff.valid = 1'b1  ;
      
    end
    
    else if (intff.req[1]) begin
      
      intff.grant = 2'b01 ;
      intff.valid = 1'b1  ;
      
    end
    
    else if(intff.req[0]) begin
      
      intff.grant = 2'b00 ;
      intff.valid = 1'b1  ;
      
    end
    
    else begin
      
      intff.grant = 2'b00 ;
      intff.valid = 1'b0  ;
      
    end
    
  end
  
  
endmodule
