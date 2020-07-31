package  game.uiRef.util
{

	public class FunctionUtils
	{
		public function FunctionUtils()
		{
		}

		public static function callFun(fun:Function, ... args):void
		{
			if (fun == null)
			{
				return;
			}
			 
				fun.apply(null, args);
			 
		}

	}
}
