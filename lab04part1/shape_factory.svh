class shape_factory;
	
	static function shape make_shape(string shape_type, real w, real h);
	
		rectangle rectangle_h;
		square square_h;
		triangle triangle_h;
	
		case(shape_type)
			"rectangle" : begin
				rectangle_h = new(w,h);
				shape_reporter#(rectangle)::add_shape(rectangle_h);
				return rectangle_h;
			end
			"square" : begin
				square_h = new(w);
				shape_reporter#(square)::add_shape(square_h);
				return square_h;
			end
			"triangle" : begin
				triangle_h = new(w,h);
				shape_reporter#(triangle)::add_shape(triangle_h);
				return triangle_h;
			end
			
			default : $fatal(1, {"There is no shape like this", shape_type});
	
		endcase
	
	endfunction : make_shape
	
endclass : shape_factory
