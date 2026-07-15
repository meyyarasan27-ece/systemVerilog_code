`include "assertion.sv"

interface priority_encoder_intf  ;
  
  logic [3:0] req ;
  logic [1:0] grant ;
  logic valid ;
  
  modport DRIVER( output req );
  
  modport MONITOR(input req ,
                 input grant ,
                 input valid) ;
  
endinterface


class transaction ;
  
  rand logic [3:0] req ;
  rand logic sel ;
  logic [1:0] grant ;
  logic valid ;
  
  
  constraint req_sel{sel dist {1 := 80 ,
                                      0 := 20};
                           }
  constraint req_constraint {
                             if(sel)
                               req inside {1,2,4,8} ;
                             else
                               !(req inside {1,2,4,8}) ;
                             }
  
  
  function void display(string name) ;
    
    $display("[%s] the value of request = %0b | grant = %b | valid = %0b ",name,req,grant,valid) ;
    
    
  endfunction
  
endclass


class generator ;
  
  transaction trans ;
  mailbox #(transaction) gen2drv ;
  integer count = 20 ;
  
  function new(mailbox #(transaction) gen2drv );
    this.gen2drv = gen2drv ;
  endfunction
  
  task generator_task();
    
    repeat(count) begin
      
      trans = new() ;
      
      assert(trans.randomize()) 
        else $fatal("RANDOMIZATION FAILED");
      
      gen2drv.put(trans);
      
      trans.display("GENERATOR");
      $display("---------------------------------------------------");
    end
    
  endtask
  
endclass


class driver ;
  
  transaction trans ;
  mailbox #(transaction) gen2drv ;
  virtual priority_encoder_intf.DRIVER intff ;
  
  integer count = 20 ;
  
  function new(virtual priority_encoder_intf.DRIVER intff ,
              mailbox #(transaction) gen2drv);
    
    this.intff = intff ;
    this.gen2drv = gen2drv ;
    
  endfunction
  
  task driver_task();
    
    repeat(count) begin
      
      trans = new() ;
      
      gen2drv.get(trans);
      
      intff.req <= trans.req ;
      #1 ;
      trans.display("DRIVER");
      
      
    end
    
  endtask
  
endclass


class coverage ;
  
  transaction trans ;
  
  covergroup cg ;
    
    option.per_instance = 1 ;
    
    req_cp : coverpoint trans.req {
      bins b1 = {0,1,2,4,8};}
    grant_cp : coverpoint trans.grant {
      bins b1 = {[0:3]} ;}
    valid_cp : coverpoint trans.valid {
      bins b1 = {0,1};}
    
    cross_req_grant : cross req_cp ,grant_cp ;
    cross_valid_req : cross valid_cp , req_cp ;
    
  endgroup
  
  function new();
    trans = new() ;
    cg = new() ;
  endfunction
  
  task sample(transaction trans) ;
    this.trans = trans ;
    cg.sample() ;
  endtask
  
  function void report_cg();
    
    $display("the total coverage %0.2f%%",cg.get_coverage());
    
  endfunction
  

endclass


class monitor ;
  
  transaction trans ;
  mailbox #(transaction) mon2scb ;
  virtual priority_encoder_intf.MONITOR intff ;
  coverage cov ;
  
  integer count = 20 ;
  
  function new(virtual priority_encoder_intf.MONITOR intff ,
               mailbox #(transaction) mon2scb ,
               coverage cov);
    
    this.intff = intff ;
    this.mon2scb = mon2scb ;
    this.cov = cov ;
    
  endfunction
  
  task monitor_task() ;
    
    repeat(count) begin
      #1 ;
      trans = new() ;
      
      trans.req   = intff.req   ;
      trans.grant = intff.grant ;
      trans.valid = intff.valid ;
      
      mon2scb.put(trans);
      cov.sample(trans);
      
      trans.display("MONITOR");
      
    end
    
  endtask
  
  
endclass


class scoreboard ;
  
  transaction trans ;
  mailbox #(transaction) mon2scb ;
  integer count = 20 ; 
  
  logic [1:0] expected_grant ;
  logic  expected_valid ;
  
  function new(mailbox #(transaction) mon2scb);
    
    this.mon2scb = mon2scb ;
    
  endfunction
  
  task scoreboard_task() ;
    
    repeat(count) begin
      trans = new() ;
      
      mon2scb.get(trans);
      trans.display("SCOREBOARD");
      
      if(trans.req[3])begin
        
        expected_grant = 2'b11 ;
        expected_valid = 1'b1  ;
        
      end
      else if(trans.req[2])begin
        
        expected_grant = 2'b10 ;
        expected_valid = 1'b1  ;
        
      end
      else if(trans.req[1])begin
        
        expected_grant = 2'b01 ;
        expected_valid = 1'b1  ;
        
      end
      else if(trans.req[0])begin
        
        expected_grant = 2'b00 ;
        expected_valid = 1'b1  ;
        
      end
      else begin
        
        expected_grant = 2'b00 ;
        expected_valid = 1'b0  ;
        
      end
      
      
      if(expected_grant == trans.grant && expected_valid == trans.valid) begin
        $display("[PASS] expected_grant = %0b | result_grant = %0b",expected_grant,trans.grant);
        $display("[PASS] expected_valid = %0b | result_valid = %0b",expected_valid,trans.valid);
        $display("-------------------------------------------------------");
      end
      else begin
        $display("[FAIL] expected_grant = %0b | result_grant = %0b",expected_grant,trans.grant);
        $display("[FAIL] expected_valid = %0b | result_valid = %0b",expected_valid,trans.valid);
        $display("-------------------------------------------------------");
        
      end
      
      
    end
    
  endtask
  
  
endclass


class env ;
  
  mailbox #(transaction) gen2drv ;
  mailbox #(transaction) mon2scb ;
  
  generator gen ;
  driver drv ;
  coverage cov ;
  monitor mon ;
  scoreboard scb ;
  
  virtual priority_encoder_intf intff ;
  
  function new( virtual priority_encoder_intf intff );
    
    this.intff = intff ;
    
  endfunction
  
  task env_task() ;
    
    gen2drv = new() ;
    mon2scb = new() ;
    
    gen = new(gen2drv) ;
    drv = new(intff , gen2drv) ;
    cov = new() ;
    mon = new(intff,mon2scb,cov) ;
    scb = new(mon2scb) ;
    
    fork 
      gen.generator_task();
      drv.driver_task() ;
      mon.monitor_task() ;
      scb.scoreboard_task() ;
    join
    
  endtask
endclass


class test ;
  
  env envh ;
  
  function new( virtual priority_encoder_intf intff ) ;
    envh = new(intff) ;
  endfunction
  
  task test_task() ;
    
    envh.env_task(); 
    envh.cov.report_cg();
  endtask
    
  
endclass


module priority_enc_tb ;
  
  test  t_handler ;
  
  priority_encoder_intf intff() ;
  priority_encoder dut(intff);
  priority_encoder_assertion assertion_inst(intff);
  
  initial begin
    
    t_handler = new(intff);
    t_handler.test_task() ;
    
  end
  
endmodule
