module priority_encoder_assertion (priority_encoder_intf intff);
  
  always_comb begin
    
    if(intff.req == 4'b0000) begin
      assert((intff.grant == 2'b00) && !intff.valid )
        else $error("ASSERTION FAILED : no request");
    end
    
    if(intff.req[3])begin
      assert((intff.grant == 2'b11) && intff.valid)
        else $error("ASSERTION FAILED : req[3] priority");
      end
    
    if(!intff.req[3] && intff.req[2])begin
      assert((intff.grant == 2'b10 )&& intff.valid)
        else $error("ASSERTION FAILED : req[2] priority");
    end
    
    if(!intff.req[3] && !intff.req[2] && intff.req[1]) begin
      
      assert((intff.grant == 2'b01 ) && intff.valid)
        else $error("ASSERTION FAILED : req[1] priority");
    end
    
    if(!intff.req[3] && !intff.req[2] && !intff.req[1] && intff.req[0])begin
      assert((intff.grant == 2'b00) && intff.valid )
        else $error("ASSERTION FAILED : req[0] priority"); 
        end
    
     assert(!$isunknown(intff.grant))
        else
            $error("ASSERTION FAILED : Grant contains X");
    
    assert(!$isunknown(intff.valid))
        else
            $error("ASSERTION FAILED : Valid contains X");
    
    assert(intff.grant inside {2'b00,2'b01,2'b10,2'b11})
        else
            $error("ASSERTION FAILED : Illegal grant");
  end
  
endmodule
