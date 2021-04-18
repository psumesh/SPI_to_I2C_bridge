module spi_master_test #(parameter WIDTH = 8,
                   parameter ct = $clog2(WIDTH))
                  (input                  reset_i,
                   input                  master_clk_i,
                   input                  slave_ready_i,
                   input                  miso_i,
                   input      [WIDTH-1:0] data_tx_i,
                   output reg [WIDTH-1:0] data_rx_o,
                   output reg             mosi_o,
                   output                 slave_sel_o,
                   output                 sclk_o,
                   output reg             master_ready_o);
                   
      spi_master uut
                  (                  reset_i,
                                     master_clk_i,
                                     slave_ready_i,
                                     miso_i,
                                     data_tx_i,
                                     data_rx_o,
                                     mosi_o,
                                     slave_sel_o,
                                     sclk_o,
                                     master_ready_o)


    initial begin
        $dumpfile("master_dump.vcd");
        $dumpvars(1, spi_master_test);
    end
    
endmodule

