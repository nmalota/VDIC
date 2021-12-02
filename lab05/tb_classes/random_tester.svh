class random_tester extends base_tester;
    
    `uvm_component_utils (random_tester)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//---------------------------------
// Random data generation functions
//---------------------------------
	protected function operation_t get_op();
		bit [2:0] op_choice;
		op_choice = 3'($random);
		case (op_choice)
			3'b000 : return and_op;
			3'b001 : return or_op;
			3'b010 : return bad_op1;
			3'b011 : return bad_op2;
			3'b100 : return add_op;
			3'b101 : return sub_op;
			3'b110 : return bad_op3;
			3'b111 : return bad_op4;
		endcase // case (op_choice)
	endfunction : get_op

//------------------------------------------------------------------
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
	
	protected function bit [2:0] get_len();
		bit correct;
		correct = 1'($random);
		if (correct)
			return 3'd4;
		else
			return {1'b0, 2'($random)};
	endfunction : get_len
	
	protected function bit [3:0] get_crc();
		bit correct;
		correct = 1'($random);
		if (correct)
			return nextCRC4_D68({bfm.B,bfm.A,1'b1,bfm.op},0);
		else
			return 4'($random);
	endfunction : get_crc

endclass : random_tester






