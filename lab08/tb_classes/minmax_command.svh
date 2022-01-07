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
class minmax_command extends random_command;
	`uvm_object_utils(minmax_command)
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
	function new(string name="");
		super.new(name);
	endfunction
//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

	constraint data {
		A dist {32'h00:=1, 32'hFFFF_FFFF:=1};
		B dist {32'h00:=1, 32'hFFFF_FFFF:=1};
	}

endclass : minmax_command


