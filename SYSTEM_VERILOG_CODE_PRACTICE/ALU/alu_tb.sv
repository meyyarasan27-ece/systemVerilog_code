interface alu_intf ;
  
   logic [3:0] a ;
   logic [3:0] b ;
   logic [2:0] opcode ;
  
   logic [7:0]result ;
  
  modport DRIVER (  output a ,
                     output b ,
                     output opcode 
                 );
  
  modport MONITOR ( input a ,
                   input b ,
                   input opcode ,
                   input result 
                  );
  
   
endinterface


class transaction ;
  
  rand logic [3:0] a ;
  rand logic [3:0] b ;
  rand logic [2:0] opcode ;
       logic [7:0] result ;
  
  constraint a_const { a  inside { [8:15] } ;}
  constraint b_const { b  inside { [5:15] } ;}
  constraint op_const {opcode inside {[0:7]};}
  
  
  function void display(string name);
    
    $display("[%s] the value of a = %0d | b = %0d | opcode = %0b | result = %0d",name,a,b,opcode,result);
    
    
  endfunction 
  
endclass


class generator ;
  
  transaction trans ;
  mailbox #(transaction) gen2drv ;
  
  integer count =  100 ;
  
  function new(mailbox #(transaction) gen2drv);
    
    this.gen2drv = gen2drv ;
    
  endfunction
  
  task generator_task();
    
    repeat(count ) begin
      trans = new() ;
      assert(trans.randomize())
        else $fatal("RANDOMIZATION FAILED") ;
      
      gen2drv.put(trans);
      
      trans.display("GENERATOR");
      $display("-------------------------------------");
    end
    
  endtask
  
endclass


class driver ;
  
  transaction trans ;
  mailbox #(transaction) gen2drv ;
  virtual alu_intf.DRIVER intff ;
  
  integer count = 100 ;
  
  function new(virtual alu_intf.DRIVER intff ,
               mailbox #(transaction) gen2drv );
    
    this.intff = intff ;
    this.gen2drv = gen2drv ;
    
  endfunction
  
  task driver_task() ;
    
    repeat(count) begin
     
      trans = new() ;
      gen2drv.get(trans);
      
      intff.a     <= trans.a ;
      intff.b      <= trans.b ;
      intff.opcode <= trans.opcode ;
      #1 ;
      trans.display("DRIVER");
      
    end
    
  endtask
  
endclass


class coverage ;
  
  
  transaction trans ;
  
  covergroup cg ;
    option.auto_bin_max = 64 ;
    option.per_instance = 1 ;
    
    cp_a : coverpoint trans.a {
      bins b1 = {[10:15]};
      bins b2 = {[1:8]};}
    
    cp_b : coverpoint trans.b{
      bins b1 = {[4:9],3,2};
      bins b2 = {[11:15]};}
    
    cp_opcode : coverpoint trans.opcode {
      bins b1 = {[0:7]}; }
    
    cp_result : coverpoint trans.result{
      bins b1 = {15,18,6,[200:225],150,157};
      bins b2 = {[150:199] , [100:149]}; 
      bins b3 = {[0:50]};
      bins b4 = {[55:90]}; }
    
    cross_a_b : cross cp_a , cp_b ;
    cross_op_res : cross cp_result,cp_opcode ;
    
  endgroup
  
  
  function new();
    trans = new() ;
    cg    = new() ;
  endfunction
  
  task sample(transaction trans) ;
    
    this.trans = trans ;
    cg.sample();
    
  endtask
  
  function void report_cg();
    
    $display("the total coverage is %0.2f%%",cg.get_coverage()) ;
    
  endfunction
  
  
endclass

class monitor ;
  
  transaction trans ;
  mailbox #(transaction) mon2scb ;
  virtual alu_intf.MONITOR intff ;
  coverage cov ;
  
  integer count = 100 ;
  
  function new( virtual alu_intf.MONITOR intff ,
               mailbox #(transaction) mon2scb  ,
               coverage cov);
    
    this.intff = intff ;
    this.mon2scb = mon2scb ;
    this.cov = cov ;
    
  endfunction
  
  task monitor_task() ;
    
    repeat(count) begin
      #1 ;
      trans = new() ;
      
      trans.a = intff.a ;
      trans.b = intff.b ;
      trans.opcode = intff.opcode ;
      trans.result = intff.result ;
      
      mon2scb.put(trans) ;
      
      cov.sample(trans);
      trans.display("MONITOR");
      
    end
    
  endtask
  
endclass



class scoreboard ;
  
  transaction trans ;
  mailbox #(transaction) mon2scb ;
  
  integer count = 100 ;
  logic [7:0]expected_res ;
  
  function new(mailbox #(transaction) mon2scb );
    
    this.mon2scb = mon2scb ;
    
  endfunction
  
  
  task scoreboard_task() ;
    
    repeat(count) begin
      trans = new() ;
      mon2scb.get(trans);
      
      
      case(trans.opcode)
        3'b000 : expected_res =  trans.a + trans.b ;
        3'b001 : expected_res =  trans.a - trans.b ;
        3'b010 : expected_res =  trans.a * trans.b ;
        3'b011 : expected_res =  trans.a & trans.b ;

        3'b100 :expected_res =  trans.a ^ trans.b ;
        3'b101 : expected_res =  trans.a >> 1  ;
        3'b110 : expected_res =  trans.a << 1  ;
      
      default : expected_res =  8'd0  ;
        
      endcase
      
      trans.display("SCOREBOARD");
      if(expected_res == trans.result) begin
        
        $display("[PASS] Expected result = %0d | result = %0d",expected_res,trans.result);
        $display("--------------------------------------");
      end
      else  begin
        
        $display("[FAIL] Expected result = %0d | result = %0d",expected_res,trans.result);
        $display("--------------------------------------");
        
      end
    //  trans.display("SCOREBOARD");
      
    end
    
  endtask
  
endclass


class env ;
  
  mailbox #(transaction) gen2drv ;
  mailbox #(transaction) mon2scb ;
  virtual alu_intf intff ;
  
  generator gen ;
  driver drv ;
  coverage cov ;
  monitor mon ;
  scoreboard scb ;
  
  function new(virtual alu_intf intff); 
    
    this.intff = intff ;
    
  endfunction
  
  task env_task();
    gen2drv = new() ;
    mon2scb = new() ;
    
    gen = new(gen2drv) ;
    drv = new(intff , gen2drv);
    cov = new();
    mon = new(intff , mon2scb ,cov);
    scb = new(mon2scb);
    
    fork 
      gen.generator_task();
      drv.driver_task();
      mon.monitor_task();
      scb.scoreboard_task() ;
    join
    
  endtask
endclass


class test ;
  
  env envh ;
  
  function new (virtual alu_intf intff);
    
    envh = new(intff);
    
  endfunction
  
  task test_task() ;
    
    envh.env_task();
    envh.cov.report_cg() ;
    
  endtask
  
endclass


module alu_tb ;
  
  test t_class ;
  
  alu_intf intff() ;
  
  alu_4bit dut(intff);
  
  
  initial begin
    
    t_class = new(intff) ;
    t_class.test_task() ;
    
  end
  
  
endmodule
