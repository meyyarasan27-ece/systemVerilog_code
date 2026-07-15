interface counter_intf;

    logic clk;
    logic reset_n;
    logic en;
    logic [3:0] counter_out;

    // Driver Clocking Block
  clocking drv_clk @(posedge clk);
        default input #0 output #1step;
        output reset_n;
        output en;
    endclocking

    // Monitor Clocking Block
  clocking mon_clk @(posedge clk);
        default input #1step;
        input reset_n;
        input en;
        input counter_out;
    endclocking

    modport DRIVER  (clocking drv_clk);
    modport MONITOR (clocking mon_clk);

endinterface
      
      
class transaction;

    rand logic reset_n;
    rand logic en;

    logic [3:0] counter_out;

    constraint reset_c {
        reset_n dist {
            0 := 10,
            1 := 90
        };
    }

    constraint en_c {
        en dist {
            0 := 1,
            1 := 99
        };
    }

    function void display(string name);
        $display("[%s] reset=%0b enable=%0b count=%0d",
                 name, reset_n, en, counter_out);
    endfunction

endclass
      
      
class generator;

    mailbox #(transaction) gen2drv;

    transaction trans;

    int count = 20;

    function new(mailbox #(transaction) gen2drv);
        this.gen2drv = gen2drv;
    endfunction

    task generator_task();

        trans = new();
        trans.reset_n = 0;
        trans.en      = 0;

        trans.display("GENERATOR");
        gen2drv.put(trans);

      repeat(count-1) begin

            trans = new();

            assert(trans.randomize())
            else
                $fatal(1,"Randomization Failed");

            trans.display("GENERATOR");

            gen2drv.put(trans);

        end

    endtask

endclass
      
class driver;

    virtual counter_intf.DRIVER intff;

    mailbox #(transaction) gen2drv;

    transaction trans;

    int count = 20;

    function new(
        virtual counter_intf.DRIVER intff,
        mailbox #(transaction) gen2drv
    );

        this.intff = intff;
        this.gen2drv = gen2drv;

    endfunction

    task driver_task();

        repeat(count) begin

            gen2drv.get(trans);

            intff.drv_clk.reset_n <= trans.reset_n;
            intff.drv_clk.en      <= trans.en;
           
            @(intff.drv_clk);
          
            #1step;
            trans.display("DRIVER");
            

        end

    endtask

endclass
      
class coverage;

    transaction trans;

    covergroup cg;

        option.per_instance = 1;

        rst_cp : coverpoint trans.reset_n {
            bins reset  = {0};
            bins normal = {1};
        }

        en_cp : coverpoint trans.en {
            bins disable_value = {0};
            bins enable  = {1};
        }

        counter_cp : coverpoint trans.counter_out {
            bins zero   = {0};
            bins others = {[1:15]};
        }

        reset_en_cross : cross rst_cp, en_cp;

    endgroup

    function new();
        trans = new();
        cg = new();
    endfunction

    task sample(transaction trans);
        this.trans = trans;
        cg.sample();
    endtask

    function void report();
        $display("\nCoverage = %0.2f %%", cg.get_coverage());
    endfunction

endclass      
      
class monitor;

    virtual counter_intf.MONITOR intff;

    mailbox #(transaction) mon2scb;

    transaction trans;

    coverage cov;

    int count = 20;

    function new(
        virtual counter_intf.MONITOR intff,
        mailbox #(transaction) mon2scb,
        coverage cov
    );
        this.intff   = intff;
        this.mon2scb = mon2scb;
        this.cov     = cov;
    endfunction

    task monitor_task();

        repeat(count) begin

            @(intff.mon_clk);
          #1step ;

            trans = new();

            trans.reset_n     = intff.mon_clk.reset_n;
            trans.en          = intff.mon_clk.en;
            trans.counter_out = intff.mon_clk.counter_out;

            trans.display("MONITOR");

            cov.sample(trans);

            mon2scb.put(trans);

        end

    endtask

endclass
      
class scoreboard;

    mailbox #(transaction) mon2scb;

    transaction trans;

    logic [3:0] expected_count;

    int count = 20;

    function new(mailbox #(transaction) mon2scb);

        this.mon2scb = mon2scb;

        expected_count = 0;

    endfunction

    task scoreboard_task();

        repeat(count) begin

            mon2scb.get(trans);

            trans.display("SCOREBOARD");


            if (trans.counter_out == expected_count)
                $display("PASS : Expected=%0d Actual=%0d",
                         expected_count, trans.counter_out);
            else
                $display("FAIL : Expected=%0d Actual=%0d",
                         expected_count, trans.counter_out);

            $display("--------------------------------");



            if (!trans.reset_n)
                expected_count = 0;
            else if (trans.en)
                expected_count++;


        end

    endtask

endclass
      
class env;

    virtual counter_intf intff;

    generator   gen;
    driver      drv;
    monitor     mon;
    scoreboard  scb;
    coverage    cov;

    mailbox #(transaction) gen2drv;
    mailbox #(transaction) mon2scb;

    function new(virtual counter_intf intff);
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

    function new(virtual counter_intf intff);
        envh = new(intff);
    endfunction

    task run();

        envh.env_task();

        envh.cov.report();

    endtask

endclass
      
module top;

    counter_intf intf();

    up_counter dut(intf);

    test t;

    initial begin
        intf.clk = 0;
        forever #5 intf.clk = ~intf.clk;
    end


    initial begin
        intf.reset_n = 0;
        intf.en      = 0;
    end


    initial begin
        t = new(intf);
        t.run();
      $finish ;
    end


endmodule      
