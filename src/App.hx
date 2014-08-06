class App extends hxd.App {

	public var rootDir : String;
	public var font : h2d.Font;
	public var browser : FileBrowser;
	public var view : ImageView;
	public var data : Data;
	
	override function init() {
		flash.desktop.NativeApplication.nativeApplication.activeWindow.maximize();
		engine.backgroundColor = 0xFF202020;
		font = hxd.res.FontBuilder.getFont("Verdana", 16);
		rootDir = Sys.getCwd();
		if( sys.FileSystem.exists("anim.dat") )
			data = haxe.Json.parse(sys.io.File.getContent("anim.dat"));
		else
			data = {
				grid : 16,
				speed : 1/8,
				files : [],
			};
		browser = new FileBrowser();
	}
	
	override function onResize() {
		s2d.setFixedSize(engine.width, engine.height);
		browser.onResize();
		if( view != null ) view.onResize();
	}
	
	public function openFile( path : String ) {
		if( view != null ) view.dispose();
		var current = null;
		for( f in data.files )
			if( f.name.toLowerCase() == path.toLowerCase() ) {
				if( f.name != path ) {
					f.name = path;
					save();
				}
				current = f;
				break;
			}
		if( current == null ) {
			current = {
				name : path,
				frames : [],
				anims : [],
			};
			data.files.push(current);
		}
		view = new ImageView(current);
	}
	
	public function save() {
		sys.io.File.saveContent("anim.dat", haxe.Json.stringify(data,null,"\t"));
		trace("!");
	}
	

	public static var inst : App;
	static function main() {
		hxd.res.Embed.embedFont("Verdana.ttf");
		hxd.Res.initEmbed();
		inst = new App();
	}
	
}