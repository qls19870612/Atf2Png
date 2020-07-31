package game.tool
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class LogWriter extends Object
	{ 

		public function LogWriter()
		{
	 
		}

 

		public static function removeMoreLog(nativeUrl:String,isDir:Boolean = false):void
		{

			var saveDate:int=10; //保存10天
			var saveDateTime:int=3600000 * 24 * saveDate;
			var date:Date=new Date;
			date.setTime(date.time - saveDateTime);
			var parentFile:File=new File(nativeUrl);
			if (parentFile.exists)
			{
				var fileArr:Array=parentFile.getDirectoryListing();
				for (var i:int=0, len:int=fileArr.length; i < len; i++)
				{
					var subFile:File = fileArr[i];
					if (subFile.isDirectory != isDir) 
					{
						continue;
					}
					var fileUrl:String=(subFile).url;
					var dotIndex:int = fileUrl.lastIndexOf(".");
					if (dotIndex == -1) 
					{
						dotIndex = fileUrl.length;	
					}
					var tempUrl:String=fileUrl.substring(fileUrl.lastIndexOf("/") + 1, dotIndex);
					if (tempUrl.length == 8 && int(tempUrl) > 0)
					{

						var dat:Date=new Date(int(tempUrl.substr(0, 4)), int(tempUrl.substr(4, 2)) - 1, int(tempUrl.substr(6)));
					
						if (date.time > dat.time)
						{
							var file:File = new File((fileArr[i] as File).nativePath);
							if (file.exists) 
							{
								file.moveToTrashAsync();
							}
						}
					}

				}
			}

		}

		public static function writeToHistoryFile(nativeUrl:String, str:String,extName:String=".txt"):void
		{
			var dateStr:String=getDateStr(new Date);

			var url:String="/log/" + dateStr + extName;
			var file:File;
			var fullUrl:String=nativeUrl + url;

			file=new File(fullUrl);
			var fileStream:FileStream=new FileStream();
			if (!file.exists)
			{
				file.resolvePath(file.url);
				fileStream.open(file, FileMode.WRITE);
			}
			else
			{
				fileStream.open(file, FileMode.APPEND);
			}

			fileStream.writeMultiByte(str + File.lineEnding, "utf-8");
			fileStream.close();
		}

		public static function getDateStr(date:Date):String
		{

			var dateStr:String=date.fullYear.toString();
			var month:String=date.month > 8 ? (date.month + 1).toString() : "0" + (date.month + 1);
			var date1:String=date.date > 9 ? date.date.toString() : "0" + date.date;
			dateStr=dateStr + month + date1;
			return dateStr;
		}

		public static function getTimeStr(date:Date,spliter:String=":"):String
		{
			var hourStr:String=date.hours > 9 ? date.hours.toString() : "0" + date.hours;
			var minStr:String=date.minutes > 9 ? date.minutes.toString() : "0" + date.minutes;
			var secondStr:String=date.seconds > 9 ? date.seconds.toString() : "0" + date.seconds;
			hourStr=hourStr + spliter + minStr + spliter + secondStr;
			return hourStr;
		}
	}
}
