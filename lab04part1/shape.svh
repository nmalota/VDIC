virtual class shape;
	
	real width;
	real height;
	
	function new(real w, real h);
		width = w;
		height = h;
	endfunction : new
	
	pure virtual function real get_area();

	pure virtual function void print();
	
endclass : shape

class rectangle extends shape;
	function new(real a, real b);
		super.new(.w(a), .h(b));
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

class triangle extends rectangle;
	
	function new(real a, real h);
		super.new(.a(a), .b(h));
	endfunction : new
	
	function real get_area();
		return width * height/2;
	endfunction : get_area
	
	function void print();
		$display("Triangle, w=%0g, h=%0g, area=%0g", width, height, get_area());
	endfunction : print
endclass : triangle