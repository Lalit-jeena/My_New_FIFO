class fifo_xtn extends uvm_sequence_item;

    rand bit       rst_n;
    rand bit       wr_enb;
    rand bit       rd_enb;
    rand bit       cs;
    rand bit       reg_sel;
    rand bit [7:0] data_in;
    rand bit [7:0] addr;

    bit       full;
    bit       empty;
    bit       almost_full;
    bit       almost_empty;
    bit       overflow;
    bit       underflow;
    bit [7:0] data_out;
    bit [7:0] reg_rdata;

    constraint c_addr_aligned { addr[1:0] == 2'b00; }
    constraint c_reg_addr {
        if (reg_sel && (wr_enb || rd_enb)) {
            addr inside {8'h00, 8'h04, 8'h08, 8'h0C, 8'h10, 8'h14, 8'h20};
        }
    }

    `uvm_object_utils_begin(fifo_xtn)
        `uvm_field_int(rst_n,         UVM_ALL_ON)
        `uvm_field_int(wr_enb,        UVM_ALL_ON)
        `uvm_field_int(rd_enb,        UVM_ALL_ON)
        `uvm_field_int(cs,            UVM_ALL_ON)
        `uvm_field_int(reg_sel,       UVM_ALL_ON)
        `uvm_field_int(data_in,       UVM_ALL_ON)
        `uvm_field_int(addr,          UVM_ALL_ON)
        `uvm_field_int(full,          UVM_ALL_ON)
        `uvm_field_int(empty,         UVM_ALL_ON)
        `uvm_field_int(almost_full,   UVM_ALL_ON)
        `uvm_field_int(almost_empty,  UVM_ALL_ON)
        `uvm_field_int(overflow,      UVM_ALL_ON)
        `uvm_field_int(underflow,     UVM_ALL_ON)
        `uvm_field_int(data_out,      UVM_ALL_ON)
        `uvm_field_int(reg_rdata,     UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "fifo_xtn");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "rst_n=%0b cs=%0b reg_sel=%0b wr_enb=%0b rd_enb=%0b addr=0x%02h data_in=0x%02h full=%0b empty=%0b almost_full=%0b almost_empty=%0b overflow=%0b underflow=%0b data_out=0x%02h reg_rdata=0x%02h",
            rst_n, cs, reg_sel, wr_enb, rd_enb, addr, data_in,
            full, empty, almost_full, almost_empty, overflow, underflow,
            data_out, reg_rdata
        );
    endfunction

    static function string table_rule();
        return "+----------+-------+-----+----+-----+----+----+--------+--------+------+------+------+------+------+------+--------+--------+";
    endfunction

    static function string table_header();
        return "| SRC      | IDX   | RST | CS | REG | WR | RD | ADDR   | DATAIN | FULL | EMPTY| ALMF | ALME | OVFL | UDFL | DOUT   | RDATA  |";
    endfunction

    function string table_row(string src = "NA", string idx = "-");
        return $sformatf(
            "| %-8s | %-5s |  %0d  | %0d  |  %0d  | %0d  | %0d  | 0x%02h   | 0x%02h   |  %0d   |   %0d  |  %0d   |  %0d   |  %0d   |  %0d   | 0x%02h   | 0x%02h   |",
            src, idx, rst_n, cs, reg_sel, wr_enb, rd_enb, addr, data_in,
            full, empty, almost_full, almost_empty, overflow, underflow,
            data_out, reg_rdata
        );
    endfunction

endclass
