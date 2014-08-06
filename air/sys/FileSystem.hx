package sys;

class FileSystem {
	
	@:allow(sys.io.File)
	static function get( path : String ) {
		if( path.charCodeAt(0) != "/".code && path.charCodeAt(1) != ":".code )
			path = Sys.getCwd() + path;
		return new flash.filesystem.File(path);
	}

	public static function exists( path : String ) {
		return try get(path).exists catch( e : Dynamic ) false;
	}

	public static function readDirectory( path : String ) {
		var f = get(path);
		return [for( f in f.getDirectoryListing() ) f.name];
	}
	
	public static function isDirectory( path : String ) {
		return try get(path).isDirectory catch( e : Dynamic ) false;
	}
	
}