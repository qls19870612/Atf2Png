package
{
	import com.loaders.LoaderItemInfo;
	import com.loaders.QueueEvent;
	import com.loaders.QueueLoader;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import game.uiRef.util.FileOperationer;
	import game.uiRef.util.FunctionUtils;

	/**
	 * 单张图片转atf
	 */
	public class Png2AtfUtils
	{
		private var wattingConvertList:Vector.<File>;

		private var queueLoader:QueueLoader;
		private var _bdFile:File;
		private var compressor:PNGEncoderOptions;
		private var _isTempFile:Boolean;

		private var _toFolder:File;
		private var _atfFile:File;
		private var _imageWidth:int;
		private var _imageHeight:int;
		public function Png2AtfUtils()
		{
			compressor = new PNGEncoderOptions();
			wattingConvertList = new Vector.<File>;
			
			queueLoader = new QueueLoader(1);
			
		  
			queueLoader.addEventListener(QueueEvent.ITEM_COMPLETE,onItemComplete);
			queueLoader.addEventListener(QueueEvent.QUEUE_COMPLETE,onAllLoaded);
		}
		
		protected function onAllLoaded(event:QueueEvent):void
		{
			 onInfoFun("png2atf 全部处理完毕");
			
		}
		
		protected function onItemComplete(event:QueueEvent):void
		{
			queueLoader.pause =true;
			var lii:LoaderItemInfo = event.loaderItemInfo;
			var bitmap:Bitmap = lii.displayLoader.content as Bitmap;
			var bd:BitmapData = bitmap.bitmapData;
			
			if(lii.extName=="png"&&isEnableSize(bd.width)&&isEnableSize(bd.height)){
				_bdFile = new File(lii.url);
				_isTempFile = false;
			}
			else{
				var enableBd:BitmapData = new BitmapData(getEnableSize(bd.width),getEnableSize(bd.height),true,0);
				enableBd.draw(bd);
				var encode:ByteArray = enableBd.encode(enableBd.rect,compressor);
				_isTempFile = true;
				_bdFile = File.applicationStorageDirectory.resolvePath("tmp/" + lii.name +".png");
				if (!_bdFile.parent.exists) 
				{
					_bdFile.parent.createDirectory();
				}
				FileOperationer.writeFile(_bdFile.nativePath,encode);
			}
			if(!_toFolder){
				_atfFile = new File(lii.url).parent.resolvePath("ATF/" + lii.name + ".rtf");
				if (!_atfFile.parent.exists) 
				{
					_atfFile.parent.createDirectory();
				}
				
			}
			else{
				_atfFile = _toFolder.resolvePath(lii.name + ".rtf");
			}
			_imageWidth = bd.width;
			_imageHeight = bd.height;
			
			bd.dispose();
			// 调用windows.exe工具生成atf格式文件
			var file:File = File.applicationDirectory;
			file = file.resolvePath("png2atf.exe");
			var na:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			na.executable = file;
			// 命令行参数
			na.arguments = pushATFArguments();
			
			
			// 运行程序
			var process:NativeProcess = new NativeProcess();
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onError);
			process.addEventListener(NativeProcessExitEvent.EXIT, atfComplete);
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,onOutput);
			process.start(na);
			process.closeInput();
			
		}
		
		private function getEnableSize(m:int):int
		{
			if (isEnableSize(m)) 
			{
				return m;
			}
			return 1<<(m.toString(2).length);
		}
		
		private function isEnableSize(m:int):Boolean
		{
			 
			if(m < 1) return false;
			var n:int = m & (m-1);
			return n == 0;
		}
		
		protected function onOutput(event:ProgressEvent):void
		{
			var standardOutput:IDataInput = (event.target as NativeProcess).standardOutput;
			var tmp:String = standardOutput.readMultiByte(standardOutput.bytesAvailable,"gb2312");
			trace(tmp,"tmp->Png2AtfUtils.onOutput()");
			
			onInfoFun(tmp);
			
		}
		
		protected function onError(event:ProgressEvent):void
		{
			event.target.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onError);
			event.target.removeEventListener(NativeProcessExitEvent.EXIT, atfComplete);
			event.target.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutput);
			var tmp:String = (event.target as NativeProcess).standardError.readMultiByte(event.target.standardError.bytesAvailable,"gb2312");
			onErroFun(tmp);
			checkRemoveTmpFile();
			queueLoader.pause = false;
		}
		
		private function checkRemoveTmpFile():void
		{
			if (_isTempFile) 
			{
				_bdFile.deleteFile();
				_isTempFile = false;
			}
		}
		/**
		 * 输入ATF的转换参数
		 * @param	fileName	String	输入输出的文件名字
		 * @return	Vector.<String>		参数的vector容器
		 * */
		private function pushATFArguments():Vector.<String>
		{
			var _args:Vector.<String> = new Vector.<String>;
			
			_args.push("-c");
			_args.push("d");
			_args.push("-r");
			
			_args.push("-i");
			trace(_bdFile.nativePath,"_bdFile.nativePath->Png2AtfUtils.pushATFArguments()");
			
			_args.push(_bdFile.nativePath);
			_args.push("-o");
			_args.push(_atfFile.nativePath);
			trace(_atfFile.nativePath,"_atfFile.nativePath->Png2AtfUtils.pushATFArguments()");
			
			return _args;
		}
		
		/**
		 * 完成atf转换
		 * */
		private function atfComplete(e:NativeProcessExitEvent):void
		{
			e.target.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onError);
			e.target.removeEventListener(NativeProcessExitEvent.EXIT, atfComplete);
			e.target.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutput);
			checkAddWhToAtf();
			checkRemoveTmpFile();
			queueLoader.pause = false;
			
		}
		
		private function checkAddWhToAtf():void
		{
			var atfFile:ByteArray = FileOperationer.readFile(_atfFile.nativePath);
			var rtfFile:ByteArray = new ByteArray();
			rtfFile.writeUnsignedInt(9999998);
			rtfFile.writeShort(_imageWidth);
			rtfFile.writeShort(_imageHeight);
			rtfFile.writeBytes(atfFile);
			FileOperationer.writeFile(_atfFile.nativePath,rtfFile);
			atfFile.clear();
			rtfFile.clear();
		}
		private function onInfoFun(...args):void
		{
			Atf2Png.THIS.addInfo(args.join(","));
		}
		private function onErroFun(...args):void
		{
			Atf2Png.THIS.addError(args.join(","));
		}
		public function convert(bdFile:File,toFolder:File):void
		{
			this._toFolder = toFolder;
			var files:Vector.<File> = FileOperationer.getAllFiles(bdFile,"png,jpg");
			if (files.length <=0) 
			{
				onErroFun("没有找到可以打包的png图片 path:" + bdFile.nativePath);
				return;
			}
			for (var i:int = 0,ilen:int=files.length; i < ilen; i++) 
			{
				queueLoader.addSignalRes(files[i].nativePath);
			}
			
				
		}
	}
}