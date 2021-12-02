class min_max_tester extends random_tester;

	`uvm_component_utils(min_max_tester)

	protected function bit [31:0] get_data();
		bit zero_ones;
		zero_ones = 1'($random);
		if (zero_ones == 1'b0)
			return 32'h00000000;
		else 
			return 32'hFFFFFFFF;
	endfunction : get_data

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : min_max_tester
