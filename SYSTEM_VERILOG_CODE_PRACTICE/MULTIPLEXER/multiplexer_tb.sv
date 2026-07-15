interface mux_intf ;
  
  logic [2:0]select_line ;
  logic [2:0]data_in[8] ;
  logic [2:0]data_out ;
  
  modport DRIVER (output select_line ,
                  output data_in);
  
  modport MONITOR (input select_line ,
                   input data_in , 
                   input data_out
                  );
endinterface


class transaction ;
  
  rand logic [2:0]select_line ;
  rand logic [2:0]data_in[8] ;
  logic [2:0] data_out ;
  
  constraint sel_const {
    select_line inside{[0:7]};
  }
  
  constraint inp_const {
    foreach(data_in[i])
      data_in[i] inside{[0:7]} ;
  }
  
  function void display(string name);
    
    $display("[%s] select_line = %0d ",name,select_line);
    
    foreach(data_in[i])
      $display("input data at data_in[%0d] = %0d",i,data_in[i]);
    
    $display("data_out = %0d",data_out);
    
  endfunction
  
  
endclass

class generator ;
  
  transaction trans ;
  mailbox #(transaction) gen2drv ;
  integer count = 10 ;
  
  
  function new(mailbox #(transaction)gen2drv);
    this.gen2drv = gen2drv ;
  endfunction
  
  task generator_task ();
    
    repeat(count) begin
      trans = new() ;
      
      assert(trans.randomize())
        else $fatal("RANDOMIZATION FAILED");
      
      gen2drv.put(trans) ;
      
      trans.display("GENERATOR");
    end
    
  endtask
  
endclass


class driver ;
  
  transaction trans ;
  virtual mux_intf.DRIVER intff ;
  mailbox #(transaction) gen2drv ;
  
  
  integer count = 10 ;
  
  function new(virtual mux_intf.DRIVER intff , mailbox #(transaction) gen2drv) ;
    
    this.intff = intff ;
    this.gen2drv = gen2drv ;
    
  endfunction
    
    task driver_task();
      
      repeat(count) begin
        trans = new() ;
        gen2drv.get(trans) ;
        
        intff.select_line <= trans.select_line ;
        
        foreach(trans.data_in[i])
          intff.data_in[i] <= trans.data_in[i];
        #1;
        trans.display("DRIVER");
      end
      
    endtask
  
endclass 

class coverage ;
  
  transaction trans ;
  
  /*covergroup data_cov (ref logic [2:0] data);
    option.per_instance = 1; 
    
    cp :coverpoint data{
      bins value[] = {[0:7]};}
    
  endgroup
 */ 
  
  covergroup data_inp ;
    
    option.per_instance = 1 ;
    
    cp1 : coverpoint trans.data_in[0] {
      bins b1[] = {[0:7]};}
    cp2 : coverpoint trans.data_in[1] {
      bins b1[] = {[0:7]};}
    cp3 : coverpoint trans.data_in[2] {
      bins b1[] = {[0:7]};}
    cp4 : coverpoint trans.data_in[3] {
      bins b1[] = {[0:7]};}
    cp5 : coverpoint trans.data_in[4] {
      bins b1[] = {[0:7]};}
    cp6 : coverpoint trans.data_in[5] {
      bins b1[] = {[0:7]};}
    cp7 : coverpoint trans.data_in[6] {
      bins b1[] = {[0:7]};}
    cp8 : coverpoint trans.data_in[7] {
      bins b1[] = {[0:7]};}
    
  endgroup
  
  covergroup sel_out_cov ;
     option.per_instance = 1;
    
    cp_sel_line :coverpoint trans.select_line{
      bins sel_line[] = {[0:7]} ; }
    
    cp_data_out : coverpoint trans.data_out{
      bins data_out1[]  = {[0:7]};}
    
    sel_out_cross : cross cp_sel_line ,cp_data_out ;
    
  endgroup
  
  //data_cov dcov[8] ;
  //data_inp dp ;
  //sel_out_cov soutc ;
  
  function new();
    
    trans = new() ;
    data_inp    = new() ;
    sel_out_cov = new() ;
    
/*    foreach(dcov[i])
      dcov[i] = new(trans.data_in[i]);
   */ 
    
  endfunction
 
  task sample(transaction trans);
    
    this.trans = trans ;
    data_inp.sample() ;
    sel_out_cov.sample() ;
    
   /* foreach(dcov[i])
      dcov[i].sample() ;
    */
  endtask
  
  
  function void report() ;
    real total ;
    
    total = sel_out_cov.get_coverage() ;
    
    $display("the data_in coverage is data_in = %0.2f%%",data_inp.get_coverage());
    $display("select/data_out coverage is %0.2f%%",total);
    
  endfunction
  
endclass

class monitor ;
  
  transaction trans ;
  virtual mux_intf.MONITOR intff ;
  mailbox #(transaction) mon2scb ;
 
  coverage cov ;
  integer count = 10 ;
  
    function new(virtual mux_intf.MONITOR intff , mailbox #(transaction) mon2scb , coverage cov);
    
    this.intff = intff ;
    this.mon2scb = mon2scb ;
    this.cov = cov ;
    
  endfunction
  
  task monitor_task() ;
    repeat(count) begin
      #1;
      trans = new() ;
      
      trans.select_line = intff.select_line ;
      
      foreach(intff.data_in[i])
        trans.data_in[i]     = intff.data_in[i] ;
      
      trans.data_out    = intff.data_out ;
      
      mon2scb.put(trans) ;
      cov.sample(trans);
      trans.display("MONITOR");
      
    end
  endtask
  
endclass
    
class scoreboard ;
  
  transaction trans ;
  mailbox #(transaction) mon2scb ;
  integer count = 10;
  logic [2:0]expected_data_out ;
  
  function new(mailbox #(transaction) mon2scb) ;
    this.mon2scb = mon2scb ;
  endfunction
  
  task scoreboard_task();
    
    repeat(count) begin
      mon2scb.get(trans) ;
      
      trans.display("SCOREBOARD");
      
      expected_data_out = trans.data_in[trans.select_line] ;
      
      if(expected_data_out == trans.data_out)
        $display("[PASS] : expected_data_out = %0d | data_out  = %0d",expected_data_out,trans.data_out);
      
      else
        $display("[FAIL] : expected_data_out = %0d | data_out  = %0d",expected_data_out,trans.data_out);
      
     
    end
    
  endtask
endclass
    
class env ;
  
  generator gen ;
  driver    drv ;
  monitor mon ;
  scoreboard scb ;
  coverage cov ;
  
  virtual mux_intf intff ;
  
  mailbox #(transaction) gen2drv ;
  mailbox #(transaction) mon2scb ;
  
  function new(virtual mux_intf intff);
    this.intff = intff ;
    
  endfunction
  
  task env_task() ;
    
    gen2drv = new() ;
    mon2scb = new() ;
    
    gen = new(gen2drv);
    drv = new(intff,gen2drv);
    cov = new();
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
  
  function new(virtual mux_intf intff);
    envh = new(intff);
  endfunction
  
  task run_test() ;
    envh.env_task();
    
    envh.cov.report();
  endtask
  
endclass
    
module mux_top ;
  
  test t ;
  
  mux_intf intff() ;
  
  mux_8_1 dut (intff);
  
  initial begin
    t = new(intff);
    t.run_test();
  end
endmodule
