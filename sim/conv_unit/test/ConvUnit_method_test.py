#=========================================================================
# RegArray_test
#=========================================================================

import pytest

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_test_vector_sim
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts
from scipy.signal import convolve2d
import math
import numpy as np

from conv_unit.ConvUnit import ConvUnit


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

def enqueue(dut, window_2d, row_counter, col_counter, win_dim_plus):
  dut.pix @= int(window_2d[row_counter][col_counter])
  dut.pix_val @= 1
  col_counter = (col_counter + 1) % win_dim_plus
  if (col_counter == 0): row_counter = row_counter + 1
  return row_counter, col_counter

def stall(dut):
  dut.pix_val @= 0

# Helper function
def t( dut, window_2d, win_dim_plus, win_dim, random_delay):
  
  Ix = convolve2d(window_2d, xkernel, mode='valid').flatten()
  Iy = convolve2d(window_2d, ykernel, mode='valid').flatten()
  num_results = win_dim * win_dim
  
  Ix_result_counter = 0
  Iy_result_counter = 0
  row = 0
  col = 0
  deq_col = 0
  deq_row = 0
  is_deq = False

  # Write input value to input port
  while (Ix_result_counter != num_results and Iy_result_counter != num_results):
    
    random_number = np.random.rand()
    dut.win_dim @= win_dim_plus-2
    if (((random_number > 0.6) or (not random_delay)) and (row < win_dim_plus and col < win_dim_plus)):
      row, col = enqueue(dut, window_2d, row, col, win_dim_plus)
      if (row > 2 and col == 0): is_deq = True
    else: 
      stall(dut)
    
    if (dut.Ix_val): 
      assert dut.Ix == Bits9(round_school(Ix[Ix_result_counter]))
      Ix_result_counter = Ix_result_counter + 1
    if (dut.Iy_val): 
      assert dut.Iy == Bits9(round_school(Iy[Iy_result_counter]))
      Iy_result_counter = Iy_result_counter + 1
    dut.sim_eval_combinational()
    dut.sim_tick()
    
  dut.sim_eval_combinational()
  dut.sim_tick()
  dut.sim_eval_combinational()
  dut.sim_tick()

#-------------------------------------------------------------------------
# test
#-------------------------------------------------------------------------

# 3x3 window 
def test_basic_small_numbers(cmdline_opts):
  dut = ConvUnit( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 3
  win_dim_plus = win_dim + 2
  window = np.arange(1, win_dim_plus * win_dim_plus + 1, dtype=int)
  window_2d = window.reshape(win_dim_plus, win_dim_plus)

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, win_dim, False)
  
# 3x3 window
def test_basic_large_numbers(cmdline_opts):
  dut = ConvUnit( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 3
  win_dim_plus = win_dim + 2
  window = np.arange(231, 231+win_dim_plus * win_dim_plus , dtype=int)
  window_2d = window.reshape(win_dim_plus, win_dim_plus)
  print(window_2d)

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, win_dim, False)
  
def test_basic_small_large_numbers(cmdline_opts):
  dut = ConvUnit( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 3
  win_dim_plus = win_dim + 2
  window = np.array([[ 46,  52, 150,  95, 161],
                     [ 43,  71,  45,  54,  83],
                     [  0,  91,  73, 181, 205],
                     [111, 128, 243, 183, 199],
                     [ 52, 213, 222, 179, 146]])
  window_2d = window.reshape(win_dim_plus, win_dim_plus)

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, win_dim, False)
  
def test_basic_positive_x(cmdline_opts):
  dut = ConvUnit( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 3
  win_dim_plus = win_dim + 2
  window = np.array([[ 0,  0, 255,  255, 255],
                     [ 0,  0, 255,  255, 255],
                     [ 0,  0, 255,  255, 255],
                     [ 0,  0, 255,  255, 255],
                     [ 0,  0, 255,  255, 255]])
  window_2d = window.reshape(win_dim_plus, win_dim_plus)

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, win_dim, False)
  
def test_basic_negative_x(cmdline_opts):
  dut = ConvUnit( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 3
  win_dim_plus = win_dim + 2
  window = np.array([[ 255, 255, 255, 0,  0],
                     [ 255, 255, 255, 0,  0],
                     [ 255, 255, 255, 0,  0],
                     [ 255, 255, 255, 0,  0],
                     [ 255, 255, 255, 0,  0]])
  window_2d = window.reshape(win_dim_plus, win_dim_plus)

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, win_dim, False)

def test_basic_positive_y(cmdline_opts):
  dut = ConvUnit( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 3
  win_dim_plus = win_dim + 2
  window = np.array([[   0,   0,   0,   0,  0],
                     [   0,   0,   0,   0,  0],
                     [   0,   0,   0,   0,  0],
                     [ 255, 255, 255, 255, 255],
                     [ 255, 255, 255, 255, 255]])
  window_2d = window.reshape(win_dim_plus, win_dim_plus)

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, win_dim, False)

def test_basic_negative_y(cmdline_opts):
  dut = ConvUnit( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 3
  win_dim_plus = win_dim + 2
  window = np.array([[ 255, 255, 255, 255, 255],
                     [ 255, 255, 255, 255, 255],
                     [   0,   0,   0,   0,  0],
                     [   0,   0,   0,   0,  0],
                     [   0,   0,   0,   0,  0]
                     ])
  window_2d = window.reshape(win_dim_plus, win_dim_plus)

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, win_dim, False)
  
  
  
def test_basic_random(cmdline_opts):
  dut = ConvUnit( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 3
  win_dim_plus = win_dim + 2
  window_2d = np.random.uniform(0, 255, size=(win_dim_plus, win_dim_plus)).astype(int)

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, win_dim, False)
  
def test_medium_random(cmdline_opts):
  dut = ConvUnit( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 7
  win_dim_plus = win_dim + 2
  window_2d = np.random.uniform(0, 255, size=(win_dim_plus, win_dim_plus)).astype(int)

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, win_dim, False)
  
def test_large_random(cmdline_opts):
  dut = ConvUnit( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 15
  win_dim_plus = win_dim + 2
  window_2d = np.random.uniform(0, 255, size=(win_dim_plus, win_dim_plus)).astype(int)

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, win_dim, False)
