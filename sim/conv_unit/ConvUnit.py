#=========================================================================
# RegArray
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *

class ConvUnit ( VerilogPlaceholder, Component ):
  def construct( s, data_width=8):
    s.win_dim    = InPort ( 4 )
    s.pix        = InPort (data_width)
    s.pix_val    = InPort (1)
    s.Ix         = OutPort(data_width + 1)
    s.Ix_val     = OutPort(1)
    s.Iy         = OutPort(data_width + 1)
    s.Iy_val     = OutPort(1)
    s.set_metadata( VerilogTranslationPass.explicit_module_name,
                    'ConvUnit' )
