`timescale 1ns/1ps

module spi_pro_tb;

    logic        clk;
    logic        rst_n;
    logic        start;
    logic [7:0]  tx_data;
    logic        miso;

    logic [7:0]  rx_data;
    logic        busy;
    logic        sclk;
    logic        mosi;
    logic        cs_n;


    spi_pro dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .tx_data (tx_data),
        .start   (start),
        .rx_data (rx_data),
        .busy    (busy),
        .sclk    (sclk),
        .mosi    (mosi),
        .miso    (miso),
        .cs_n    (cs_n)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    initial begin
        $dumpfile("spi_pro.vcd");
        $dumpvars(0, spi_pro_tb);
    end

    initial begin
        rst_n   = 0;
        start   = 0;
        tx_data = 8'h00;
        miso    = 0;

        #20;
        rst_n = 1;
    end


    initial begin

        @(posedge rst_n);

        tx_data = 8'b10110010;

        @(posedge clk);
        start = 1'b1;

        @(posedge clk);
        start = 1'b0;

    end


    initial begin

        @(negedge cs_n);

        miso = 1'b1; @(posedge sclk);
        miso = 1'b1; @(posedge sclk);
        miso = 1'b0; @(posedge sclk);
        miso = 1'b0; @(posedge sclk);
        miso = 1'b1; @(posedge sclk);
        miso = 1'b0; @(posedge sclk);
        miso = 1'b1; @(posedge sclk);
        miso = 1'b0; @(posedge sclk);

    end

    initial begin

      $monitor("%TIME = 0t | STATE =  %0d | CS = %0b |  SCLK =  %0b |  MOSI = %0b |   MISO = %0b | RX =  %0h",
                 $time,
                 dut.state,
                 cs_n,
                 sclk,
                 mosi,
                 miso,
                 rx_data);
    end

    initial begin

        #500;

        $display("--------------------------------");
        $display("Final RX_DATA = %b", rx_data);
        $display("--------------------------------");

        $finish;

    end

endmodule
