module spi_slave_test #(parameter WIDTH = 8,
                   parameter ct    = $clog2(WIDTH))
                  (input                  reset_i,
                   input                  slave_enable_i,
                   input                  slave_sel_i,
                   input                  slave_clk_i,
                   input                  mosi_i,
                   input                  master_ready_i,
                   input      [WIDTH-1:0] data_tx_i,
                   output reg             miso_o,
                   output     [WIDTH-1:0] data_rx_o,
                   output                 slave_ready_o,
                   output                 slave_data_enable_o);
                   
                   
                   
                   
     spi_slave uut(                  reset_i,
                                     slave_enable_i,
                                     slave_sel_i,
                                     slave_clk_i,
                                     mosi_i,
                                     master_ready_i,
                                     data_tx_i,
                                     miso_o,
                                     data_rx_o,
                                     slave_ready_o,
                                     slave_data_enable_o);            
            
                   
    initial begin
        $dumpfile("slave_dump.vcd");
        $dumpvars(1, spi_slave_test);
    end
    
endmodule

