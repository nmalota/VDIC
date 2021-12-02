virtual class base_tester extends uvm_component;

	`uvm_component_utils(base_tester)

	virtual alu_bfm bfm;

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
			$fatal(1,"Failed to get BFM");
	endfunction : build_phase

	pure virtual protected function operation_t get_op();

	pure virtual protected function bit [31:0] get_data();

	pure virtual protected function bit [2:0] get_len();

	pure virtual protected function bit [3:0] get_crc();

	task run_phase(uvm_phase phase);
		bit [31:0] A;
		bit [31:0] B;
		bit [3:0] CRC_in;
		bit [2:0] A_len;
		bit [2:0] B_len;
		operation_t op_set;
		shortint result;

		phase.raise_objection(this);

		bfm.reset_alu();

		bfm.reset_alu();
		repeat (10000) begin : tester_main
			@(negedge bfm.clk);
			bfm.reset_alu();
			bfm.op_set = get_op();
			bfm.A      = get_data();
			bfm.B      = get_data();
			bfm.A_len  = get_len();
			bfm.B_len  = get_len();
			bfm.CRC_in = get_crc();

			bfm.send1data(bfm.A,bfm.B,bfm.op_set,bfm.A_len, bfm.B_len, bfm.CRC_in);
			bfm.get1data(bfm.C, bfm.FLAGS, bfm.CRC);
			bfm.flag = 1'b1;
//          if($get_coverage() == 100) break;
		end

		phase.drop_objection(this);

	endtask : run_phase


endclass : base_tester
