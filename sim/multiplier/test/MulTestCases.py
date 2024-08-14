#=========================================================================
# IntMulFL_test
#=========================================================================

import pytest

from random import randint

from pymtl3 import *
from pymtl3.stdlib.test_utils import mk_test_case_table, run_sim
from pymtl3.stdlib.stream import StreamSourceFL, StreamSinkFL

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness( Component ):

  def construct( s, imul ):

    # Instantiate models

    s.src  = StreamSourceFL( Bits24 )
    s.sink = StreamSinkFL( Bits24 )
    s.imul = imul

    # Connect

    s.src.ostream  //= s.imul.istream
    s.imul.ostream //= s.sink.istream

  def done( s ):
    return s.src.done() and s.sink.done()

  def line_trace( s ):
    return s.src.line_trace() + " > " + s.imul.line_trace() + " > " + s.sink.line_trace()

#-------------------------------------------------------------------------
# mk_imsg/mk_omsg
#-------------------------------------------------------------------------

# Make input message, truncate ints to ensure they fit in 32 bits.

def mk_imsg( x, y ):
  return concat( Bits9( x, trunc_int=True ), Bits15( y, trunc_int=True ) )

# Make output message, truncate ints to ensure they fit in 32 bits.

def mk_omsg( a ):
  return Bits24( a, trunc_int=True )

#----------------------------------------------------------------------
# Test Case: small positive * positive
#----------------------------------------------------------------------

small_pos_pos_msgs = [
  mk_imsg(  1,  1 ), mk_omsg(   1 ),
  mk_imsg(  2,  3 ), mk_omsg(   6 ),
  mk_imsg(  4,  5 ), mk_omsg(  20 ),
  mk_imsg(  3,  4 ), mk_omsg(  12 ),
  mk_imsg( 10, 13 ), mk_omsg( 130 ),
  mk_imsg(  8,  7 ), mk_omsg(  56 ),
]

# ''' LAB TASK '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# Define additional lists of input/output messages to create
# additional directed and random test cases.
# ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

#----------------------------------------------------------------------
# Test Case: small negative * positive
#----------------------------------------------------------------------

small_neg_pos_msgs = [
  mk_imsg(  -2,  3 ), mk_omsg(   -6 ),
  mk_imsg(  -4,  5 ), mk_omsg(  -20 ),
  mk_imsg(  -3,  4 ), mk_omsg(  -12 ),
  mk_imsg( -10, 13 ), mk_omsg( -130 ),
  mk_imsg(  -8,  7 ), mk_omsg(  -56 ),
]

#----------------------------------------------------------------------
# Test Case: small positive * negative
#----------------------------------------------------------------------

small_pos_neg_msgs = [
  mk_imsg(  2,  -3 ), mk_omsg(   -6 ),
  mk_imsg(  4,  -5 ), mk_omsg(  -20 ),
  mk_imsg(  3,  -4 ), mk_omsg(  -12 ),
  mk_imsg( 10, -13 ), mk_omsg( -130 ),
  mk_imsg(  8,  -7 ), mk_omsg(  -56 ),
]

#----------------------------------------------------------------------
# Test Case: small negative * negative
#----------------------------------------------------------------------

small_neg_neg_msgs = [
  mk_imsg(  -2,  -3 ), mk_omsg(   6 ),
  mk_imsg(  -4,  -5 ), mk_omsg(  20 ),
  mk_imsg(  -3,  -4 ), mk_omsg(  12 ),
  mk_imsg( -10, -13 ), mk_omsg( 130 ),
  mk_imsg(  -8,  -7 ), mk_omsg(  56 ),
]

#----------------------------------------------------------------------
# Test Case: zeros
#----------------------------------------------------------------------

zeros_msgs = [
  mk_imsg(  0,  0 ), mk_omsg( 0 ),
  mk_imsg(  0,  1 ), mk_omsg( 0 ),
  mk_imsg(  1,  0 ), mk_omsg( 0 ),
  mk_imsg(  0, -1 ), mk_omsg( 0 ),
  mk_imsg( -1,  0 ), mk_omsg( 0 ),
]
#----------------------------------------------------------------------
# Test Case: random small
#----------------------------------------------------------------------

random_small_msgs = []
for i in range(50):
  a = randint(0,100)
  b = randint(0,100)
  random_small_msgs.extend([ mk_imsg( a, b ), mk_omsg( a * b ) ])

#----------------------------------------------------------------------
# Test Case: random large
#----------------------------------------------------------------------

random_large_msgs = []
for i in range(50):
  a = (randint(-256,255))
  b = (randint(-16384,16383))
  random_large_msgs.extend([ mk_imsg( a, b ), mk_omsg( a * b ) ])

#-------------------------------------------------------------------------
# Test Case Table
#-------------------------------------------------------------------------

test_case_table = mk_test_case_table([
  (                      "msgs                   src_delay sink_delay"),
  [ "small_pos_pos",     small_pos_pos_msgs,     0,        0          ],

  # ''' LAB TASK '''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  # Add more rows to the test case table to leverage the additional lists
  # of request/response messages defined above, but also to test
  # different source/sink random delays.
  # ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

  [ "small_neg_pos",       small_neg_pos_msgs,    0,        0         ],
  [ "small_pos_neg",       small_pos_neg_msgs,    0,        0         ],
  [ "small_neg_neg",       small_neg_neg_msgs,    0,        0         ],
  [ "zeros",               zeros_msgs,            0,        0         ],
  [ "random_small",        random_small_msgs,     0,        0         ],
  [ "random_large",        random_large_msgs,     0,        0         ],
  [ "random_small_src40",  random_small_msgs,    40,        0         ],
  [ "random_large_src40",  random_large_msgs,    40,        0         ],

  # ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

])
