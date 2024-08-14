#=========================================================================
# RegArray
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *

class ConvFeeder ( VerilogPlaceholder, Component ):
  def construct( s, data_width=32):
    s.win_dim    = InPort ( 4 )
    s.enq_val    = InPort(1)
    s.enq_rdy    = [OutPort(1) for _ in range(3)]
    s.enq_msg       = InPort (data_width)
    s.deq_val      = [OutPort(1) for _ in range(3)]
    s.deq_rdy      = [OutPort(1) for _ in range(3)]
    s.deq_msg      = [OutPort(data_width) for _ in range(3)]
    s.new_row      = OutPort( 1 )
    s.set_metadata( VerilogTranslationPass.explicit_module_name,
                    'ConvFeeder' )
    

    # input logic [3:0] win_dim,

    # input logic enq_val,
    # output logic enq_rdy [2:0],
    # input logic [data_width-1:0] enq_msg,

    # output logic deq_val [2:0],
    # output logic [data_width-1:0] deq_msg [2:0]


