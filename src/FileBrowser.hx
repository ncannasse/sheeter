class FileBrowser {

	public var width(default,null) : Int;
	var app : App;
	var root : h2d.Sprite;
	var content : h2d.Sprite;
	var curPath : Array<String>;
	
	public function new() {
		app = App.inst;
		width = 200;
		root = new h2d.Sprite(app.s2d);
		curPath = [];
		refresh();
	}
	
	public function onResize() {
	}
	
	function refresh() {
		var curFiles = browse();
		if( content != null ) content.remove();
		content = new h2d.Sprite(root);
		var y = 0;
		var icons = [
			hxd.Res.dir.toTile(),
			hxd.Res.png.toTile(),
			hxd.Res.jpg.toTile(),
		];
		content.x = content.y = 2;
		var current = null;
		for( f in curFiles ) {
			if( f.p != ".." && f.p.charAt(0) == "." ) continue;
			var i = new h2d.Interactive(width, 24, content);
			i.onOver = function(_) {
				i.backgroundColor = 0xFF404040;
			};
			i.onOut = function(_) {
				i.backgroundColor = i == current ? 0xFF808080 : null;
			};
			i.onClick = function(_) {
				if( current == i ) return;
				if( current != null ) {
					current.backgroundColor = null;
					current = null;
				}
				if( f.dir ) {
					if( f.p == ".." )
						curPath.pop();
					else
						curPath.push(f.p);
					refresh();
				} else {
					var path = curPath.copy();
					path.push(f.p);
					current = i;
					i.backgroundColor = 0xFF808080;
					app.openFile(path.join("/"));
				}
			};
			var t = new h2d.Text(app.font, i);
			t.x = 30;
			t.y = 2;
			t.text = f.p;
			i.y = y;
			y += 26;
			var ic = new h2d.Bitmap(icons[f.dir ? 0 : 1], i);
			ic.scale(0.8);
			ic.filter = true;
		}
	}
	
	function browse() {
		var path = app.rootDir + curPath.join("/");
		var files = [];
		if( curPath.length > 0 )
			files.push( { p : "..", dir:true } );
		for( s in sys.FileSystem.readDirectory(path) ) {
			var abs = path + "/" + s;
			if( sys.FileSystem.isDirectory(abs) ) {
				files.push( { p:s, dir:true } );
				continue;
			}
			switch( s.split(".").pop().toLowerCase() ) {
			case "png", "jpg", "jpeg", "gif":
				files.push( { p:s, dir:false } );
			default:
			}
		}
		files.sort(function(f1, f2) { if( f1.dir != f2.dir ) return f1.dir ? -1 : 1; return Reflect.compare(f1.p, f2.p); });
		return files;
	}
	
}