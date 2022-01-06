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
class tester extends uvm_component;
    `uvm_component_utils (tester)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    virtual alu_bfm bfm;
    uvm_put_port #(random_command) command_port;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
			$fatal(1, "Failed to get BFM");
		command_port = new("command_port", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------

    task run_phase(uvm_phase phase);
        random_command command;

        phase.raise_objection(this);

        command    = new("command");
        bfm.reset_alu();
        

        command    = random_command::type_id::create("command");
        repeat (1000) begin
            assert(command.randomize());
            command_port.put(command);
        end
        
        #500;
        
        phase.drop_objection(this);
        
    endtask : run_phase

endclass : tester






