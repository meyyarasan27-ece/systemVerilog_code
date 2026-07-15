`include "assertion.sv"
interface synchronous_fifo_intf ;
  logic clk ;
  logic reset ;
  logic [7:0]wr_data ;
  logic wr_enb ;
  logic rd_enb ;
  logic [7:0]rd_data ;
  logic full ;
  logic empty ;
  
  
  
  clocking drv_clk @(posedge clk or negedge reset) ;
    
    default input #0 output #1step ; 
    output reset ;
    output wr_data ;
    output wr_enb ;
    output rd_enb ;
    
  endclocking
  
  
  clocking mon_clk @(posedge clk or negedge reset) ;
    
    default input #1step ;
    
    input reset ;
    input wr_data ;
    input wr_enb ;
    input rd_enb ;
    input rd_data  ;
    input full  ;
    input empty ;
    
  endclocking
  
  modport DRIVER (clocking drv_clk  );
  
  modport MONITOR ( clocking mon_clk  );
  
endinterface
    
    
class transaction ;
  
  rand logic reset ;
  rand logic [7:0]wr_data ;
  rand logic wr_enb ;
  rand logic rd_enb ;
       logic [7:0]rd_data ;
       logic full ;
       logic empty ;

constraint reset_constraint {
  reset dist {0 := 90,
              1 := 10};
}

constraint wr_data_constraint {
  wr_data inside {[0:255]};
}

constraint wr_enb_constraint {
  wr_enb dist {1 := 50,
               0 := 50};
}

constraint rd_enb_constraint {
  rd_enb dist {1 := 50,
               0 := 50};
}
  
  
  
  function void display(string name ) ;
    
    $display("[%s] reset = %0b | wr_enb = %0b | full = %0b | wr_data = %0d ",name,reset,wr_enb,full,wr_data) ;
    $display("[%s] reset = %0b |rd_enb = %0b | empty = %0b | rd_data = %0d ",name,reset,rd_enb,empty,rd_data);
    
  endfunction
  
endclass

    
class generator ;
  transaction trans ;
  mailbox #(transaction) gen2drv ;
  integer count = 40 ;
  
  function new(mailbox #(transaction) gen2drv ) ;
    
    this.gen2drv = gen2drv ;
    
  endfunction
  
  task generator_task() ;
    
    trans = new() ;
    trans.reset = 0 ;
    trans.wr_data = 8'b0 ;
    trans.wr_enb = 1 ;
    trans.rd_enb = 0;
    trans.display("GENERATOR");
    gen2drv.put(trans);
    
    repeat(count-1) begin
      
      trans = new() ;
      
      assert(trans.randomize()) 
        else $fatal("RANDOMIZATION FAILED");
      
      gen2drv.put(trans) ;
      
      trans.display("GENERATOR");
      $display("--------------------------------------");
      
    end
    
  endtask
  
endclass
    
    
class driver ;
  
  transaction trans ;
  mailbox #(transaction) gen2drv ;
  virtual synchronous_fifo_intf.DRIVER intff ;
  
  integer count = 40 ;
  
  function new(virtual synchronous_fifo_intf.DRIVER intff ,
               mailbox #(transaction) gen2drv  ) ;
    
    this.intff = intff ;
    this.gen2drv = gen2drv ;
    
  endfunction
  
  task driver_task() ;
    
    repeat(count) begin
      trans = new() ;
      
      gen2drv.get(trans) ;
      trans.display("DRIVER");
      intff.drv_clk.reset <= trans.reset ;
      intff.drv_clk.wr_data <= trans.wr_data ;
      intff.drv_clk.wr_enb <= trans.wr_enb ;
      intff.drv_clk.rd_enb <= trans.rd_enb ;
      
      @(intff.drv_clk);
      #1step ;
      
      
    end
  endtask
  
endclass
    
    
class coverage ;
  transaction trans ;
  
  covergroup cg ;
    option.auto_bin_max = 64 ;
    option.per_instance = 1;
    
    
    reset_cp : coverpoint trans.reset {
      bins b1 = {0,1} ;}
    
    wr_data_cp : coverpoint trans.wr_data{
      bins b1 = {[200:255]};
      bins b2 = {[100:149]};
      bins b3 = {[150:199]};
      bins b4 = {[1:99]};}
    
    wr_enb_cp :coverpoint trans.wr_enb {
      bins b1 = {0,1};}
    
    rd_enb_cp : coverpoint trans.rd_enb {
      bins b1 = {0,1};}
    
    rd_data_cp : coverpoint trans.rd_data {
      bins b1 = {[100:149]};
      bins b2 = {[200:255]};
      bins b3 = {[0:99]};
      bins b4 = {[100:199]};}
    
    full_cp : coverpoint trans.full{
      bins b1 = {0,1};}
    
    empty_cp : coverpoint trans.empty{
      bins b1 = {0,1};}
    
    cross_rd_wr_data : cross rd_data_cp , wr_data_cp ;
    cross_full_rd_data : cross rd_data_cp ,full_cp ;
    cross_full_wr_data : cross wr_data_cp ,full_cp ;
    
    cross_empty_rd_data : cross rd_data_cp ,empty_cp ;
    cross_empty_wr_data : cross wr_data_cp ,empty_cp ;
    
  endgroup
  
  function new() ;
    trans = new() ;
    cg  = new() ;
  endfunction
  
  task cg_task(transaction trans);
    
    this.trans = trans ;
    cg.sample() ;
    
  endtask
  
  function void cov_report();
    
    $display("the total coverage is %0.2f%%",cg.get_coverage()) ;
    
  endfunction
  
endclass
    
    
class monitor ;
  
  transaction trans ; 
  virtual synchronous_fifo_intf.MONITOR intff ;
  mailbox #(transaction) mon2scb ;
  coverage cov ;
  
  integer count = 40 ;
  
  function new(virtual synchronous_fifo_intf.MONITOR intff ,
               mailbox #(transaction) mon2scb,
               coverage cov ) ;
    this.intff = intff ;
    this.mon2scb = mon2scb ;
    this.cov = cov ;
    
  endfunction
  
  task monitor_task() ;
    
    repeat(count)begin
    
      @(intff.mon_clk) ;
      #1step ;
      trans = new() ;
      
  trans.reset =  intff.mon_clk.reset ;  
  trans.wr_data = intff.mon_clk.wr_data ;
  trans.wr_enb = intff.mon_clk.wr_enb ;
  trans.rd_enb = intff.mon_clk.rd_enb ;
  trans.rd_data = intff.mon_clk.rd_data ;
  trans.full    = intff.mon_clk.full ;
  trans.empty   = intff.mon_clk.empty; 
      
      mon2scb.put(trans);
      
      trans.display("MONITOR");
      cov.cg_task(trans);
    end
    
  endtask
  
endclass
    
    
class scoreboard;

  transaction trans;
  mailbox #(transaction) mon2scb;

  integer count = 40;

  // Reference FIFO
  logic [7:0] ref_fifo[$ :3];
  logic [7:0] expected_data;

  function new(mailbox #(transaction) mon2scb);
    this.mon2scb = mon2scb;
  endfunction

  task scoreboard_task();

    repeat(count) begin

      mon2scb.get(trans);
      trans.display("SCOREBOARD");
      //-------------------------------------------------
      // WRITE ONLY
      //-------------------------------------------------
      if((trans.wr_enb && !trans.full ) &&
         !(trans.rd_enb && !trans.empty)) begin

        ref_fifo.push_back(trans.wr_data);

        $display("[WRITE] Data Written = %0d",trans.wr_data);

      end

      //-------------------------------------------------
      // READ ONLY
      //-------------------------------------------------
      else if(trans.rd_enb && !trans.empty &&
              !(trans.wr_enb && !trans.full)) begin

        expected_data = ref_fifo.pop_front();

        if(expected_data == trans.rd_data)
          $display("[PASS] Expected=%0d DUT=%0d",
                    expected_data,trans.rd_data);
        else
          $display("[FAIL] Expected=%0d DUT=%0d",
                    expected_data,trans.rd_data);

      end

      //-------------------------------------------------
      // SIMULTANEOUS READ & WRITE
      //-------------------------------------------------
      else if(trans.wr_enb && !trans.full &&
              trans.rd_enb && !trans.empty) begin

        expected_data = ref_fifo.pop_front();

        if(expected_data == trans.rd_data)
          $display("[PASS] Expected=%0d DUT=%0d",
                    expected_data,trans.rd_data);
        else
          $display("[FAIL] Expected=%0d DUT=%0d",
                    expected_data,trans.rd_data);

        ref_fifo.push_back(trans.wr_data);

      end

      //-------------------------------------------------
      // WRITE WHEN FULL
      //-------------------------------------------------
      else if(trans.wr_enb && trans.full) begin

        $display("[INFO] Write attempted when FIFO FULL");

      end

      //-------------------------------------------------
      // READ WHEN EMPTY
      //-------------------------------------------------
      else if(trans.rd_enb && trans.empty) begin

        $display("[INFO] Read attempted when FIFO EMPTY");

      end

      //-------------------------------------------------
      // CHECK STATUS FLAGS
      //-------------------------------------------------

      if(ref_fifo.size()==0 && !trans.empty)
        $display("[FAIL] EMPTY flag mismatch");

      if(ref_fifo.size()!=0 && trans.empty)
        $display("[FAIL] EMPTY flag mismatch");

      if(ref_fifo.size()==4 && !trans.full)
        $display("[FAIL] FULL flag mismatch");

      if(ref_fifo.size()<4 && trans.full)
        $display("[FAIL] FULL flag mismatch");

      $display("------------------------------------------");

    end

  endtask

endclass
    
class env;

    virtual synchronous_fifo_intf intff;

    generator   gen;
    driver      drv;
    monitor     mon;
    scoreboard  scb;
    coverage    cov;

    mailbox #(transaction) gen2drv;
    mailbox #(transaction) mon2scb;

    function new(virtual synchronous_fifo_intf intff);
        this.intff = intff;
    endfunction

    task env_task();

        gen2drv = new();
        mon2scb = new();

        cov = new();

        gen = new(gen2drv);
        drv = new(intff, gen2drv);
        mon = new(intff, mon2scb, cov);
        scb = new(mon2scb);

        fork
            gen.generator_task();
            drv.driver_task();
            mon.monitor_task();
            scb.scoreboard_task();
        join

    endtask

endclass
      
class test;

    env envh;

    function new(virtual synchronous_fifo_intf intff);
        envh = new(intff);
    endfunction

    task run();

        envh.env_task();

        envh.cov.cov_report();

    endtask

endclass
      
module top;

    synchronous_fifo_intf intff();

    synchronous_fifo dut(intff);
    synchronous_fifo_assertion assertion_inst(intff);
    test t;


    initial begin
        intff.clk = 0;
        forever #5 intff.clk = ~intff.clk;
    end



    initial begin
      t = new(intff);
        t.run();
      $finish ;
    end


    

endmodule      
