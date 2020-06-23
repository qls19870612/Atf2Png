package
{
 
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import mx.graphics.codec.PNGEncoder;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	public class StarlingContent  extends Sprite 
	{
		
		
		private var _holder:Sprite;
	 
		
		public function StarlingContent()
		{
			_holder = new Sprite();
			super();
			 
		}
		
 
	 
		
		public function saveFile(textureAsset:ByteArray,file:File):void
		{
			textureAsset = textureAsset;
 
			var texture:Texture = Texture.fromAtfData(textureAsset, 1, false);
			var image:Image = new Image(texture);
			addChild(_holder);
			_holder.addChild(image);
			var bitmapData:BitmapData = new BitmapData(image.width, image.height, true);
			stage.drawToBitmapData(bitmapData, true);
			var pNGEncoder:PNGEncoder = new PNGEncoder();
			var byteArray:ByteArray = pNGEncoder.encode(bitmapData);
 			var fileName:String = file.name;
			fileName = (fileName.slice(0, (fileName.length - 4)) + ".png");
			var directory:String = (file.parent.nativePath + "\\PNG\\");
			(trace((directory + fileName)));
			var fileStream:FileStream = new FileStream();
			fileStream.open(new File((directory + fileName)), "write");
			fileStream.writeBytes(byteArray, 0, byteArray.length);
			fileStream.close();
			while (_holder.numChildren > 0) {
				_holder.removeChildAt(0);
			};
		}
		
		
	}
}//package com.vamapaull.view

// _SafeStr_1 = "CoinStacks_atf$c97bd1fafd924784fb5abcb7b982ae87-1664621953" (String#404)
