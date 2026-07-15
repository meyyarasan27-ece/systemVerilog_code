module synchronous_fifo_assertion(synchronous_fifo_intf intff);


  property p_reset;
    @(posedge intff.clk)
    intff.reset |=> (intff.empty && !intff.full);
  endproperty

  assert property(p_reset)
    else $error("[ASSERT] Reset failed.");


  property p_no_write_when_full;
    @(posedge intff.clk)
    disable iff(intff.reset)
    (intff.full && intff.wr_enb) |=> $stable(intff.rd_data);
  endproperty

  assert property(p_no_write_when_full)
    else $error("[ASSERT] Write attempted while FIFO FULL.");


  property p_no_read_when_empty;
    @(posedge intff.clk)
    disable iff(intff.reset)
    (intff.empty && intff.rd_enb) |=> $stable(intff.rd_data);
  endproperty

  assert property(p_no_read_when_empty)
    else $error("[ASSERT] Read attempted while FIFO EMPTY.");


  property p_full_empty;
    @(posedge intff.clk)
    !(intff.full && intff.empty);
  endproperty

  assert property(p_full_empty)
    else $error("[ASSERT] FULL and EMPTY both HIGH.");


  property p_full_write;
    @(posedge intff.clk)
    disable iff(intff.reset)
    intff.full |-> !intff.wr_enb;
  endproperty

  assert property(p_full_write)
    else $error("[ASSERT] Write enable asserted while FULL.");


  property p_empty_read;
    @(posedge intff.clk)
    disable iff(intff.reset)
    intff.empty |-> !intff.rd_enb;
  endproperty

  assert property(p_empty_read)
    else $error("[ASSERT] Read enable asserted while EMPTY.");


  property p_no_unknown;
    @(posedge intff.clk)
    !$isunknown(intff.full) &&
    !$isunknown(intff.empty) &&
    !$isunknown(intff.rd_data);
  endproperty

  assert property(p_no_unknown)
    else $error("[ASSERT] Unknown value detected.");

endmodule
