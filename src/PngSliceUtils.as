package
{
	import com.loaders.LoaderItemInfo;
	import com.loaders.QueueEvent;
	import com.loaders.QueueLoader;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	
	import game.uiRef.util.FileOperationer;
	
	public class PngSliceUtils
	{
		private static const imageAndXmlPath:String = "D:/SVN/client/sourceCode/SummonWorld2/resources/zhCN/ATF/pc/assets/atlasATF";
		private var options:PNGEncoderOptions = new PNGEncoderOptions();
		public function PngSliceUtils()
		{
		}
		public function slicePng():void
		{
			
			var xmlDic:Dictionary = getXmlDic();
			var file:File = new File(imageAndXmlPath);
			var queueLoader:QueueLoader = new QueueLoader();
			queueLoader.addEventListener(QueueEvent.ITEM_COMPLETE,onLoadItem);
			queueLoader.addEventListener(QueueEvent.QUEUE_COMPLETE,onLoadAll);
			var getDirectoryListing:Vector.<File> = FileOperationer.getAllFiles(file,"png");
			
			for (var i:int = 0; i < getDirectoryListing.length; i++) 
			{
				var f:File = getDirectoryListing[i];
			 
				queueLoader.addSignalRes(f.nativePath,xmlDic);
				
			}
			
		}
		protected function onLoadItem(event:QueueEvent):void
		{
			var lii:LoaderItemInfo = event.loaderItemInfo;
			var xmlDic:Dictionary = lii.data as Dictionary;
			var bitmap:Bitmap = lii.displayLoader.content as Bitmap;
			var bd:BitmapData = bitmap.bitmapData;
			var fileName:String = lii.name;
			var f:File = new File(lii.url);
			var subImageFolder:File = f.parent.resolvePath(fileName);
			if(!subImageFolder.exists){
				subImageFolder.createDirectory();
			}
			var file:File = new File(lii.url);
			var xmlPath:String = file.parent.parent.resolvePath(lii.name + ".xml").nativePath;
			var vect:Vector.<Rect> = xmlDic[xmlPath];
			var repeateInfo:String = "";
			var dic:Dictionary = new Dictionary;
			for (var i:int = 0,ilen:int=vect.length; i < ilen; i++) 
			{
				var rect:Rect = vect[i];
				var key:String = rect.x +"_"+ rect.y;
				if(dic.hasOwnProperty(key)){
					var oldRect:Rect = dic[key];
					//						trace("================" + fileName);
					//						
					//						trace(oldRect.subImageName,"oldRect.subImageName->Atf2Png.testXml()");
					//						trace(rect.subImageName,"item.subImageName->Atf2Png.testXml()");
					//						var emptyImageFolder:File = subImageFolder(rect.subImageName + "__" + oldRect.subImageName);
					//						emptyImageFolder.createDirectory();
					repeateInfo+=rect.subImageName + "=" + oldRect.subImageName + "\r\n";
					
					
				}
				else{
					dic[key] = rect;
					
					createImg(rect,bd,subImageFolder);
				}
				
			}
			if(repeateInfo){
				Atf2Png.THIS.addInfo(repeateInfo);
				FileOperationer.writeText(repeateInfo,subImageFolder.resolvePath("repeat.txt").nativePath);
			}
			
			
			
			
		}
		private function createImg(rect:Rect, bd:BitmapData,subImageFolder:File):void
		{
			var small:BitmapData = new BitmapData(rect.w,rect.h,true,0);
			var m:Matrix = new Matrix();
			m.translate(-rect.x,-rect.y);
			small.draw(bd,m);
			var writeBd:BitmapData;
			if(rect.fw>0){
				var bg:BitmapData = new BitmapData(rect.fw,rect.fh,true,0);
				m.identity();
				m.translate(-rect.fx,-rect.fy)
				bg.draw(small,m);
				writeBd = bg;
				
			}
			else
			{
				writeBd = small;
			}
			var resolvePath:File = subImageFolder.resolvePath(rect.subImageName);
			if(!resolvePath.parent.exists){
				resolvePath.parent.createDirectory();
			}
			var bytes:ByteArray = writeBd.encode(writeBd.rect,options);
			FileOperationer.writeFile(resolvePath.nativePath,bytes);
			trace("写入文件 resolvePath.nativePath:" + resolvePath.nativePath);
			
		}
		protected function onLoadAll(event:QueueEvent):void
		{
			Alert.show("png已经全部分割完成");
			
		}
		
		
		private function getXmlDic():Dictionary
		{
			var dic:Dictionary = new Dictionary();
			var xmlFolder:String =imageAndXmlPath;
			var file:File = new File(xmlFolder);
			var getDirectoryListing:Vector.<File> = FileOperationer.getAllFiles(file,"xml");
			 
			for (var i:int = 0; i < getDirectoryListing.length; i++) 
			{
				var f:File = getDirectoryListing[i];
			 
				try{
					var vect:Vector.<Rect> = readXmlToVectory(f);
				 
					dic[f.nativePath] = vect;
				}
				catch(e:Error){
					var getStackTrace:String = e.getStackTrace();
					Atf2Png.THIS.addError(getStackTrace);
				}
				
			}
			
			return dic;
		}
		
		private function readXmlToVectory(f:File):Vector.<Rect>
		{
			var vect:Vector.<Rect> = new Vector.<Rect>;
			var readFile:XML = FileOperationer.readXML(f.nativePath);
			var children:XMLList = readFile.children();
			var len:int = children.length();
			
			for (var j:int = 0; j < len; j++) 
			{
				var item:XML = children[j];
				
				vect.push(new Rect(item));
				
			}
			return vect;
		}
		
		private function testXml():void
		{
			var getXmlDic2:Dictionary = getXmlDic();
			for (var dicKey:String in getXmlDic2) 
			{
				//					var readXmlToVectory2:Vector.<Rect> = readXmlToVectory(new File("D:/SVN/client/sourceCode/SummonWorld2/resources/zhCN/ATF/pc/assets/atlasATF/atlasATF/preload/cardSmall1.xml"));
				//					trace(readXmlToVectory2.length,"readXmlToVectory2.length->Atf2Png.testXml()");
				var dic:Dictionary = new Dictionary();
				var readXmlToVectory2:Vector.<Rect> = getXmlDic2[dicKey];
				for (var i:int = 0,ilen:int=readXmlToVectory2.length; i < ilen; i++) 
				{
					var item:Rect = readXmlToVectory2[i];
					var key:String = item.x +"_"+ item.y;
					if(dic.hasOwnProperty(key)){
						var oldRect:Rect = dic[key];
						trace("================" + dicKey);
						
						trace(oldRect.subImageName,"oldRect.subImageName->Atf2Png.testXml()");
						trace(item.subImageName,"item.subImageName->Atf2Png.testXml()");
						
					}
					else{
						dic[key] = item;
					}
					
				}
				
			}
			
			
			
			
		}
		
	}
}