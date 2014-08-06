
class ImageView {
	
	static inline var HEAD = 25;
	static var bgTile = null;
	
	var width : Int;
	var height : Int;
	var app : App;
	var root : h2d.Sprite;
	var content : h2d.Sprite;
	var image : h2d.Bitmap;
	var bmp : hxd.BitmapData;
	var frames : Array<IBounds>;
	var ui : h2d.Graphics;
	var selection : Array<Int>;
	var hightLight : Int;
	var selRect : { sx : Float, sy : Float, x : Float, y : Float, w : Float, h : Float, active : Bool };
	var data : Data.FileData;
	
	public function new(data) {
		this.data = data;
		app = App.inst;
		root = new h2d.Sprite(app.s2d);
		content = new h2d.Sprite(root);
		ui = new h2d.Graphics(root);
		ui.y = content.y = HEAD;
		var header = new h2d.Bitmap(h2d.Tile.fromColor(0xFF404040, 3000, HEAD - 1), root);
		var htxt = new h2d.Text(app.font, header);
		htxt.x = 2;
		htxt.y = 1;
		root.x = app.browser.width;
		var res = hxd.res.Any.fromBytes(data.name, sys.io.File.getBytes(data.name));
		bmp = res.toBitmap();
		detectFrames();
		var bg = new h2d.Bitmap(h2d.Tile.fromColor(0xFF400040,bmp.width, bmp.height), content);
		bg.tileWrap = true;
		image = new h2d.Bitmap(res.toTile(), content);
		htxt.text = data.name + " ["+bmp.width+" x "+bmp.height+"]";
		var int = new h2d.Interactive(bmp.width, bmp.height, content);
		hightLight = -1;
		selection = [];
		int.cursor = Default;
		int.enableRightButton = true;
		int.onClick = function(e) {
			switch( e.button ) {
			case 1:
				selection = [];
				redraw();
				return;
			}
			if( hightLight >= 0 ) {
				selection.push(hightLight);
				redraw();
			}
		};
		int.onMove = function(e) {
			var x = Std.int(e.relX);
			var y = Std.int(e.relY);
			if( selRect != null ) {
				var w = Math.abs(e.relX - selRect.x);
				var h = Math.abs(e.relY - selRect.y);
				selRect.x = e.relX < selRect.sx ? e.relX : selRect.sx;
				selRect.y = e.relY < selRect.sy ? e.relY : selRect.sy;
				selRect.w = w;
				selRect.h = h;
				if( w > 5 || h > 5 )
					selRect.active = true;
				if( selRect.active ) {
					hightLight = -1;
					redraw();
					return;
				}
			}
			for( i in 0...frames.length )
				if( frames[i].collide(x, y) ) {
					if( hightLight != i ) {
						hightLight = i;
						redraw();
					}
					return;
				}
			if( hightLight >= 0 ) {
				hightLight = -1;
				redraw();
			}
		};
		int.onPush = function(e) {
			var x = Std.int(e.relX);
			var y = Std.int(e.relY);
			selRect = { sx : x, sy : y, x : x, y : y, w : 1, h : 1, active : false };
		};
		int.onRelease = function(e) {
			if( selRect == null ) return;
			if( !selRect.active ) {
				selRect = null;
				redraw();
				return;
			}
			var b = new IBounds(Std.int(selRect.x), Std.int(selRect.y), Math.ceil(selRect.w), Math.ceil(selRect.h));
			selection = [];
			for( f in frames )
				if( f.intersects(b) )
					selection.push(frames.indexOf(f));
			selRect = null;
			redraw();
			e.cancel = true;
		};
		int.onOut = function(_) {
			if( hightLight >= 0 ) {
				hightLight = -1;
				redraw();
			}
		};
		int.onKeyUp = function(e) {
			switch( e.keyCode ) {
			case "M".code:
				if( selection.length < 2 ) return;
				var sel = [for( s in selection ) frames[s]];
				var b = sel[0].clone();
				for( s in sel )
					b.addBounds(s);
				for( s in sel )
					frames.remove(s);
				frames.push(b);
				// TODO : reindex animations !
				app.save();
				selection = [];
				redraw();
			case hxd.Key.BACKSPACE:
				selection.pop();
				redraw();
			case "A".code if( selection.length > 0 ):
				var frames = [];
				for( s in selection ) frames.push(this.frames[s]);
				data.anims.push({
					frames : buildAnim(frames),
					name : "Anim" + StringTools.lpad("" + (data.anims.length + 1), "0", 2),
					speed : 1.,
					loop : true,
				});
				app.save();
				selection = [];
				redraw();
			}
		}
		onResize();
	}
	
	function buildAnim( frames : Array<IBounds> ) {
		throw "TODO";
		return null;
	}
	
	function detectFrames() {
		var bmp = bmp.clone();
		frames = [];
		for( x in 0...bmp.width )
			for( y in 0...bmp.height ) {
				var p = bmp.getPixel(x, y);
				if( p >>> 24 == 0 ) continue;
				var b = new IBounds(x, y, 1, 1);
				while( true ) {
					var o = b.clone();
					for( y in 0...b.height )
						for( x in 0...b.width ) {
							var p = bmp.getPixel(b.x + x, b.y + y);
							if( p >>> 24 == 0 ) continue;
							addRec(bmp, b.x + x, b.y + y, b);
						}
					if( o.equals(b) )
						break;
				}
				frames.push(b);
			}
		bmp.dispose();
	}
	
	function addRec( bmp : hxd.BitmapData, x : Int, y : Int, b : IBounds ) {
		if( x < 0 || y < 0 || x >= bmp.width || y >= bmp.height ) return;
		var p = bmp.getPixel(x, y);
		if( p >>> 24 == 0 ) return;
		b.add(x, y);
		bmp.setPixel(x, y, 0);
		addRec(bmp, x - 1, y, b);
		addRec(bmp, x + 1, y, b);
		addRec(bmp, x, y - 1, b);
		addRec(bmp, x, y + 1, b);
	}
	
	public function onResize() {
		width = app.s2d.width - app.browser.width;
		height = app.s2d.height;
		var s = Math.min(width / bmp.width, (height - HEAD) / bmp.height);
		if( s < 1 )
			s = 1 / Math.ceil(1 / s);
		else
			s = Std.int(s);
		if( s > 12 ) s = 12;
		content.setScale(s);
		redraw();
	}
	
	function redraw() {
		ui.clear();
		var s = content.scaleX;
		for( i in 0...frames.length ) {
			var f = frames[i];
			var selected = selection.indexOf(i) >= 0;
			ui.lineStyle(1, selected ? 0xFFFFFFFF : 0xFFFF00FF);
			if( i == hightLight )
				ui.beginFill(0xFFFFFF, 0.1);
			ui.drawRect(f.x * s, f.y * s, f.width * s + 1, f.height * s + 1);
			if( i == hightLight )
				ui.endFill();
		}
		if( selRect != null ) {
			ui.lineStyle(1, 0xFFFFFFFF);
			ui.beginFill(0xFFFFFF, 0.1);
			ui.drawRect(selRect.x * s, selRect.y * s, selRect.w * s, selRect.h * s);
			ui.endFill();
		}
	}
	
	public function dispose() {
		bmp.dispose();
		image.tile.getTexture().dispose();
		root.remove();
	}
	
}