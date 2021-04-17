module spi_slave #(parameter WIDTH = 8,
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
    
        
    reg [WIDTH-1:0] slave_tx_reg;
    reg [WIDTH-1:0] slave_rx_reg;
    
    reg [WIDTH-1:0] slave_tx_reg_tmp;
    reg [WIDTH-1:0] slave_rx_reg_tmp;
    
    reg [ct-1:0] count_rx;
    reg [ct-1:0] count_tx;
    
    wire sclk;
    
    parameter LOAD_RX=2'b00;
    parameter RECEIVE=2'b01;
    parameter WAIT_RX=2'b10;
    parameter REST_RX=2'b11;
    
    reg [1:0] ns_rx;
    
    parameter LOAD_TX=2'b00;
    parameter SEND=2'b01;
    parameter WAIT_TX=2'b10;
    parameter REST_TX=2'b11;
    
    reg [1:0] ns_tx;
    
    reg [3:0] data_ct;
    
    
    assign sclk                = (slave_sel_i == 1'b0) ? slave_clk_i : 1'b0;
    assign slave_ready_o       =  slave_enable_i;
    assign slave_data_enable_o = (data_ct == 4'b1011) ? 1'b1 : 1'b0;
    assign data_rx_o           = slave_rx_reg_tmp;
    
    
    always @(posedge sclk,negedge slave_enable_i) begin
         if(reset_i ==1'b1 || slave_enable_i ==1'b0) begin
              slave_tx_reg_tmp <= {ct{1'b0}};
              ns_rx            <= REST_RX;
         end
         
        else if(master_ready_i==1'b1) begin
             slave_tx_reg_tmp <= data_tx_i;  
            
             case(ns_rx)
                 LOAD_RX : begin
                           count_rx <= {ct{1'b0}};
                           ns_rx    <= RECEIVE;     
                 end
                 
                 RECEIVE : begin
                           slave_rx_reg <= {slave_rx_reg[WIDTH-2:0], mosi_i};
                           count_rx     <= count_rx+1;
                          
                           if(count_rx == {ct{1'b1}})
                                ns_rx <= WAIT_RX;

                           else
                                ns_rx <= RECEIVE;
                end
                
                WAIT_RX : begin
                           slave_rx_reg_tmp <= slave_rx_reg;
                           ns_rx            <= REST_RX;  
                end
                
                default : begin
                           count_rx <= {ct{1'b0}};
                           ns_rx    <= LOAD_RX;    
                end
            endcase
            
         end    
    end
 
    always @(negedge sclk, negedge slave_enable_i) begin
          if(reset_i == 1'b1 || slave_enable_i == 1'b0) begin
              data_ct      <= 4'b0000;
              slave_tx_reg <= {WIDTH{1'b0}};
              miso_o       <= 1'b0;
              ns_tx        <= REST_TX;
          end
          
          else if(master_ready_i == 1'b1) begin
               
               if(data_ct == 4'b1011)
                  data_ct <= 4'b0001;
               
               else
                  data_ct <= data_ct+1;
                
               case(ns_tx)
                SEND : begin
                       miso_o       <= slave_tx_reg[WIDTH-1];
                       slave_tx_reg <= {slave_tx_reg[WIDTH-2:0], slave_tx_reg[WIDTH-1]};
                       count_tx     <= count_tx+1;
                       
                       if(count_tx == {ct{1'b1}})
                             ns_tx <= WAIT_TX;
                            
                       else 
                             ns_tx <= SEND;
                end
                 
                WAIT_TX : begin
                          slave_tx_reg <= {WIDTH{1'b0}};
                          count_tx     <= {ct{1'b0}};
                          miso_o       <= 1'bZ;
                          ns_tx        <= LOAD_TX;
                end
                
                LOAD_TX : begin                          
                          slave_tx_reg <= {WIDTH{1'b0}};
                          count_tx     <= {ct{1'b0}};
                          miso_o       <= 1'bZ;
                          ns_tx        <= REST_TX;                             
                end
                
                default : begin                           
                          slave_tx_reg <= slave_tx_reg_tmp;
                          count_tx     <= {ct{1'b0}};
                            
                          if(ns_rx==LOAD_RX)
                               ns_tx <= SEND;
                          
                          else
                               ns_tx <= REST_TX;
                end
            endcase
        end
    end
      
endmodule

