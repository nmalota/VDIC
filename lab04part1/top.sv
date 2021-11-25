`timescale 1ns/1ps
module top;
	initial begin
		
		shape shape_h;
		rectangle rectangle_h;
		square square_h;
		triangle triangle_h;
		
		int data_file; //file handler
		int scan_file; //file handler
		string shape_type;
		real w, h;
		
		data_file = $fopen("lab04part1_shapes.txt", "r");

		while(!$feof(data_file))begin  
			scan_file = $fscanf(data_file, "%s %g %g", shape_type, w, h);
			shape_h = shape_factory::make_shape(shape_type,w,h);
		end
		
		shape_reporter#(rectangle)::report_shapes();
		shape_reporter#(square)::report_shapes();
		shape_reporter#(triangle)::report_shapes();
	end
endmodule : top