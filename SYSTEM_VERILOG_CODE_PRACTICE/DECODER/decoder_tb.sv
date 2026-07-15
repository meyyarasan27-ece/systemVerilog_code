interface decoder_intf ;
  logic enb ;
  logic [1:0] data_in ;
  logic [3:0] data_out ;
  
  modport DRIVER(output enb ,
                output data_in);
  
  modport MONITOR(input enb ,
                  input data_in ,
                  input data_out );
  
endinterface


class transaction ;
  
  rand logic enb ;
  rand logic [1:0] data_in ;
  logic  [3:0] data_out ;
  
  
  constraint enb_c{
    enb dist {0 := 10 , 
              1 := 90 } ;}
    
  constraint data_in_c {
    data_in inside {0,1,2,3};}
  
  function void display(string name);
    
    $display("[%s] enable = %0b | data_in = %0b | data_out = %0b",name,enb,data_in,data_out);
    
    
  endfunction
  
endclass

class generator ;
  
  transaction trans ;
  mailbox #(transaction) gen2drv ;
  
  integer count = 30 ;
  
  function new(mailbox #(transaction) gen2drv) ;
    
    this.gen2drv = gen2drv ;
    
  endfunction
  
  task generator_task() ;
    
    repeat(count)begin
      
      trans = new() ;
      
      assert(trans.randomize()) 
       else $fatal("RANDOMIZATION FAILED");
      
      gen2drv.put(trans);
      
      trans.display("GENERATOR TASK") ;
    end
    
  endtask
  
endclass


class driver ;
  
  transaction trans ;
  mailbox #(transaction) gen2drv ;
  virtual decoder_intf.DRIVER intff ;
  
  integer count = 30 ;
  
  function new(virtual decoder_intf.DRIVER intff,
              mailbox #(transaction) gen2drv);
    
    this.intff   = intff   ;
    this.gen2drv = gen2drv ;
    
  endfunction
  
  task driver_task();
    
    repeat(count) begin
      
      trans = new() ;
      
      gen2drv.get(trans);
      
      intff.enb      <= trans.enb ;
      intff.data_in <= trans.data_in ;
      #1;
      trans.display("DRIVER TASK");
     
    end
    
  endtask
  
endclass

class coverage ;
  
  transaction trans ;
  
  covergroup total_data_cg ;
    
    en_cp : coverpoint trans.enb {
      bins high = {1} ;
      bins low = {0};
    }
    
    data_in_cp : coverpoint trans.data_in{
      bins low_bits = {[0:1]};
      bins high_bits = {[2:3]};
      }
    
    data_out_cp : coverpoint trans.data_out {
      bins disabled = {4'b0000};
      bins out0 = {4'b0001};
      bins out1 = {4'b0010};
      bins out2 = {4'b0100};
      bins out3 = {4'b1000};
    }
    
    cross_enb_data_in : cross en_cp ,data_in_cp ;
    cross_en_out      : cross en_cp, data_out_cp;
    cross_in_out      : cross  data_in_cp ,data_out_cp ;
    
  endgroup 
  
  
  function new ();
    
    trans         = new() ;
    total_data_cg = new() ;
    
  endfunction
  
  task sample(transaction  trans) ;
    
    this.trans = trans ;
    total_data_cg.sample() ;

    
  endtask
  
  function void cov_report() ;
    
    $display("Total coverage %0.2f%%",total_data_cg.get_coverage());

  endfunction
    
  
endclass

class monitor ;
  
  transaction trans ;
  virtual decoder_intf.MONITOR intff ;
  mailbox #(transaction) mon2scb ;
  coverage cov ;
  
  integer count = 30 ;
  
  function new(virtual decoder_intf.MONITOR intff ,
               mailbox #(transaction) mon2scb , coverage cov);
    
    this.intff   = intff ;
    this.mon2scb = mon2scb ;
    this.cov = cov ;
    
  endfunction
  
  task monitor_task() ;
    
    repeat(count) begin
      #1;
      trans = new();
      
      trans.enb      =  intff.enb ;
      trans.data_in  = intff.data_in ;
      trans.data_out = intff.data_out ;
      
      mon2scb.put(trans);
      cov.sample(trans);
      
      trans.display("MONITOR TASK");
      
    end
      
  endtask
  
endclass


class scoreboard ;
  
  transaction trans ;
  mailbox #(transaction) mon2scb ;
  integer count = 30 ;
  logic [3:0]expected_out ;
  
  function new(mailbox #(transaction) mon2scb) ;
    this.mon2scb = mon2scb ;
  endfunction
  
  task scoreboard_task();
    repeat( count )begin
      
      mon2scb.get(trans);
      
      trans.display("SCOREBOARD TASK");
      
      if(!trans.enb)
        expected_out = 4'b0000 ;
      else 
        expected_out = 4'b0001 << trans.data_in ;
      
      
      if(expected_out == trans.data_out)begin
        
        $display("PASS : expected_out = %0b |  data_out  = %0b" ,expected_out,trans.data_out) ;
        $display("--------------------------");
      end
        
      else begin
        
        $display("FAIL : expected_out = %0b |  data_out  = %0b" ,expected_out,trans.data_out) ;
        
        $display("--------------------------");
      end
      
      
      
    end
    
  endtask
  
endclass

class env ;
  
  mailbox #(transaction) gen2drv ;
  mailbox #(transaction) mon2scb ;
  virtual decoder_intf intff ;
  
  generator gen ;
  driver drv ;
  monitor mon ;
  scoreboard scb ;
  coverage cov ;
  
  function new(virtual decoder_intf intff ) ;
    this.intff = intff ;
  endfunction
  
  task env_task() ;
    
    gen2drv = new() ;
    mon2scb = new() ;
    
    gen = new(gen2drv) ;
    drv = new(intff , gen2drv) ;
    cov = new() ;
    mon = new(intff , mon2scb,cov) ;
    scb = new(mon2scb) ;
    
    fork
      
      gen.generator_task() ;
      drv.driver_task() ;
      mon.monitor_task() ;
      scb.scoreboard_task() ;
      
    join
    
    
  endtask
  
endclass


class test ;
  
  env envh ;
  
  function new(virtual decoder_intf intff) ;
    envh = new(intff);
    
  endfunction
  
  task test_task() ;
    envh.env_task() ;
    envh.cov.cov_report() ;
  endtask
  
endclass


module top ;
  
  decoder_intf intff() ;
  
  decoder2_4 dut (intff);
  
  test t_class ;
  
  initial begin
    
    t_class = new(intff) ;
    t_class.test_task() ;
  end
  
endmodule
