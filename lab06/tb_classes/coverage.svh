class coverage extends uvm_subscriber #(ALU_in_t);

	`uvm_component_utils(coverage)


	protected bit         [31:0]  A;
	protected bit         [31:0]  B;
	protected bit         [2:0]  A_len;
	protected bit         [2:0]  B_len;
	protected bit 		  expected_err_crc;
	protected operation_t         op_set;

	covergroup op_cov;

		option.name = "cg_op_cov";

		A_alu_op : coverpoint op_set {
			// #A1 test all operations
			bins A1_valid_op[] = {and_op, or_op, add_op, sub_op};
			// #A2 test incorrect alu op code
			bins A2_invalid_op[] = {bad_op1, bad_op2, bad_op3, bad_op4};
		}
	endgroup

	covergroup zeros_or_ones_on_ops;

		option.name = "cg_zeros_or_ones_on_ops";

		all_ops : coverpoint op_set {
			bins all_op[] = {and_op, or_op, add_op, sub_op};
		}

		a_leg: coverpoint A {
			bins zeros = {'h0000_0000};
			bins others= {['h0000_0001:'hFFFF_FFFE]};
			bins ones  = {'hFFFF_FFFF};
		}

		b_leg: coverpoint B {
			bins zeros = {'h0000_0000};
			bins others= {['h0000_0001:'hFFFF_FFFE]};
			bins ones  = {'hFFFF_FFFF};
		}

		B_op_00_FF: cross a_leg, b_leg, all_ops {

			// #B1 simulate all zero input for all the operations
			bins B1_add_00          = binsof (all_ops) intersect {add_op} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_and_00          = binsof (all_ops) intersect {and_op} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_or_00           = binsof (all_ops) intersect {or_op} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_sub_00          = binsof (all_ops) intersect {sub_op} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			// #B2 simulate all one input for all the operations
			bins B2_add_FF          = binsof (all_ops) intersect {add_op} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B2_and_FF          = binsof (all_ops) intersect {and_op} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B2_or_FF           = binsof (all_ops) intersect {or_op} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B2_sub_FF          = binsof (all_ops) intersect {sub_op} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			ignore_bins others_only =
			binsof(a_leg.others) && binsof(b_leg.others);
		}

	endgroup

	covergroup err_cov;

		option.name = "cg_err_cov";

		// #A4 Test operations with incorrect CRC
		err_crc : coverpoint expected_err_crc {
			bins C2_err_crc = {1'b1};
		}

		// #A3 Test operations with incorrect nr of data bits
		err_data_A : coverpoint A_len {
			bins C3_inv_range_A[] = {[3'd0 : 3'd3]};
		}
		err_data_B : coverpoint B_len {
			bins C3_inv_range_B[] = {[3'd0 : 3'd3]};
		}

	endgroup

	function new (string name, uvm_component parent);
		super.new(name, parent);
		op_cov               = new();
		zeros_or_ones_on_ops = new();
		err_cov              = new();
	endfunction : new

    function void write(ALU_in_t t);
        A      = t.A;
        B      = t.B;
	    A_len  = t.A_len;
	    B_len  = t.B_len;
        op_set = t.op_set;
	    expected_err_crc = !(t.CRC_in == nextCRC4_D68({B,A,1'b1, op_set},0));
        op_cov.sample();
        zeros_or_ones_on_ops.sample();
	    err_cov.sample();
    endfunction : write
    
endclass : coverage

