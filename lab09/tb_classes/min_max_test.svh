class min_max_test extends alu_base_test;

	`uvm_component_utils(min_max_test)

	local minmax_sequence minmax_seq;

	function new (string name, uvm_component parent);
		super.new(name,parent);
	endfunction : new

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------

	task run_phase(uvm_phase phase);
		minmax_seq = new("minmax_seq");
		phase.raise_objection(this);
		minmax_seq.start(sequencer_h);
		phase.drop_objection(this);
	endtask : run_phase



endclass
