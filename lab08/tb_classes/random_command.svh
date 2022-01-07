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
class random_command extends uvm_transaction;
	`uvm_object_utils(random_command)

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

	rand bit [31:0] A;
	rand bit [31:0] B;
	rand bit [3:0] CRC_in;
	rand bit [2:0] A_len;
	rand bit [2:0] B_len;
	rand operation_t        op_set;

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

	function new (string name = "");
		super.new(name);
	endfunction : new

//------------------------------------------------------------------------------
// transaction functions: do_copy, clone_me, do_compare, convert2string
//------------------------------------------------------------------------------

    extern function void do_copy(uvm_object rhs);
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function string convert2string();

endclass : random_command


