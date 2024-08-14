#=========================================================================
# RegArray
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *

class PE ( VerilogPlaceholder, Component ):
  def construct( s, data_width=32, p_shamt_nbits=3):
    s.x_in    = InPort ( data_width )
    s.y_in    = InPort(data_width)
    s.x_out    = OutPort(data_width)
    s.y_out       = OutPort (data_width)
    s.shamt      = OutPort (p_shamt_nbits)
    s.addamt      = InPort(data_width)


