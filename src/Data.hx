
typedef FrameData = {
	var f : Int;
	var x : Int;
	var y : Int;
	var t : Int;
}

typedef AnimData = {
	var name : String;
	@:optional var obj : Null<String>;
	var speed : Float;
	var loop : Bool;
	var frames : Array<FrameData>;
}

typedef FileData = {
	var name : String;
	var frames : Array<{ x : Int, y : Int, w : Int, h : Int }>;
	var anims : Array<AnimData>;
}

typedef Data = {
	var files : Array<FileData>;
	var grid : Int;
	var speed : Float;
}
