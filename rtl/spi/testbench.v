module spi_testbench
               #(parameter WIDTH=8,
                 parameter ct=$clog2(WIDTH))
                (input              reset_i,
                 input              clk_i,
                 input              spi_slave_enable_i,
                 input  [WIDTH-1:0] master_data_tx_i,
                 input  [WIDTH-1:0] slave_data_tx_i,
                 output             slave_data_enable_o,
                 output [WIDTH-1:0] master_data_rx_o,
                 output [WIDTH-1:0] slave_data_rx_o);
                 
                 
     spi_top dut(              reset_i,
                               clk_i,
                               spi_slave_enable_i,
                               master_data_tx_i,
                               slave_data_tx_i,
                               slave_data_enable_o,
                               master_data_rx_o,
                               slave_data_rx_o);
                 
                 
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1, spi_testbench);
    end
                 
                 
                 
endmodule

