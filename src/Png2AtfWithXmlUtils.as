package
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.EventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import mx.logging.Log;
	
	import game.tool.LogWriter;
	import game.uiRef.util.FileOperationer;
	import game.uiRef.util.FunctionUtils;
 
	public class Png2AtfWithXmlUtils extends EventDispatcher
	{ 

		private var _bdFile:File;

		private var xml:String;

		private var _atfFile:File;
		private var _mergeFile:File;//合并后的文件


		private var onCompalteFun:Function;

		private var onErrorFun:Function;
		private var onOutputFun:Function;
		public function Png2AtfWithXmlUtils(onCompalteFun:Function,onErrorFun:Function,onOutputFun:Function)
		{
			this.onErrorFun = onErrorFun;
			this.onCompalteFun = onCompalteFun;
			this.onOutputFun = onOutputFun;
		}
		
		public function get bdFile():File
		{
			return _bdFile;
		}

		public function convert(bdFile:File,xml:String,toFolder:File):void
		{
			this.xml = xml;
			
			this._bdFile = bdFile;
			var binFolder:File = toFolder.resolvePath("BIN_ATF");
			if(!binFolder.exists)binFolder.createDirectory();
			this._atfFile =  binFolder.resolvePath( bdFile.name.replace( ".png",".atf"));
			this._mergeFile = binFolder.resolvePath(_bdFile.name.replace(".png",".bin"));
			 
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
		
		protected function onOutput(event:ProgressEvent):void
		{
			var standardOutput:IDataInput = (event.target as NativeProcess).standardOutput;
			var tmp:String = standardOutput.readMultiByte(standardOutput.bytesAvailable,"gb2312");
			trace(tmp,"tmp->Png2AtfUtils.onOutput()");
			
			FunctionUtils.callFun(onOutputFun,tmp);
			
		}
		
		protected function onError(event:ProgressEvent):void
		{
			event.target.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onError);
			event.target.removeEventListener(NativeProcessExitEvent.EXIT, atfComplete);
			event.target.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutput);
			var tmp:String = (event.target as NativeProcess).standardError.readMultiByte(event.target.standardError.bytesAvailable,"gb2312");
			FunctionUtils.callFun(onErrorFun,tmp);
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
			mergeAtfAndXml();
		
		}
		
		protected function mergeAtfAndXml():void
		{
			if (!_atfFile.exists) 
			{
				FunctionUtils.callFun(onErrorFun,"打包完成后居然找不到atf文件:" + _atfFile.nativePath);
				return;	
			}
			var atfFileBytes:ByteArray = FileOperationer.readFile(_atfFile.nativePath);
			
		 
			var mergeFileBytes:ByteArray = new ByteArray();
			mergeFileBytes.writeUnsignedInt(9999999);
			mergeFileBytes.writeUnsignedInt(atfFileBytes.length);
			mergeFileBytes.writeBytes(atfFileBytes);
			
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(xml);
			mergeFileBytes.writeUnsignedInt(bytes.length);
			mergeFileBytes.writeMultiByte(xml,"utf-8");
			FileOperationer.writeFile(_mergeFile.nativePath,mergeFileBytes);
			Atf2Png.addLog("mergeAtfAndXml=" + _atfFile.nativePath + " atfLen:" + atfFileBytes.length + " xmlLen:" + bytes.length); 
			
			FunctionUtils.callFun(onCompalteFun);
		}
	}
}