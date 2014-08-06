class Sys {
	
	static var event : flash.events.InvokeEvent = null;
	@:keep static var _ = {
	flash.desktop.NativeApplication.nativeApplication.addEventListener(flash.events.InvokeEvent.INVOKE, function(e) event = e);
		0;
	}
	
	public static function getCwd() {
		var p = event.currentDirectory.nativePath;
		if( !StringTools.endsWith(p, "/") && !StringTools.endsWith(p, "\\") )
			p += "/";
		return p;
	}
}