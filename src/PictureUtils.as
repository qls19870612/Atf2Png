package
{
	import flash.filesystem.File;

	public class PictureUtils
	{
		private var packager:PicturePackager;

		private var png2AtfUtils:Png2AtfWithXmlUtils;

		private var folders:Vector.<File>;
		private var _totalPackageCount:uint;

		private var toFolder:File;
		public static var recoverFile:Boolean;

		private var currPackFolder:File;
	
		public function PictureUtils()
		{
			this.packager = new PicturePackager();
			png2AtfUtils = new Png2AtfWithXmlUtils(onToAtfComplete,onToAtfError,onToAtfProgress);
			 
		}
		
		protected function onToAtfComplete():void
		{
			startPackage();
		}
		
		protected function onToAtfError(info:String):void
		{
			onPickImageError("转换成atf时发生错:" + info+ "=>file:" + png2AtfUtils.bdFile.nativePath);	
		}
		private function onToAtfProgress(info:String):void
		{
			Atf2Png.THIS.addInfo(info);
		}
		public function packagePic(url:String,toFolder:File):void
		{
			this.toFolder = toFolder;
			var file:File = new File(url);
			if(!file.exists||!file.isDirectory){
				onPickImageError("文件目录不存在:" + url);
				return;
			}
			folders = new Vector.<File>;
			findNeedPackFolders(file,folders);
			
			_totalPackageCount = folders.length;
			if(_totalPackageCount==0){
				onPickImageError("没有打到需要打包的文件夹");
				return;
			}
			if(!toFolder.exists){
				toFolder.createDirectory();
			}
//			packager.packPic(new File(url),onCompleteCreateImage);
			startPackage();
		
		}
		public function packDir(file:File,level:int=1):void{
			if(!file.isDirectory){
				onPickImageError("打包的必需是一个目录");
				return ;
			}
			folders = new Vector.<File>;
			findFolder(file,folders,level,0);
			if(folders.length<=0){
				onPickImageError("没有找到需要打包的目录");
				return;
			}
			
			startPackage();
		}
		
		private function findFolder(file:File,toFolders:Vector.<File>, level:int,currLevle:int):void
		{
			currLevle++;
			if(level==currLevle){
				toFolders.push(file);
				return;
			}
			if(currLevle > level)return;
			var list:Array = file.getDirectoryListing();
			for (var i:int = 0,ilen:int=list.length; i < ilen; i++) 
			{
				var f:File = list[i];
				if(f.isDirectory){
					findFolder(f,toFolders,level,currLevle);
				}
			}
			
		}
		private function startPackage():void
		{
			if(folders.length==0){
				onInfoFun("打包完成");
				return;
			}
			currPackFolder = folders.pop();
			
			
			packager.packPic(currPackFolder,onCompleteCreateImage,onPickImageError,onInfoFun,getToFolder());
		}
		
		private function getToFolder():File
		{
			var toFile:File;
			if (toFolder) 
			{
				toFile = toFolder;
			}
			else{
				toFile = currPackFolder.parent;
			}
			return toFile;
		}
		private function onPickImageError(...args):void
		{
			Atf2Png.THIS.addError(args.join(","));
			startPackage();
		}
		private function onInfoFun(...args):void
		{
			Atf2Png.THIS.addInfo(args.join(","));
		}
		/**
		 * 找到没有子目录，且有png图片的目录，进行打包
		 */
		private function findNeedPackFolders(folder:File,folders:Vector.<File> = null):Vector.<File>
		{
			var files:Array = folder.getDirectoryListing();
			if(files.length==0){
				return folders;
			}
			var hasFolder:Boolean = false;
			var hasPng:Boolean = false;
			for (var i:int = 0,ilen:int=files.length; i < ilen; i++) 
			{
				var f:File = files[i];
				if (f.isDirectory) 
				{
					findNeedPackFolders(f,folders);
					hasFolder = true;
				}
				else if(f.extension=="png"){
					hasPng = true;
				}
				
			}
			if(!hasFolder&&hasPng){
				
				if(!recoverFile){
					//不覆盖文件，又存在文件，则不进行打包
					
					var resolvePath:File = getToFolder().resolvePath(folder.name + ".png");
					if (resolvePath.exists) 
					{
						return folders;
					}
				}
				//没有子目录，放入列表，准备打包
				if(folders==null){
					folders = new Vector.<File>();
				}
				folders.push(folder);
			}
			
			return folders;
			
		}
		
		private function onCompleteCreateImage(imageUrl:String,xml:String):void
		{
			png2AtfUtils.convert(new File(imageUrl),xml,getToFolder());
		}
	}
}