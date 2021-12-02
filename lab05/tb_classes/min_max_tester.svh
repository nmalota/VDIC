class min_max_tester extends random_tester;

	`uvm_component_utils(min_max_tester)

	protected function bit [31:0] get_data();
		bit [1:0] zero_ones;
		zero_ones = 2'($random);
		if (zero_ones == 2'b00)
			return 32'h00000000;
		else if (zero_ones == 2'b11)
			return 32'hFFFFFFFF;
		else
			return 32'($random);
	endfunction : get_data

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : min_max_tester
