#=========================================================================
# RegArray_test
#=========================================================================

import pytest

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_test_vector_sim
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts


from interpolation_unit.InterpolationUnit import InterpolationUnit
import numpy as np

def enqueue(dut, window_2d, row_counter, col_counter, win_dim_plus):
  dut.enq_msg @= int(window_2d[row_counter][col_counter])
  dut.enq_val @= 1
  col_counter = (col_counter + 1) % win_dim_plus
  if (col_counter == 0): row_counter = row_counter + 1
  return row_counter, col_counter

def stall(dut):
  dut.enq_val @= 0

def dequeue(dut, window_2d, deq_row, deq_col, win_dim_plus):
  assert dut.deq_msg[2] == int(window_2d[deq_row][deq_col])
  assert dut.deq_msg[1] == int(window_2d[deq_row+1][deq_col])
  assert dut.deq_msg[0] == int(window_2d[deq_row+2][deq_col])
  deq_col = (deq_col + 1) % win_dim_plus
  if (deq_col == 0): deq_row = deq_row + 1
  return deq_row, deq_col


# Helper function
def t( dut, window_2d, win_dim_plus, random_delay):
  
  row = 0
  col = 0
  deq_col = 0
  deq_row = 0
  is_deq = False

  # Write input value to input port
  while (deq_row != win_dim_plus - 2):
    random_number = np.random.rand()
    dut.win_dim @= win_dim_plus-2
    if (((random_number > 0.6) or (not random_delay)) and (row < win_dim_plus and col < win_dim_plus)):
      row, col = enqueue(dut, window_2d, row, col, win_dim_plus)
      if (row > 2 and col == 0): is_deq = True
    else: 
      stall(dut)
    
    if (is_deq): 
      deq_row, deq_col = dequeue(dut, window_2d, deq_row, deq_col, win_dim_plus)
      if (deq_col == 0): is_deq = False
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
def test_basic(cmdline_opts):
  dut = InterpolationUnit( 9, 15 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 3
  win_dim_plus = win_dim + 1
  window = np.arange(1, win_dim_plus * win_dim_plus, dtype=int)
  window_2d = window.reshape(win_dim_plus, win_dim_plus)

  dut.sim_reset()
  t(dut, window_2d, win_dim, win_dim_plus, False)
  
# Inject output data into each of 3 ports and read rdy
def test_basic_random_delay(cmdline_opts):
  dut = ConvFeeder( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 3
  win_dim_plus = win_dim + 2
  window = np.arange(1, win_dim_plus * win_dim_plus + 1, dtype=int)
  window_2d = window.reshape(win_dim_plus, win_dim_plus)
  print(window_2d)

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, True)
  
# Inject output data into each of 3 ports and read rdy
def test_random_delay_basic_five(cmdline_opts):
  dut = ConvFeeder( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 5
  win_dim_plus = win_dim + 2
  window = np.arange(1, win_dim_plus * win_dim_plus + 1, dtype=int)
  window_2d = window.reshape(win_dim_plus, win_dim_plus)

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, True)

def test_medium_basic(cmdline_opts):
  dut = ConvFeeder( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 5
  win_dim_plus = win_dim + 2
  window = np.arange(1, win_dim_plus * win_dim_plus + 1, dtype=int)
  window_2d = window.reshape(win_dim_plus, win_dim_plus)

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, False)
  
def test_large_basic_no_delay(cmdline_opts):
  dut = ConvFeeder( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 15
  win_dim_plus = win_dim + 2
  window = np.arange(1, win_dim_plus * win_dim_plus + 1, dtype=int)
  window = np.array([x % 256 for x in window])
  window_2d = window.reshape(win_dim_plus, win_dim_plus)

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, False)
  
def test_large_basic_random_delay(cmdline_opts):
  dut = ConvFeeder( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 15
  win_dim_plus = win_dim + 2
  window = np.arange(1, win_dim_plus * win_dim_plus + 1, dtype=int)
  window = np.array([x % 256 for x in window])
  window_2d = window.reshape(win_dim_plus, win_dim_plus)

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, True)

def test_directed(cmdline_opts):
  dut = ConvFeeder( 8 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  
  win_dim = 3
  win_dim_plus = win_dim + 2
  window_2d = np.array([[ 255,  255, 255,  255, 255],
                     [ 0,  0,  0,  0,  0],
                     [  255,  255, 255,  255, 255],
                     [0,  0,  0,  0,  0],
                     [ 255,  255, 255,  255, 255]])

  dut.sim_reset()
  t(dut, window_2d, win_dim_plus, False)