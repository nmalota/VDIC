class shape;
	
	real width;
	real height;
	
	function new();
	endfunction : new
	
	function real get_area();
		$fatal(1,"Which shape's area do you want to calculate?");
	endfunction : get_area
	
	function void print();
		$fatal(1, "Which object type parameters do you want to print? ");
	endfunction : print
	
endclass : shape

class rectangle extends shape;
	function new(real a, real b);
		width = a;
		height = b;
	endfunction : new 
	
	function real get_area();
		return width * height;
	endfunction : get_area
	
	function void print();
		$display("Rectangle, w=%0g, l=%0g, area=%0g", width, height, get_area());
	endfunction : print
endclass : rectangle

class square extends rectangle;
	function new(real side);
		super.new(.a(side), .b(side));
	endfunction : new
	
	function void print();
		$display("Square, w=%0g, area=%0g", width, get_area());
	endfunction : print
endclass : square

class triangle extends shape;
	
	function new(real a, real h);
		width = a;
		height = h;
	endfunction: new 
	
	function real get_area();
		return width * height/2;
	endfunction : get_area
	
	function void print();
		$display("Triangle, w=%0g, h=%0g, area=%0g", width, height, get_area());
	endfunction : print
endclass : triangle