package fifo_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "fifo_xtn.sv"
    `include "fifo_sequencer.sv"
    `include "fifo_generator.sv"
    `include "write_drv.sv"
    `include "read_monitor.sv"
    `include "fifo_agent.sv"
    `include "reference_model.sv"
    `include "scoreboard.sv"
    `include "fifo_coverage.sv"
    `include "env.sv"
    `include "fifo_test.sv"

endpackage
