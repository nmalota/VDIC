virtual class base_tester extends uvm_component;

// base tester instance is never created, so we do not need macros
//     `uvm_component_utils(base_tester)

	uvm_put_port #(ALU_in_t) command_port;

	virtual alu_bfm bfm;

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
			$fatal(1, "Failed to get BFM");
		command_port = new("command_port", this);
	endfunction : build_phase

	pure virtual protected function operation_t get_op();

	pure virtual protected function bit [31:0] get_data();

	pure virtual protected function bit [2:0] get_len();

	pure virtual protected function bit [3:0] get_crc(input B, input A, input op_set);

	task run_phase(uvm_phase phase);

		ALU_in_t command;
		phase.raise_objection(this);
		bfm.reset_alu();
//      command.op_mode = rst_op;
//      command_port.put(command);

		repeat (10000) begin : tester_main

			command.A = get_data();
			command.B = get_data();
			command.A_len = get_len();
			command.B_len = get_len();
			command.op_set = get_op();
			command.CRC_in = get_crc(command.B, command.A,command.op_set);
			command_port.put(command);

		end
		#2000;
		phase.drop_objection(this);

	endtask : run_phase


endclass : base_tester
