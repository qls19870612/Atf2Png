package game.uiRef.util
{
	import flash.utils.Dictionary;

	/**
	 * @author liangsong
	 * 创建时间:2016-8-10 下午7:48:38
	 * 
	 */
	public class TemplateUtil
	{
		public function TemplateUtil()
		{
		}
		public static function converArrToDictionary(arr:Array, dataFiled:String):Dictionary
		{
			var ret:Dictionary;
			if (arr) 
			{
				ret = new Dictionary();
				var ilen:int = arr.length;
				for (var i:int = 0; i < ilen; i++) 
				{
					var obj:Object = arr[i];
					ret[obj[dataFiled]] = obj;
				}
			}
			return ret;
		}
	}
}