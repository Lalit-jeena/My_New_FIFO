class fifo_base_seq extends uvm_sequence #(fifo_xtn);

    `uvm_object_utils(fifo_base_seq)

    function new(string name = "fifo_base_seq");
        super.new(name);
    endfunction

    virtual task send_cycle(
        bit       rst_n   = 1'b1,
        bit       cs      = 1'b0,
        bit       reg_sel = 1'b0,
        bit       wr_enb  = 1'b0,
        bit       rd_enb  = 1'b0,
        bit [7:0] addr    = 8'h00,
        bit [7:0] data_in = 8'h00
    );
        fifo_xtn req;

        req = fifo_xtn::type_id::create("req");
        start_item(req);
        req.rst_n   = rst_n;
        req.cs      = cs;
        req.reg_sel = reg_sel;
        req.wr_enb  = wr_enb;
        req.rd_enb  = rd_enb;
        req.addr    = addr;
        req.data_in = data_in;
        finish_item(req);
    endtask

    virtual task apply_reset(int unsigned cycles = 3);
        repeat (cycles) begin
            send_cycle(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'h00, 8'h00);
        end
        send_cycle(1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 8'h00, 8'h00);
    endtask

    virtual task idle(int unsigned cycles = 1);
        repeat (cycles) begin
            send_cycle(1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 8'h00, 8'h00);
        end
    endtask

    virtual task fifo_write(bit [7:0] data);
        send_cycle(1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 8'h00, data);
    endtask

    virtual task fifo_read();
        send_cycle(1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 8'h00, 8'h00);
    endtask

    virtual task fifo_rw(bit [7:0] data);
        send_cycle(1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 8'h00, data);
    endtask

    virtual task reg_write(bit [7:0] addr, bit [7:0] data);
        send_cycle(1'b1, 1'b1, 1'b1, 1'b1, 1'b0, addr, data);
    endtask

    virtual task reg_read(bit [7:0] addr);
        send_cycle(1'b1, 1'b1, 1'b1, 1'b0, 1'b1, addr, 8'h00);
    endtask

    virtual task gated_noise(bit wr_enb, bit rd_enb, bit reg_sel, bit [7:0] addr, bit [7:0] data);
        send_cycle(1'b1, 1'b0, reg_sel, wr_enb, rd_enb, addr, data);
    endtask

endclass

class fifo_smoke_seq extends fifo_base_seq;

    `uvm_object_utils(fifo_smoke_seq)

    function new(string name = "fifo_smoke_seq");
        super.new(name);
    endfunction

    virtual task body();
        apply_reset();
        fifo_write(8'h11);
        fifo_write(8'h22);
        fifo_write(8'h33);
        idle(2);
        fifo_read();
        fifo_read();
        fifo_read();
        fifo_read();
        idle(2);
    endtask

endclass

class fifo_full_empty_seq extends fifo_base_seq;

    `uvm_object_utils(fifo_full_empty_seq)

    function new(string name = "fifo_full_empty_seq");
        super.new(name);
    endfunction

    virtual task body();
        int unsigned i;

        apply_reset();

        for (i = 0; i < 16; i++) begin
            fifo_write(8'h80 + i[7:0]);
        end

        fifo_write(8'hFE);
        fifo_read();
        fifo_rw(8'hA5);
        fifo_rw(8'h5A);

        repeat (13) begin
            fifo_read();
        end

        fifo_rw(8'h3C);
        fifo_read();
        fifo_rw(8'hC3);

        repeat (15) begin
            fifo_write($urandom_range(0, 255));
        end

        fifo_rw(8'h77);
        gated_noise(1'b1, 1'b1, 1'b0, 8'h00, 8'h55);
        idle(2);
    endtask

endclass

class fifo_register_seq extends fifo_base_seq;

    `uvm_object_utils(fifo_register_seq)

    function new(string name = "fifo_register_seq");
        super.new(name);
    endfunction

    virtual task body();
        apply_reset();

        reg_read(8'h04);
        reg_read(8'h08);
        reg_read(8'h0C);
        reg_read(8'h14);

        reg_write(8'h08, 8'h03);
        reg_write(8'h0C, 8'h01);
        reg_read(8'h08);
        reg_read(8'h0C);

        fifo_write(8'h44);
        fifo_write(8'h55);
        fifo_write(8'h66);

        reg_read(8'h10);
        reg_read(8'h14);
        reg_read(8'h20);

        reg_write(8'h00, 8'h02);
        send_cycle(1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 8'h00, 8'h00);
        reg_read(8'h10);

        reg_write(8'h00, 8'h02);
        send_cycle(1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 8'h00, 8'h00);
        reg_read(8'h04);
        reg_read(8'h10);
        reg_read(8'h14);
    endtask

endclass

class fifo_random_seq extends fifo_base_seq;

    `uvm_object_utils(fifo_random_seq)

    function new(string name = "fifo_random_seq");
        super.new(name);
    endfunction

    virtual task body();
        fifo_xtn req;
        int unsigned i;

        apply_reset();

        for (i = 0; i < 200; i++) begin
            req = fifo_xtn::type_id::create($sformatf("random_req_%0d", i));
            start_item(req);
            if (!req.randomize() with {
                rst_n == 1'b1;
                cs dist {1'b1 := 8, 1'b0 := 2};
                reg_sel dist {1'b0 := 7, 1'b1 := 3};
                wr_enb dist {1'b1 := 5, 1'b0 := 5};
                rd_enb dist {1'b1 := 5, 1'b0 := 5};
                if (!cs) {
                    addr == 8'h00;
                }
                if (cs && !reg_sel) {
                    addr == 8'h00;
                }
                if (cs && reg_sel) {
                    addr inside {8'h00, 8'h04, 8'h08, 8'h0C, 8'h10, 8'h14, 8'h20};
                }
            }) begin
                `uvm_fatal(get_type_name(), "Randomization failed in fifo_random_seq")
            end
            finish_item(req);
        end

        idle(5);
    endtask

endclass
