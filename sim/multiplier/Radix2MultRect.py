#=========================================================================
# RegArray
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *
from pymtl3.stdlib.stream.ifcs import IStreamIfc, OStreamIfc

class Radix2MultRect ( VerilogPlaceholder, Component ):
  def construct( s , x_width, y_width):
    s.istream = IStreamIfc( x_width+y_width )
    s.ostream = OStreamIfc( x_width+y_width )
    s.set_metadata( VerilogTranslationPass.explicit_module_name,
                    'Radix2MultRect' )
