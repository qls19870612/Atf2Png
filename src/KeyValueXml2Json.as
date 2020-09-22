package
{
	import flash.filesystem.File;
	
	import game.uiRef.util.FileOperationer;

	public class KeyValueXml2Json
	{
		public function KeyValueXml2Json()
		{
		}
		public static  function start():void
		{
			var path:String = "D:/client_workspace/SummonWebBuilder1/resources/en/lang_client";
			var files:Vector.<File> = FileOperationer.getAllFiles(new File(path),"xml");
			var testxml:XML =  <language name="arena">
				<language key="jifen" value="积分"/>
				<language key="paiming" value="排名"/>
				<language key="shenglv" value="胜率"/>
				<language key="zhankuang" value="本周战况"/>
				<language key="wanchengPVP" value="已完成PVP战斗："/>
				<language key="lingjiangPVP" value="领奖还需战斗："/>
				<language key="yujijiangli" value="本周预计奖励："/>
				<language key="shijian" value="截止时间："/>
				<language key="guize" value="查看规则"/>
				<language key="paihangbang" value="排行榜"/>
				<language key="xunzhang" value="荣誉勋章："/>
			</language>;
			for each (var file:File in files) 
			{
				var xml:XML = FileOperationer.readXML(file.nativePath);
				var child:XMLList = xml.child("language");
				var obj:Object = {};
				for (var i:int = 0,ilen:int=child.length(); i < ilen; i++) 
				{
					var item:XML = child[i];
					obj[item.@key] = item.@value.toString();
					
				}
				var json:String = JSON.stringify(obj);
				FileOperationer.writeText(json,file.nativePath.replace(".xml",".json"));
				
			}
			
			
			
		}
	}
}