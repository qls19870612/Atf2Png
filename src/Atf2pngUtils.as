package
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	
	import game.uiRef.util.FileOperationer;
	
	import starling.core.Starling;
	 
	public class Atf2pngUtils
	{
		private static const imageAndXmlPath:String = "D:/SVN/client/sourceCode/SummonWorld2/resources/zhCN/ATF/pc/assets/atlasATF";
		private var _starling:Starling;
		public function Atf2pngUtils(stage:Stage)
		{
			var _viewPort:Rectangle = new Rectangle(0, 0, 2048, 2048);
			_starling = new Starling(StarlingContent, stage, _viewPort, null, "auto", "baseline");
			_starling.enableErrorChecking = false;
			_starling.start();

		 
		}
		public function start():void{
						setTimeout(atf2png,1000);	
		}
		private function atf2png():void{
			 
			var file:File = new File(imageAndXmlPath);
			var getDirectoryListing:Vector.<File> = FileOperationer.getAllFiles(file,"atf");
 
			for (var i:int = 0; i < getDirectoryListing.length; i++) 
			{
				var f:File = getDirectoryListing[i];
			 
				toPng(f);
				
				
			}
			Alert.show("atf2png 完成" );
		}
		
		private function toPng(f:File):void
		{
			
			try{
				
				var readFile:ByteArray = FileOperationer.readFile(f.nativePath);
				var content:StarlingContent = _starling.root as StarlingContent;
				content.saveFile(readFile,f);
				trace("atf2png:" + f.nativePath);
				
			}
			catch(e:Error){
				var getStackTrace:String = e.getStackTrace();
				trace("atf2png:" + getStackTrace);
			}
		}
		
	 
		
	}
}