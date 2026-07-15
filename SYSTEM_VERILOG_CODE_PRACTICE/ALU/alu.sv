module alu_4bit (alu_intf intff) ;
 
  
  always_comb  begin
    
    case(intff.opcode)
      
      3'd0 : intff.result =  intff.a + intff.b ;
      3'd1 : intff.result =  intff.a - intff.b ;
      3'd2 : intff.result =  intff.a * intff.b ;
      3'd3 : intff.result =  intff.a & intff.b ;
     
      3'd4 : intff.result =  intff.a ^ intff.b ;
      3'd5: intff.result =  intff.a >> 1  ;
      3'd6 : intff.result =  intff.a << 1  ;
      
      default : intff.result =  8'd0  ;
    endcase
    
  end
  
  
  
endmodule
