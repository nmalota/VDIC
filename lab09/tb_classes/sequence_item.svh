/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
class sequence_item extends uvm_sequence_item;

//  This macro is moved below the variables definition and expanded.
//    `uvm_object_utils(sequence_item)

//------------------------------------------------------------------------------
// sequence item variables
//------------------------------------------------------------------------------

	rand bit [31:0] A;
	rand bit [31:0] B;
	rand bit [3:0] CRC_in;
	rand bit [2:0] A_len;
	rand bit [2:0] B_len;
	rand operation_t        op_set;


//------------------------------------------------------------------------------
// Macros providing copy, compare, pack, record, print functions.
// Individual functions can be enabled/disabled with the last
// `uvm_field_*() macro argument.
// Note: this is an expanded version of the `uvm_object_utils with additional
//       fields added. DVT has a dedicated editor for this (ctrl-space).
//------------------------------------------------------------------------------

	`uvm_object_utils_begin(sequence_item)
		`uvm_field_int(A, UVM_ALL_ON | UVM_DEC)
		`uvm_field_int(B, UVM_ALL_ON | UVM_DEC)
		`uvm_field_int(CRC_in, UVM_DEFAULT)
		`uvm_field_int(A_len, UVM_DEFAULT)
		`uvm_field_int(B_len, UVM_DEFAULT)
		`uvm_field_enum(operation_t, op_set, UVM_DEFAULT)
	`uvm_object_utils_end

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

	constraint data_len {
		A_len dist {[3'h0 : 3'h3] :/25, 3'h4 := 75};
		B_len dist {[3'h0 : 3'h3] :/25, 3'h4 := 75};
	}
	constraint crc {
		CRC_in dist {[4'h0 : 4'hF] :/25, nextCRC4_D68({B, A, 1'b1, op_set}, 1'b0) := 75};
	}
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

	function new(string name = "sequence_item");
		super.new(name);
	endfunction : new
//------------------------------------------------------------------------------
// transaction functions: do_copy, clone_me, do_compare, convert2string
//------------------------------------------------------------------------------

	function void do_copy(uvm_object rhs);
		sequence_item copied_transaction_h;

		if(rhs == null)
			`uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

		super.do_copy(rhs); // copy all parent class data

		if(!$cast(copied_transaction_h,rhs))
			`uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

		A  = copied_transaction_h.A;
		B  = copied_transaction_h.B;
		op_set = copied_transaction_h.op_set;
		A_len = copied_transaction_h.A_len;
		B_len = copied_transaction_h.B_len;
		CRC_in = copied_transaction_h.CRC_in;

	endfunction : do_copy


	function bit do_compare(uvm_object rhs, uvm_comparer comparer);

		sequence_item compared_transaction_h;
		bit same;

		if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
				"Tried to do comparison to a null pointer");

		if (!$cast(compared_transaction_h,rhs))
			same = 0;
		else
			same = super.do_compare(rhs, comparer) &&
			(compared_transaction_h.A == A) &&
			(compared_transaction_h.B == B) &&			
			(compared_transaction_h.A_len == A_len) &&
			(compared_transaction_h.B_len == B_len) &&
			(compared_transaction_h.CRC_in == CRC_in) &&
			(compared_transaction_h.op_set == op_set);
		return same;

	endfunction : do_compare
//------------------------------------------------------------------------------
// convert2string
//------------------------------------------------------------------------------

	
	function string convert2string();
		string s;
		s = $sformatf("A: %8h  B: %8h A_len: %h B_len: %h CRC_in: %h op_set: %s", A, B, A_len, B_len, CRC_in, op_set.name());
		return s;
	endfunction : convert2string

endclass : sequence_item


