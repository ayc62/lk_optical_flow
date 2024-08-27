#=========================================================================
# RegArray
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *

class KernelCellXWrapper ( VerilogPlaceholder, Component ):
  def construct( s ):
    s.x1          = InPort ( 8 )
    s.x2          = InPort ( 8 )
    s.x3          = InPort ( 8 )
    s.x1_val      = InPort ( 1 )
    s.x2_val      = InPort ( 1 )
    s.x3_val      = InPort ( 1 )
    s.result      = OutPort ( 8+1 )
    s.result_val  = OutPort ( 1 )
    s.new_row     = InPort ( 1 )
    s.set_metadata( VerilogTranslationPass.explicit_module_name,
                    'KernelCellXWrapper' )



