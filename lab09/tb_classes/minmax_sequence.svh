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
class minmax_sequence extends uvm_sequence #(sequence_item);
	`uvm_object_utils(minmax_sequence)

	virtual alu_bfm bfm; // TODO remove
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

	function new(string name = "minmax_sequence");
		super.new(name);
	endfunction : new

//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------

	task body();
        
		`uvm_info("SEQ_MINMAX","",UVM_MEDIUM)
		`uvm_do_with(req, {op_set == rst_op;})
		
		repeat (1000) begin
			`uvm_do_with(req, {A dist {32'h0 :=1, 32'hFFFF_FFFF := 1};
				B dist {32'h0 :=1, 32'hFFFF_FFFF := 1};})
		end
	endtask : body


endclass : minmax_sequence











