class IBounds {

	public var x : Int;
	public var y : Int;
	public var xMax : Int;
	public var yMax : Int;
	public var width(get,never) : Int;
	public var height(get,never): Int;
	
	public function new(x, y, w, h) {
		this.x = x;
		this.y = y;
		this.xMax = x + w - 1;
		this.yMax = y + h - 1;
	}
	
	inline function get_width() return xMax - x + 1;
	inline function get_height() return yMax - y + 1;
	
	public inline function add(x, y) {
		if( x < this.x ) this.x = x;
		if( x > xMax ) xMax = x;
		if( y < this.y ) this.y = y;
		if( y > yMax ) yMax = y;
	}
	
	public inline function addBounds(b:IBounds) {
		if( b.x < this.x ) this.x = b.x;
		if( b.xMax > xMax ) xMax = b.xMax;
		if( b.y < this.y ) this.y = b.y;
		if( b.yMax > yMax ) yMax = b.yMax;
	}
	
	public inline function intersects(b:IBounds) {
		return !(x > b.xMax || y > b.yMax || xMax < b.x || yMax < b.y);
	}
	
	public inline function clone() {
		return new IBounds(x, y, width, height);
	}
	
	public inline function equals( b : IBounds ) {
		return x == b.x && y == b.y && xMax == b.xMax && yMax == b.yMax;
	}
	
	public inline function collide(x:Int, y:Int) {
		return !(this.x > x || this.y > y || this.xMax < x || this.yMax < y);
	}

}
