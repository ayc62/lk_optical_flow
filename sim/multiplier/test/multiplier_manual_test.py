#=========================================================================
# RegArray_test
#=========================================================================

import pytest

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_test_vector_sim

from multiplier.Radix2MultRect import Radix2MultRect
from multiplier.SimpleMult import SimpleMult

basic_test = [
  (' x         y        p*'),
  [  1,        1,       0],
  [  0,        0,       0],
  [  0,        0,       1],
  [  1,        2,       0],
  [  0,        0,       0],
  [  0,        0,       2],
  [  2,        1,       0],
  [  0,        0,       0],
  [  0,        0,       2],
]

basic_test_negative = [
  (' x         y        p*'),
  [  -3,       3,       0],
  [  0,        0,       0],
  [   0,       0,       Bits24(-9)],
  [  3,       -3,       0],
  [  0,        0,       0],
  [  0,        0,       Bits24(-9)],
]

test_small_negative = [
  (' x         y        p*'),
  [  -1,       -1,       0],
  [  0,        0,       0],
  [   0,        0,       Bits24(1)],
  [  -1,        1,       0],
  [  0,        0,       0],
  [   0,        0,       Bits24(-1)],
  [   1,       -1,       0],
  [  0,        0,       0],
  [   0,        0,       Bits24(-1)],
]

test_large_negative = [
  (' x         y        p*'),
  [  -8,       -8,       0],
  [  0,        0,       0],
  [   0,        0,       Bits24(64)],
  [  -256,       -16384,  0],
  [  0,        0,       0],
  [   0,        0,       Bits24(256*16384)],
]

test_large_positive = [
  (' x         y        p*'),
  [  7,       7,       0],
  [  0,        0,       0],
  [  0,       0,       Bits24(49)],
  [  128,       16383,       0],
  [  0,        0,       0],
  [  0,       0,       Bits24(128*16383)],
]


#-------------------------------------------------------------------------
# test
#-------------------------------------------------------------------------

@pytest.mark.parametrize( "test_vectors", [
  basic_test,
  basic_test_negative,
  test_small_negative,
  test_large_negative,
  test_large_positive
])

def test( test_vectors, cmdline_opts ):
    # run_test_vector_sim( Radix2MultRect(9, 15), test_vectors, cmdline_opts )
    run_test_vector_sim( SimpleMult(9, 15), test_vectors, cmdline_opts )

