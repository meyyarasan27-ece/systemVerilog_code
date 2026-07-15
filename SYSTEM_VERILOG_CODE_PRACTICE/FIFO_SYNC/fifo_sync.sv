module synchronous_fifo (synchronous_fifo_intf intff);

  logic [7 : 0]mem[0 : 3] ;
  logic [1 : 0]rd_ptr ,wr_ptr ;
  logic [2 : 0 ]count ;
  

  
  always_ff @(posedge intff.clk or negedge intff.reset)begin
    if(intff.reset)begin
      wr_ptr <= 0 ;
      
  end
  else begin
    if(intff.wr_enb && !intff.full)begin
      mem[wr_ptr] <= intff.wr_data ;
       wr_ptr <= wr_ptr + 1 ;
    end
  end
end


  always_ff @(posedge intff.clk or negedge intff.reset)begin
    if(intff.reset)begin
    rd_ptr <= 0 ;
    intff.rd_data <= 0 ;
  end
  else begin
    if(intff.rd_enb && !intff.empty)begin
      intff.rd_data <= mem[rd_ptr] ;
       rd_ptr <= rd_ptr + 1 ;
    end
  end
end
  always_ff @(posedge intff.clk or negedge intff.reset)begin
    if(intff.reset)begin
     count <= 0 ;
   end
    else if((intff.wr_enb && !intff.full ) && !(intff.rd_enb && !intff.empty))begin
      count <= count + 1 ;
   end
    else if((intff.rd_enb && !intff.empty) && !(intff.wr_enb && !intff.full))begin
      count <= count - 1 ;
   end
   else 
     count <= count ;
end
  assign intff.full = (count == 4);
  assign intff.empty = (count == 0);
  
endmodule
 
