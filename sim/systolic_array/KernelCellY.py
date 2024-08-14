#=========================================================================
# RegArray
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *

class KernelCellY ( VerilogPlaceholder, Component ):
  def construct( s, data_width=32):
    s.x1          = InPort ( data_width )
    s.x2          = InPort ( data_width )
    s.x3          = InPort ( data_width )
    s.x1_val      = InPort ( 1 )
    s.x2_val      = InPort ( 1 )
    s.x3_val      = InPort ( 1 )
    s.result      = OutPort ( data_width+1 )
    s.result_val  = OutPort ( 1 )
    s.new_row     = InPort( 1 )



