package 
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class FileOperationer
	{
		public function FileOperationer()
		{
		}
		public static function getStr( bytearray:ByteArray ):String
		{ 
			var info:String = "";
			bytearray.position = 0;
			var headNum:uint = bytearray.readUnsignedShort();
			trace( "string  headNum :: ", headNum.toString( 16 ) );
			if( headNum == 0xFEFF )//UTF-16BE(Unicode的大尾编码)
			{
				trace( "文件采用的是--- UTF-16BE(Unicode的大尾编码)" );
				info = bytearray.readMultiByte( bytearray.bytesAvailable, "unicodeFFFE" );
			}
			else if( headNum == 0xFFFE )//UTF-16LE(Unicode的小尾编码)
			{
				trace( "文件采用的是--- UTF-16LE(Unicode的小尾编码)" );
				info = bytearray.readMultiByte( bytearray.bytesAvailable, "unicode" );
			}
			else if( headNum == 0xEFBB )//UTF-8 包括 with BOM 与 with OUT BOM
			{
				var headNum_last:uint = bytearray.readUnsignedByte(); 
				if( headNum_last == 0xBF )//UTF-8 with BOM
				{
					trace( "文件采用的是--- UTF-8 with BOM" );
					info = bytearray.readMultiByte( bytearray.bytesAvailable, "UTF-8" );
				}
				else//UTF-8 with OUT BOM
				{
					trace( "文件采用的是--- UTF-8 with OUT BOM" )
					bytearray.position = 0;
					info = bytearray.readMultiByte( bytearray.bytesAvailable, "utf-8" );
				}
			}
			else //剩下的是 gb2312 与  UTF-8 with OUT BOM
			{
				var charSet:String;
				if( IsUTF8ByteWithoutBom( bytearray ) )
				{
					charSet = "utf-8";
				}
				else
				{
					charSet = "gb2312";
				}
				bytearray.position = 0;
				info = bytearray.readMultiByte( bytearray.bytesAvailable, charSet );
				trace( "文件采用的是--- ", charSet );
			}
			
			return info;
		}
		
		/**
		 * 检测内容是否是 utf-8 without bom 格式
		 * @author jacc 
		 */		
		public static function IsUTF8ByteWithoutBom( bytearray:ByteArray ):Boolean
		{
			bytearray.position = 0;
			var curByte:int;
			var charByteCounter:int = 1;
			var fileStreamLength:uint = bytearray.bytesAvailable;
			for( var idx:int = 0; idx < fileStreamLength; ++idx )
			{
				curByte = bytearray[ idx ];
				if( charByteCounter == 1 )
				{
					if( curByte >= 0x80 )
					{
						while( ( ( curByte <<= 1 ) & 0x80 ) != 0 )
						{
							charByteCounter++;
						}
						if ( charByteCounter == 1 || charByteCounter > 6 )
						{
							return false;
						}
					}
				}
				else if( charByteCounter > 1 )
				{
					if( ( curByte & 0xC0 ) != 0x80 )
					{
						return false;
					}
					charByteCounter--;
				}
				else 
				{
					return false;
				}
			}
			if( charByteCounter != 1 )
			{
				return false;
			}
			return true;
		}
		public static function getFileLines(fileStr:String):Array
		{
			fileStr = fileStr.replace(/\r\n/g,"\n");
			return fileStr.split("\n");
		}
		public static function writeFile(fileNativeURL:String, byteArr:ByteArray):File
		{
			var fileStream:FileStream=new FileStream;
			var file:File=new File(fileNativeURL);
			fileStream.open(file, FileMode.WRITE);
			fileStream.position = 0;
			fileStream.truncate();
			fileStream.writeBytes(byteArr);
			fileStream.close();
			return file;
		}


		public static function writeText(xmlStr:String, fullUrl:String, encode:String = "utf-8"):void
		{
			var file:File=new File(fullUrl);
			var fileStream:FileStream=new FileStream;
			fileStream.open(file, FileMode.UPDATE);
			fileStream.truncate();
//			fileStream.writeUTFBytes(xmlStr);
			fileStream.writeMultiByte(xmlStr, encode);

			fileStream.close();
		}
		public static function readTxt(nativeUrl:String):String
		{
			var file:File=new File(nativeUrl);
			if (file.exists)
			{
				var fileStream:FileStream=new FileStream;
				fileStream.open(file, FileMode.READ);
				var xmlStr:String=fileStream.readUTFBytes(fileStream.bytesAvailable);
				fileStream.close();
				return xmlStr;
			}
			return null;
		}
		/**
		 *对指定目录文本文件进行替换，如果无替换，则不更新文件 
		 * @param nativeUrl
		 * @param replaceFun
		 * @return 
		 * 
		 */		
		public static function updateTxtFile(nativeUrl:String,replaceFun:Function):Boolean
		{
			var file:File=new File(nativeUrl);
			if (file.exists)
			{
				var fileStream:FileStream=new FileStream;
				fileStream.open(file, FileMode.UPDATE);
				var str:String=fileStream.readUTFBytes(fileStream.bytesAvailable);
				str= replaceFun.apply(null,[str]);
				if (str != null) 
				{
					/**<如果没有返回字符串，说明没有修改，则不进行写入>*/
					fileStream.position = 0;
					fileStream.truncate();
					fileStream.writeUTFBytes(str);
				}
				fileStream.close();
				return true;
			}
			return false;
		}
 
		public static function readXML(nativeUrl:String):XML
		{
			var xmlStr:String = readTxt(nativeUrl);
			if (xmlStr) 
			{
				try
				{
					
					var xml:XML=XML(xmlStr);
				} 
				catch(error:Error) 
				{
					//					UIEditor.writeLog("读取XML格式错误:"+nativeUrl+":"+error.getStackTrace());
					return null;
				}
				return xml;
			}
			return null;
		}

		public static function readFile(nativePath:String):ByteArray
		{
			var file:File=new File(nativePath);
			if (file.exists)
			{
				var fileStream:FileStream=new FileStream;
				try
				{
					fileStream.open(file, FileMode.READ);

				}
				catch (error:Error)
				{
					return null;
				}
				var bytes:ByteArray=new ByteArray();
				fileStream.readBytes(bytes);
				return bytes;
			}
			return null;
		}

//		public static function openUrl(urlStr:String, select:Boolean = false):Boolean
//		{
//			if (!urlStr)
//			{
//				return false;
//			}
//			var imageFolder:File;
//			try
//			{
//				
//				imageFolder=new MyFile(urlStr);
//			}
//			catch (error:Error)
//			{
//				
//			}
//			return openFolder(imageFolder);
//		}
		public static function openFolder(file:File,select:Boolean = false):Boolean
		{
			if (file && file.exists) 
			{
				if (select) 
				{
					var isSelectSuccess:Boolean = tryOpenAndSelect(file);
					if (isSelectSuccess) 
					{
						return true;
					}
				}
				
				if (file.isDirectory) 
				{
					file.openWithDefaultApplication();
				}
				else
				{
					
					file.parent.openWithDefaultApplication();
				}
				return true;
			}
			return false;
		} 
		
		private static function tryOpenAndSelect(file:File):Boolean
		{
			var exploreFile:File = File.applicationDirectory.resolvePath("C:/Windows/explorer.exe");
			if (!exploreFile.exists) 
			{
				return false;
			}
			var process:NativeProcess = new NativeProcess();
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = exploreFile;
			info.workingDirectory = exploreFile.parent;
			
			var arguments:Vector.<String> = new Vector.<String>();
			arguments.push("/select,");
			arguments.push(file.nativePath);
			info.arguments = arguments;
			process.start(info);
			process.exit();
			return true;
		}
	}
}
