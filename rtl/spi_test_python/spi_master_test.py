import cocotb
from random import randint
from cocotb.triggers import RisingEdge, Timer

@cocotb.coroutine
def clock(clk):
   while True:
      clk <= 1
      yield Timer(10, units='ns')
      clk <= 0
      yield Timer(10, units='ns')

@cocotb.coroutine     
async def reset_in(rst, units = 'ns'):
      rst <= 0
      await Timer(50, units)
      rst <= 1
      await Timer(60, units)
      rst <= 0

@cocotb.coroutine
async def slave_ready_fn(slave_ready_i):
      slave_ready_i <= 0
      await Timer(1000, units = 'ns')
      slave_ready_i <= 1

@cocotb.coroutine      
async def miso_fn(miso_i):
      miso_i <= randint(0, 1)

async def data_tx(data_tx_i):
      data_tx_i <= randint(0, 255)
      
      
@cocotb.test()
async def test(dut):
     
     cocotb.fork(clock(dut.master_clk_i))
     cocotb.fork(reset_in(dut.reset_i))
     cocotb.fork(slave_ready_fn(dut.slave_ready_i))
     
     for _ in range(800):
         await miso_fn(dut.miso_i)
         await data_tx(dut.data_tx_i)
         await Timer(60, units = 'ns')



