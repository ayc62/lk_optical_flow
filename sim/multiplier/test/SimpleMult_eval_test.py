#=========================================================================
# IntMulFixed_test
#=========================================================================

import pytest

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_sim
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from multiplier.test.MulEvalCases import t, test_case_table

from multiplier.SimpleMultWrapper import  SimpleMultWrapper
@pytest.mark.parametrize( **test_case_table )
def test( test_params, cmdline_opts ):
  
  dut = SimpleMultWrapper(9, 15)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  t( dut, test_params )

  # th.set_param("top.src.construct",
  #   msgs=test_params.msgs[::2],
  #   initial_delay=test_params.src_delay+3,
  #   interval_delay=test_params.src_delay )

  # th.set_param("top.sink.construct",
  #   msgs=test_params.msgs[1::2],
  #   initial_delay=test_params.sink_delay+3,
  #   interval_delay=test_params.sink_delay )

  # run_sim( th, cmdline_opts, duts=['imul'] )

