package game.uiRef.util
{
	import flash.filesystem.File;
	import flash.utils.Dictionary;

	public class FileUtil
	{
		public function FileUtil()
		{
		}
		
		public static function getFileShortName(file:File):String
		{
			var shortname:String = file.name;
			var index:int = shortname.indexOf(".");
			if(index != -1)
			{
				shortname = shortname.substring(0,index);
			}
			return shortname;
		}
		
		public static function getFileExtendsType(file:File):String
		{
			var shortname:String = file.name;
			var index:int = shortname.indexOf(".");
			if(index != -1)
			{
				shortname = shortname.substring(index + 1);
			}
			return shortname;
		}
		
		public static function getFolderFileList(file:File,filterExt:String = ""):Array
		{
			var fileArr:Array = [];
			if(file.isDirectory)
			{
				var arr:Array = file.getDirectoryListing();
				for each (var subFile:File in arr) 
				{
					var fileName:String = subFile.name;
					if(fileName == ".svn")
					{
						continue;
					}
					if(subFile.isDirectory)
					{
						var subFileArr:Array = getFolderFileList(subFile,filterExt);
						fileArr = fileArr.concat(subFileArr);
					}else
					{
						if(subFile.extension == filterExt || filterExt == "")
						{
							fileArr.push(subFile);
						}
					}
				}
			}
			return fileArr;
		}
		public static function getFolderFileListByExtendDic(file:File,extendNames:Dictionary = null):Array
		{
			var fileArr:Array = [];
			if(file.isDirectory)
			{
				var arr:Array = file.getDirectoryListing();
				for each (var subFile:File in arr) 
				{
					var fileName:String = subFile.name;
					if(fileName == ".svn")
					{
						continue;
					}
					if(subFile.isDirectory)
					{
						var subFileArr:Array = getFolderFileListByExtendDic(subFile,extendNames);
						fileArr = fileArr.concat(subFileArr);
					}else
					{
						if(extendNames == null || extendNames.hasOwnProperty(subFile.extension))
						{
							fileArr.push(subFile);
						}
					}
				}
			}
			return fileArr;
		}
		/**
		 * 
		 * @param file 文件夹
		 * @param extendNames 如 Vector.<String>(["png","jpg"])
		 * @return 
		 * 
		 */		
		public static function getFolderFileListByExtendList(file:File,extendNames:Vector.<String> = null):Array
		{
			var extendNameObj:Dictionary;
			if(extendNames)
			{
				extendNameObj = new Dictionary();
				for each(var ext:String in extendNames)
				{
					extendNameObj[ext] = true;
				}
			}
			return getFolderFileListByExtendDic(file,extendNameObj);
		}
		public static function getFolderList(file:File):Array
		{
			var fileArr:Array = [];
			if(file.isDirectory)
			{
				var arr:Array = file.getDirectoryListing();
				for each (var subFile:File in arr) 
				{
					var fileName:String = subFile.name;
					if(fileName == ".svn")
					{
						continue;
					}
					if(subFile.isDirectory)
					{
						fileArr.push(subFile);
					} 
				}
			}
			return fileArr;
		}
		
		public static function exists(path:String):Boolean
		{
			var file:File = new File(path);
			return file.exists;
		}
	}
}