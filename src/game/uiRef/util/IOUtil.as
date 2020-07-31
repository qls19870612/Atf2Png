package game.uiRef.util
{
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.graphics.codec.JPEGEncoder;
	

	/**
	 * io操作util类
	 * @author FF
	 *
	 */
	public class IOUtil
	{

		public static function readXml(file:File):XML
		{
			if(!file.exists)
			{
				return new XML();
			}
			var fs:FileStream =new FileStream();
			fs.open(file, FileMode.READ);
			var personInfo:String=fs.readUTFBytes(fs.bytesAvailable);
			fs.close();
			return XML(personInfo);
		}
		
		public static function readString(file:File,encode:String = null):String
		{
			if(!file.exists)
			{
				return "";
			}
			var fs:FileStream=new FileStream();
			var personInfo:String;
			try
			{
				fs.open(file, FileMode.READ);
				if(encode == null)
				{
					personInfo = fs.readUTFBytes(fs.bytesAvailable);
				}else
				{
					personInfo = fs.readMultiByte(fs.bytesAvailable,encode);
				}
			}catch(e:Error)
			{
				Alert.show("readString:" + e.message);
			}
			fs.close();
			return personInfo;
		}
		
		public static function readByte(file:File):ByteArray
		{
			if(!file.exists)
			{
				trace(file.name + "不存在");
				return null;
			}
			var fs:FileStream=new FileStream();
			fs.open(file, FileMode.READ);
			var byte:ByteArray= new ByteArray();
			fs.readBytes(byte);
			fs.close();
			return byte;
		}

		public static function saveFile(f:File, txt:String):void
		{
			var stream:FileStream=new FileStream();
			stream.open(f, FileMode.WRITE);
			stream.writeUTFBytes(txt);
			stream.close();
		}
		
		public static function saveByteFile(f:File, byte:ByteArray):void
		{
			var stream:FileStream=new FileStream();
			stream.open(f, FileMode.WRITE);
			stream.writeBytes(byte);
			stream.close();
		}
		
		private static var jp:JPEGEncoder = new JPEGEncoder();
		public static function saveBitmapDataFile(f:File, bitmap:BitmapData):void
		{
			var byte:ByteArray = jp.encode(bitmap);
			saveByteFile(f,byte);
		}
		
		public static function readXmlInCheck(file:File):String
		{
			var errStr:String = "";
			var fs:FileStream=new FileStream();
			fs.open(file, FileMode.READ);
			var personInfo:String=fs.readUTFBytes(fs.bytesAvailable);
			fs.close();
			var xml:XML;
			try{
				xml = XML(personInfo);
			}catch(e:Error)
			{
				errStr = e.message;
			}
			return errStr;
		}
		
		public static function saveFileStr(f:File, txt:String,encode:String = ""):void
		{
			var stream:FileStream=new FileStream();
			stream.open(f, FileMode.WRITE);
			if(encode == "")
			{
				stream.writeUTFBytes(txt);
			}else
			{
				if(encode == "utf-8")
				{
//					stream.writeByte(0xEF);
//					stream.writeByte(0xBB);
//					stream.writeByte(0xBF);
				}
				stream.writeMultiByte(txt,encode);
			}
			stream.close();
		}
	}
}