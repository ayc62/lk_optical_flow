#=========================================================================
# RegArray_test
#=========================================================================

import pytest

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_test_vector_sim
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

import numpy as np
from scipy.signal import convolve2d
import math

from systolic_array.KernelCellXWrapper import KernelCellXWrapper

def round_school(x):
    i, f = divmod(x, 1)
    return int(i + ((f >= 0.5) if (x > 0) else (f > 0.5)))

# Note: convolve 2d mirrors the matrix
# Example 3x3 kernel
xkernel = np.array([
    [ 3/32, 0, -3/32],
    [10/32, 0, -10/32],
    [ 3/32, 0, -3/32]
])

# Example 3x3 kernel
ykernel = np.array([
    [ 3/32,  10/32,  3/32],
    [    0,      0,     0],
    [-3/32, -10/32, -3/32]
])

# Helper function
def t( dut, matrix, kernel):
    
  result = convolve2d(matrix, kernel, mode='valid').flatten()
  ind_result = 0
  ind_mat = 0

  # Write input value to input port
  while(ind_result < len(result)):
    if (ind_mat == 0):
        dut.new_row @= 1
    else:
        dut.new_row @= 0
    if (ind_mat < len(matrix[0])):
      dut.x1 @= int(matrix[0][ind_mat])
      dut.x2 @= int(matrix[1][ind_mat])
      dut.x3 @= int(matrix[2][ind_mat])
        
      dut.x1_val @= 1
      dut.x2_val @= 1
      dut.x3_val @= 1
      ind_mat = ind_mat + 1
    else: 
      dut.x1_val @= 0
      dut.x2_val @= 0
      dut.x3_val @= 0
      
    if (dut.result_val):
      print(result[ind_result])
      assert (dut.result) == Bits9(round_school(result[ind_result]))
      ind_result = ind_result + 1
    dut.sim_eval_combinational()
    dut.sim_tick()
  dut.sim_eval_combinational()
  dut.sim_tick()
  dut.sim_eval_combinational()
  dut.sim_tick()

#-------------------------------------------------------------------------
# test
#-------------------------------------------------------------------------

# Inject output data into each of 3 ports and read rdy
def test_eval_basic_x(cmdline_opts):
  dut = KernelCellXWrapper()
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  dut.sim_reset()
  
  for i in range(17):
    window = np.random.uniform(0, 255, size=(3, 17)).astype(int)
    t(dut, window, xkernel)
