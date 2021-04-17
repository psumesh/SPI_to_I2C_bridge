module spi_top #(parameter WIDTH=8,
                 parameter ct=$clog2(WIDTH))
                (input              reset_i,
                 input              clk_i,
                 input              spi_slave_enable_i,
                 input  [WIDTH-1:0] master_data_tx_i,
                 input  [WIDTH-1:0] slave_data_tx_i,
                 output             slave_data_enable_o,
                 output [WIDTH-1:0] master_data_rx_o,
                 output [WIDTH-1:0] slave_data_rx_o);
  

  wire slave_sel_w;
  wire slave_ready_w;
  wire sclk_w;
  wire mosi_w;
  wire miso_w;
  wire master_ready_w;

  spi_master #(.WIDTH(WIDTH)) master_device
  (
    .reset_i(reset_i),
    .master_clk_i(clk_i),
    .data_tx_i(master_data_tx_i),
    .data_rx_o(master_data_rx_o),
    .slave_sel_o(slave_sel_w),
    .slave_ready_i(slave_ready_w),
    .sclk_o(sclk_w),
    .mosi_o(mosi_w),
    .miso_i(miso_w),
    .master_ready_o(master_ready_w)
  );

  spi_slave #(.WIDTH(WIDTH)) slave_device
  (
    .reset_i(reset_i),
    .slave_enable_i(spi_slave_enable_i),
    .data_tx_i(slave_data_tx_i),
    .data_rx_o(slave_data_rx_o),
    .slave_data_enable_o(slave_data_enable_o),
    .slave_ready_o(slave_ready_w),
    .slave_sel_i(slave_sel_w),
    .slave_clk_i(sclk_w),
    .mosi_i(mosi_w),
    .miso_o(miso_w),
    .master_ready_i(master_ready_w)                                                
  );

endmodule
