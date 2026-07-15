module up_counter( counter_intf intf);
  
 
  always_ff @(posedge intf.clk )begin
    
    
    if(!intf.reset_n)
      begin
         intf.counter_out <= 4'd0 ;
         
      end
    else if(intf.en)
      
      intf.counter_out <=intf.counter_out + 1'b1 ;
   else
     intf.counter_out <=intf.counter_out ;
      
  end

  
endmodule

