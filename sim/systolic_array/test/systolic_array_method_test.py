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

from systolic_array.KernelCellX import KernelCellX
from systolic_array.KernelCellY import KernelCellY

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
def test_basic_x(cmdline_opts):
  dut = KernelCellX( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  len = 3
  window = np.arange(1, len * len + 1, dtype=int)
  window_2d = window.reshape(len, len)

  dut.sim_reset()
  t(dut, window_2d, xkernel)

def test_positive_x(cmdline_opts):
  dut = KernelCellX( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  len = 3
  window = np.array([0, 0, 255, 0, 0, 255, 0, 0, 255])
  window_2d = window.reshape(len, len)

  dut.sim_reset()
  t(dut, window_2d, xkernel)
  
def test_negative_x(cmdline_opts):
  dut = KernelCellX( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  len = 3
  window = np.array([255, 0, 0, 255, 0, 0, 255, 0, 0])
  window_2d = window.reshape(len, len)

  dut.sim_reset()
  t(dut, window_2d, xkernel)
  
def test_random_x(cmdline_opts):
  dut = KernelCellX( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  len = 3
  window = np.random.uniform(0, 255, size=(3, 50)).astype(int)
  window_2d = window

  dut.sim_reset()
  t(dut, window_2d, xkernel)

def test_directed_x(cmdline_opts):
  dut = KernelCellX( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  window_2d = np.array([[ 255,  255, 255,  255, 255],
                     [ 0,  0,  0,  0,  0],
                     [  255,  255, 255,  255, 255]])

  dut.sim_reset()
  t(dut, window_2d, xkernel)
  
# Inject output data into each of 3 ports and read rdy
def test_basic_y(cmdline_opts):
  dut = KernelCellY( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  len = 3
  window = np.arange(1, len * len + 1, dtype=int)
  window_2d = window.reshape(len, len)

  dut.sim_reset()
  t(dut, window_2d, ykernel)
  
def test_positive_y(cmdline_opts):
  dut = KernelCellY( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  len = 3
  window = np.array([0, 0, 0, 0, 0, 0, 255, 255, 255])
  window_2d = window.reshape(len, len)

  dut.sim_reset()
  t(dut, window_2d, ykernel)

def test_negative_y(cmdline_opts):
  dut = KernelCellY( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  len = 3
  window = np.array([255, 255, 255, 0, 0, 0, 0, 0, 0])
  window_2d = window.reshape(len, len)

  dut.sim_reset()
  t(dut, window_2d, ykernel)

def test_directed_x_2(cmdline_opts):
  dut = KernelCellY( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  len = 3
  window_2d = np.array([[ 19, 144,  54,   9, 116],
                        [ 11, 153, 188, 144, 111],
                        [203, 229,  82,  99,   4]])

  dut.sim_reset()
  t(dut, window_2d, ykernel)

def test_random_x(cmdline_opts):
  dut = KernelCellX( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  len = 3
  window = np.random.uniform(0, 255, size=(3, 15)).astype(int)
  window_2d = window

  dut.sim_reset()
  t(dut, window_2d, xkernel)

def test_random_y(cmdline_opts):
  dut = KernelCellY( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  len = 3
  window = np.random.uniform(0, 255, size=(3, 15)).astype(int)
  window_2d = window

  dut.sim_reset()
  t(dut, window_2d, ykernel)
