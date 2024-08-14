#=========================================================================
# RegArray
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *

class InterpolationUnit ( VerilogPlaceholder, Component ):
  def construct( s, pix_width = 9, dec_width = 15):
    s.win_dim        = InPort ( 5 )
    s.pix            = InPort ( pix_width )
    s.pix_val        = InPort (1)
    s.pix_interp     = OutPort (pix_width+dec_width+2)
    s.pix_interp_val = OutPort(1)
    s.set_metadata( VerilogTranslationPass.explicit_module_name,
                    'InterpolationUnit' )
