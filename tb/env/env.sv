class fifo_env extends uvm_env;

    `uvm_component_utils(fifo_env)

    fifo_agent      agent_h;
    fifo_scoreboard scoreboard_h;
    fifo_coverage   coverage_h;

    function new(string name = "fifo_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent_h      = fifo_agent::type_id::create("agent_h", this);
        scoreboard_h = fifo_scoreboard::type_id::create("scoreboard_h", this);
        coverage_h   = fifo_coverage::type_id::create("coverage_h", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent_h.monitor_h.analysis_port.connect(scoreboard_h.analysis_imp);
        agent_h.monitor_h.analysis_port.connect(coverage_h.analysis_export);
    endfunction

endclass

