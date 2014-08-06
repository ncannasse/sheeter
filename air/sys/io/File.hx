package sys.io;

class File {

	public static function getBytes( path : String ) {
		var file = FileSystem.get(path);
		var fs = new flash.filesystem.FileStream();
		fs.open(file, flash.filesystem.FileMode.READ);
		var bytes = haxe.io.Bytes.alloc(fs.bytesAvailable);
		fs.readBytes(bytes.getData());
		fs.close();
		return bytes;
	}
	
	public static function getContent( path : String ) {
		return getBytes(path).toString();
	}
	
	public static function saveContent( path : String, data : String ) {
		saveBytes(path, haxe.io.Bytes.ofString(data));
	}
	
	public static function saveBytes( path : String, data : haxe.io.Bytes ) {
		var file = FileSystem.get(path);
		var fs = new flash.filesystem.FileStream();
		fs.open(file, flash.filesystem.FileMode.WRITE);
		if( data.length > 0 ) fs.writeBytes(data.getData(), 0, data.length);
		fs.close();
	}
	
}