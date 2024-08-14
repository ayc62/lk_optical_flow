#=========================================================================
# RegArray
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *


class SimpleMultWrapper ( VerilogPlaceholder, Component ):
  def construct( s , x_width, y_width):
    s.x = InPort( x_width )
    s.y = InPort( y_width )
    s.x_val = InPort( 1 )
    s.y_val = InPort( 1 )
    s.p = OutPort( x_width+y_width )
    s.p_val = OutPort( 1 )
    s.set_metadata( VerilogTranslationPass.explicit_module_name,
                    'SimpleMultWrapper' )