class fifo_base_test extends uvm_test;

    `uvm_component_utils(fifo_base_test)

    fifo_env env_h;

    function new(string name = "fifo_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env_h = fifo_env::type_id::create("env_h", this);
    endfunction

endclass

class fifo_smoke_test extends fifo_base_test;

    `uvm_component_utils(fifo_smoke_test)

    function new(string name = "fifo_smoke_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        fifo_smoke_seq seq;

        phase.raise_objection(this);
        seq = fifo_smoke_seq::type_id::create("seq");
        seq.start(env_h.agent_h.sequencer_h);
        phase.drop_objection(this);
    endtask

endclass

class fifo_register_test extends fifo_base_test;

    `uvm_component_utils(fifo_register_test)

    function new(string name = "fifo_register_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        fifo_register_seq seq;

        phase.raise_objection(this);
        seq = fifo_register_seq::type_id::create("seq");
        seq.start(env_h.agent_h.sequencer_h);
        phase.drop_objection(this);
    endtask

endclass

class fifo_random_test extends fifo_base_test;

    `uvm_component_utils(fifo_random_test)

    function new(string name = "fifo_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        fifo_random_seq seq;

        phase.raise_objection(this);
        seq = fifo_random_seq::type_id::create("seq");
        seq.start(env_h.agent_h.sequencer_h);
        phase.drop_objection(this);
    endtask

endclass

class fifo_regression_test extends fifo_base_test;

    `uvm_component_utils(fifo_regression_test)

    function new(string name = "fifo_regression_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        fifo_smoke_seq      smoke_seq;
        fifo_full_empty_seq full_empty_seq;
        fifo_register_seq   register_seq;
        fifo_random_seq     random_seq;

        phase.raise_objection(this);

        smoke_seq      = fifo_smoke_seq::type_id::create("smoke_seq");
        full_empty_seq = fifo_full_empty_seq::type_id::create("full_empty_seq");
        register_seq   = fifo_register_seq::type_id::create("register_seq");
        random_seq     = fifo_random_seq::type_id::create("random_seq");

        smoke_seq.start(env_h.agent_h.sequencer_h);
        full_empty_seq.start(env_h.agent_h.sequencer_h);
        register_seq.start(env_h.agent_h.sequencer_h);
        random_seq.start(env_h.agent_h.sequencer_h);

        phase.drop_objection(this);
    endtask

endclass
