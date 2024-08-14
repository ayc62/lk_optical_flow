#=========================================================================
# RegArray_test
#=========================================================================

import pytest

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_test_vector_sim

from interpolation_unit.InterpolationUnit import InterpolationUnit

basic_test = [
  (' win_dim  pix  pix_val  pix_interp*  pix_interp_val*'),
  [     3,    1,        1,       '?',          0],
  [     3,    2,        1,       '?',          0],
  [     3,    3,        1,       '?',          0],
  [     3,    4,        1,       '?',          0],
  [     3,    5,        1,       '?',          0],
  [     3,    6,        1,       '?',          0],
  [     3,    7,        1,       '?',          0],
  [     3,    8,        1,       '?',          0],
  [     3,    9,        1,       1+2+5+6,      1],
  [     3,   10,        1,       2+3+6+7,      1],
  [     3,   11,        1,       3+4+7+8,      1],
  [     3,   12,        1,       '?',          0],
  [     3,   13,        1,       5+6+9+10,     1],
  [     3,   14,        1,       6+7+10+11,    1],
  [     3,   15,        1,       7+8+11+12,    1],
  [     3,   16,        1,       '?',          0],
  [     3,    0,        0,       9+10+13+14,   1],
  [     3,    0,        0,       10+11+14+15,  1],
  [     3,    0,        0,       11+12+15+16,  1],
  [     3,    0,        0,       '?',          0],
  [     3,    0,        0,       '?',          0],
]

#-------------------------------------------------------------------------
# test
#-------------------------------------------------------------------------

@pytest.mark.parametrize( "test_vectors", [
  basic_test,
])

def test( test_vectors, cmdline_opts ):
    # run_test_vector_sim( Radix2MultRect(9, 15), test_vectors, cmdline_opts )
    run_test_vector_sim( InterpolationUnit(9, 15), test_vectors, cmdline_opts )

