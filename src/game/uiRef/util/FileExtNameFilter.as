package game.uiRef.util
{
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	public class FileExtNameFilter implements Filter
	{

		private var extNameDic:Dictionary = new Dictionary;
		public function FileExtNameFilter(extName:String)
		{
			var split:Array = extName.split(",");
			for (var i:int = 0,ilen:int=split.length; i < ilen; i++) 
			{
				extNameDic[split[i]]=true;
			}
			
		}
		
		public function accept(file:File):Boolean
		{
			return file.extension in extNameDic;;
		}
	}
}