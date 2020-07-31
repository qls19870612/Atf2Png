package
{
	import com.loaders.LoaderItemInfo;
	import com.loaders.QueueEvent;
	import com.loaders.QueueLoader;
	import com.splice.BitmapSplicer;
	import com.splice.BitmapTrimmer;
	import com.splice.FreeRectangleChoiceHeuristic;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.graphics.codec.PNGEncoder;
	
	import game.uiRef.util.FileOperationer;
	import game.uiRef.util.FunctionUtils;
	import game.uiRef.util.MyRectange;
	import game.uiRef.util.StringUtils;

	public class PicturePackager
	{
		public function PicturePackager(){
			
		}
		private var _isLoading:Boolean = false;

		private var fileNames:Vector.<String>;

		private var fileMap:Dictionary;
		private var pngFrameRectMap:Dictionary;
		private var options:PNGEncoderOptions = new PNGEncoderOptions();
		private var _currFolder:File;

		private var onComplateFun:Function;

		private var toFolder:File;
		private var onErrorFun:Function;

		private var infoFun:Function;
		public static var flashCut:Boolean = true;
		public  function packPic(folder:File,onComplateFun:Function,onErrorFun:Function,infoFun:Function,toFolder:File):void
		{
			this.infoFun = infoFun;
			this.toFolder = toFolder;
			this.onComplateFun = onComplateFun;
			this.onErrorFun = onErrorFun;
			
			
			if (!folder.exists||!folder.isDirectory) 
			{
				FunctionUtils.callFun(onErrorFun,folder.exists,  folder.isDirectory,folder.nativePath,"folder.exists,folder.isDirectory->PicturePackager.packPic()")
				return;	
			}
			
			_currFolder = folder;
			if (_isLoading) 
			{
				
				FunctionUtils.callFun(onErrorFun,_isLoading,folder.nativePath,"_isLoading->PickPackage.packPic()1");
				
				return;
			}
			
			var subFiles:Vector.<File> = FileOperationer.getAllFiles(_currFolder,"png");
			
			 
			fileNames = new Vector.<String>();
			fileMap = new Dictionary();
			pngFrameRectMap = new Dictionary();
			var queueLoader:QueueLoader = new QueueLoader(4);
			
			for (var i:int = 0,ilen:int=subFiles.length; i < ilen; i++) 
			{
				var f:File = subFiles[i];
			 
			 
				_isLoading = true;
				var shortName:String = getShortName(f.nativePath);
				
				fileNames.push(shortName);
				
				queueLoader.addSignalRes(f.nativePath);
			}
			
			if (!_isLoading) 
			{
				FunctionUtils.callFun(onErrorFun,_isLoading,folder.nativePath,"_isLoading->PickPackage.packPic()2");
				return;
			}
			queueLoader.addEventListener(QueueEvent.ITEM_COMPLETE,onItemComplete);
			queueLoader.addEventListener(QueueEvent.QUEUE_COMPLETE,onAllLoaded);
			
			
		}
		
		private function getShortName(nativePath:String):String
		{
			nativePath = nativePath.replace(/\\/g,"/");
			var currFileUrl:String = _currFolder.nativePath.replace(/\\/g,"/") + "/"; 
			
			var shortName:String = nativePath.replace(currFileUrl,"");
			shortName = shortName.replace(".png","");
			return shortName;
		}
		
		protected  function onAllLoaded(event:QueueEvent):void
		{
			var queueLoader:QueueLoader = event.currentTarget as QueueLoader;
			queueLoader.removeEventListener(QueueEvent.ITEM_COMPLETE,onItemComplete);
			queueLoader.removeEventListener(QueueEvent.QUEUE_COMPLETE,onAllLoaded);
			_isLoading = false;
			var locationDic:Dictionary = new Dictionary();
			fileNames.sort(function(a:String,b:String):int{
				 var rect1:MyRectange = pngFrameRectMap[a];
				 var rect2:MyRectange = pngFrameRectMap[b];
				return rect2.wh - rect1.wh;
				
			});
			var type:int = -1;
			for (var i:int = 0,ilen:int=FreeRectangleChoiceHeuristic.ContactPointRule; i < ilen; i++) 
			{
				var checkMinFitBin:Boolean = BitmapSplicer.checkMinFitBin(fileNames,fileMap,false,i);
				if(checkMinFitBin){
					type = i;
					break;
				}
			}
			
			if (type==-1) 
			{
				FunctionUtils.callFun(onErrorFun,_currFolder.nativePath,"path->PicturePackager.onAllLoaded()");
				
				return;
			}
			FunctionUtils.callFun(infoFun,type,"type->PicturePackager.onAllLoaded()");
			var bigBd:BitmapData = BitmapSplicer.createSplicedBitmap(fileMap,fileNames,locationDic,false,type);
			
			var encode:ByteArray;
			encode = bigBd.encode(bigBd.rect,options);
//			var pNGEncoder:PNGEncoder = new PNGEncoder();
//			encode = pNGEncoder.encode(bigBd);
			var newFileUrl:String = toFolder.resolvePath( _currFolder.name + ".png").nativePath;
			FileOperationer.writeFile(newFileUrl,encode);
			var repeat:File = _currFolder.resolvePath("repeat.txt");
			var repeatedDic:Dictionary = null;
			if (repeat.exists) 
			{
				repeatedDic = getRepeatDic(repeat);
			}
			 	
			var xml:XML = <TextureAtlas imagePath={_currFolder.name+".png"}></TextureAtlas>;
			for each (var key:String in fileNames) 
			{
				var item:Rectangle = locationDic[key];
				var itemXml:XML
				
				;var frame:Rectangle = pngFrameRectMap[key];
				if(item.width == frame.width && item.height==frame.height){
					itemXml = <SubTexture name={key} x= {item.x} y={item.y} width={item.width} height={item.height}/>
				}
				else{
					itemXml = <SubTexture name={key} x= {item.x} y={item.y} width={item.width} height={item.height} frameX={-frame.x} frameY={-frame.y} frameWidth={frame.width} frameHeight={frame.height}/>	
				}
				xml.appendChild(itemXml);
				if(repeatedDic&& key in repeatedDic){
					var cloneXml:XML = new XML(itemXml.toXMLString());
					cloneXml.@name = repeatedDic[key];
					xml.appendChild(cloneXml);
				}
				
			}
			var toXml:String = xml.toXMLString();
			FileOperationer.writeText(toXml,_currFolder.resolvePath(_currFolder.name+".xml").nativePath);
			
			onComplateFun(newFileUrl,toXml);
			
			 
		}
		
		private function getRepeatDic(repeat:File):Dictionary
		{
			var readTxt:String = FileOperationer.readTxt(repeat.nativePath);
			var replace:String = readTxt.replace(/\\\\r/g,"");
			var split:Array = replace.split("\n");
			var dic:Dictionary = new Dictionary;
			for (var i:int = 0,ilen:int=split.length; i < ilen; i++) 
			{
				
				var item:String = split[i];
				
				var fileNames:Array = item.split("=");
				if(fileNames.length!=2)continue;
				var name1:String = fileNames[1];
				var name0:String = fileNames[0];
				name1= name1.replace(".png","");
				name0= name0.replace(".png","");
				name0 = StringUtils.trim(name0);
				name1 = StringUtils.trim(name1);
				dic[name1] = name0;
				
			}
			
			return dic;
		}
		
		protected  function onItemComplete(event:QueueEvent):void
		{
			var lii:LoaderItemInfo = event.loaderItemInfo;
			var bitmap:Bitmap = lii.displayLoader.content as Bitmap;
			var bd:BitmapData = bitmap.bitmapData;
			
			var mr:MyRectange = new MyRectange;
			var nbd:BitmapData;
			if(flashCut){
				var r:Rectangle = bd.getColorBoundsRect(0xFF000000, 0x00000000, false);
				if(r.x==0&&r.y==0&&r.width ==bd.width&&r.height==bd.height){
					nbd = bd;
				}
				else{
					if(r.width > 0&&r.height > 0){
						
						nbd = new BitmapData(r.width,r.height,true,0);
						var matrix:Matrix = new Matrix();
						matrix.tx = -r.x;
						matrix.ty = -r.y;
						nbd.draw(bd,matrix);
						r.width = bd.width;
						r.height = bd.height;
						
						mr.x = r.x;
						mr.y = r.y;
					}
					else{
						nbd = BitmapTrimmer.trimBitmap(bd,0,false,mr);
					}
					
				}
			}
			else
			{
				nbd = BitmapTrimmer.trimBitmap(bd,0,false,mr);
			}
			
		
			
			

			
			var shortName:String = getShortName(lii.url);
			mr.name = shortName;
			mr.wh = nbd.width *nbd.height;
			mr.width = bd.width;
			mr.height = bd.height;
			
			
 
			fileMap[shortName] = nbd;
		
			pngFrameRectMap[shortName] = mr;
			if(nbd!=bd){
				bd.dispose();
			}
			
			
		}
		
	}
}