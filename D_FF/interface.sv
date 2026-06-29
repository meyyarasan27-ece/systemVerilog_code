interface intf;
  logic clk ;
  logic rst ;
  logic data ;
  logic q ;
  
  modport DUT ( input clk ,rst ,data , 
                output q);
  
  modport TB ( input q ,
               output clk ,rst ,data) ;
  
  modport MON ( input clk ,rst ,data ,q);
  
endinterface
