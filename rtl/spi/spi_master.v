module spi_master #(parameter WIDTH = 8,
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
  
  
 
  reg [WIDTH-1:0] master_tx_reg;
  reg [WIDTH-1:0] master_rx_reg;
  reg [WIDTH-1:0] master_tx_reg_tmp;
  reg [WIDTH-1:0] master_rx_reg_tmp;

  parameter LOAD_RX=2'b00;
  parameter RECEIVE=2'b01;
  parameter WAIT_RX=2'b10;
  parameter REST_RX=2'b11;
  
  reg [1:0] ns_rx;

  parameter LOAD_TX=2'b00;
  parameter SEND   =2'b01;
  parameter WAIT_TX=2'b10;
  parameter REST_TX=2'b11;
  
  reg [1:0] ns_tx; 

  reg [ct-1:0]count_rx;
  reg [ct-1:0]count_tx;
  
  assign slave_sel_o = ({slave_ready_i,reset_i}==2'b10) ? 1'b0         : 1'b1;
  assign sclk_o      = ({slave_ready_i,reset_i}==2'b10) ? master_clk_i : 1'b0;


  always @(posedge master_clk_i) begin
       if(reset_i) begin
         master_tx_reg_tmp <= {WIDTH{1'b0}};  
         data_rx_o         <= {WIDTH{1'b0}};
         ns_rx             <= REST_RX;
       end
       
       else if(slave_ready_i) begin
            master_tx_reg_tmp <= data_tx_i;  // data sample //
            data_rx_o         <= master_rx_reg_tmp; 
            
            case(ns_rx)
               REST_RX: begin 
                        count_rx          <= {ct{1'b0}};
                        master_rx_reg_tmp <= {WIDTH{1'b0}};
                        ns_rx             <= LOAD_RX;
               end
               
               RECEIVE: begin
                        master_rx_reg <= {master_rx_reg[WIDTH-2:0],miso_i};
                        count_rx      <= count_rx + 1;
                        
                        if(count_rx == {ct{1'b1}})
                              ns_rx <= WAIT_RX;
                        else
                              ns_rx <= RECEIVE;
               end
               
               WAIT_RX: begin
                        master_rx_reg_tmp <= master_rx_reg;
                        ns_rx             <= REST_RX;    
               end
               
               LOAD_RX: begin                        
                        count_rx          <= {ct{1'b0}};
                        master_rx_reg_tmp <= {WIDTH{1'b0}};
                        ns_rx             <= RECEIVE;
               end
               
               default: begin 
                        count_rx          <= {ct{1'b0}};
                        master_rx_reg_tmp <= {WIDTH{1'b0}};
                        ns_rx             <= LOAD_RX;
               end
           endcase     
        end
        
       else begin
            master_tx_reg_tmp <= {WIDTH{1'b0}};
            data_rx_o         <= {WIDTH{1'b0}};
            ns_rx             <= REST_RX;
       end
  end



/*
---------------------------------------TX----------------------------------------------------
*/



  always @(negedge master_clk_i) begin
        if(reset_i) begin
              master_tx_reg  <= {WIDTH{1'b0}};
              master_ready_o <= 1'b0;
              mosi_o         <= 1'b0;  
              ns_tx          <= REST_TX;
        end
        
        else if(slave_ready_i) begin
             master_ready_o <= 1'b1;
      
             case(ns_tx) 
             REST_TX: begin
                     master_tx_reg <= master_tx_reg_tmp;
                     count_tx      <= {ct{1'b0}};
                     mosi_o        <= 1'b0;
                   
                     if(ns_rx == LOAD_RX)
                        ns_tx <= SEND;
                     
                     else
                        ns_tx <= REST_TX;
             end
               
             SEND: begin
                   mosi_o        <= master_tx_reg[WIDTH-1];
                   master_tx_reg <= {master_tx_reg[WIDTH-2:0], master_tx_reg[WIDTH-1]};
                   count_tx      <= count_tx + 1;
                   
                   if(count_tx == {ct{1'b1}})
                      ns_tx <= WAIT_TX;
                   
                   else
                     ns_tx <= SEND;
             end
             
             WAIT_TX: begin
                     master_tx_reg <= {WIDTH{1'b0}};
                     count_tx      <= {ct{1'b0}};
                     mosi_o        <= 1'bZ;
                     ns_tx         <= LOAD_TX;
             end
             
             LOAD_TX: begin
                     master_tx_reg <= {WIDTH{1'b0}};
                     count_tx      <= {ct{1'b0}};
                     mosi_o        <= 1'bZ;
                     ns_tx         <= REST_TX;    
             end
             
             default: begin
                     master_tx_reg <= master_tx_reg_tmp;
                     count_tx      <= {ct{1'b0}};
                     mosi_o        <= 1'b0;
                   
                     if(ns_rx == LOAD_RX)
                        ns_tx <= SEND;
                     
                     else
                        ns_tx <= REST_TX;
             end
          endcase
      end
      
      else begin
          master_tx_reg  <= {WIDTH{1'b0}};
          master_ready_o <= 1'b0;
          mosi_o         <= 1'b0;
          ns_tx          <= REST_TX;
      end  
  end  
  
endmodule
