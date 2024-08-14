#=========================================================================
# IntMulFL_test
#=========================================================================

import pytest

from random import randint

from pymtl3 import *
from pymtl3.stdlib.test_utils import mk_test_case_table, run_sim
from pymtl3.stdlib.stream import StreamSourceFL, StreamSinkFL
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------
def t(dut, table):
  print(table)
  
  dut.sim_reset()
  
  num_msgs = len(table.msgs)
  in_ind = 0
  out_ind = 0
  while (not (in_ind == num_msgs and out_ind == num_msgs)):
    if (not (in_ind == num_msgs)):
      dut.x @= table.msgs[in_ind][0]
      dut.x_val @= 1
      
      dut.y @= table.msgs[in_ind][1]
      dut.y_val @= 1
      in_ind = in_ind + 1
    if (dut.p_val): 
      assert (dut.p == table.msgs[out_ind][2])
      out_ind = out_ind + 1
    dut.sim_eval_combinational()
    dut.sim_tick()
    
  dut.sim_eval_combinational()
  dut.sim_tick()
  dut.sim_eval_combinational()
  dut.sim_tick()

#-------------------------------------------------------------------------
# mk_msg/mk_omsg
#-------------------------------------------------------------------------

# Make input message, truncate ints to ensure they fit in 32 bits.

def mk_msg( x, y , p):
  return [ [Bits9( x, trunc_int=True ), Bits15( y, trunc_int=True), Bits24( p, trunc_int=True )] ]

#----------------------------------------------------------------------
# Test Case: random small
#----------------------------------------------------------------------

random_small_msgs = []
for i in range(50):
  a = randint(0,100)
  b = randint(0,100)
  random_small_msgs.extend(mk_msg( a, b, a * b ))

#----------------------------------------------------------------------
# Test Case: random large
#----------------------------------------------------------------------

random_large_msgs = []
for i in range(50):
  a = (randint(-256,255))
  b = (randint(-16384,16383))
  random_large_msgs.extend([ mk_msg( a, b , a * b ) ])

#-------------------------------------------------------------------------
# Test Case Table
#-------------------------------------------------------------------------

test_case_table = mk_test_case_table([
  (                      "msgs                  "),
  [ "random_small",        random_small_msgs],
  # [ "random_large",        random_large_msgs,     0,        0         ],


  # ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

])
