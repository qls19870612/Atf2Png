package game.uiRef.util
{
	import flash.events.Event;
	import flash.filesystem.File;

	public class MyFile extends File
	{

 

		public function get dataObj():*
		{
			return _dataObj;
		}

		public function set dataObj(value:*):void
		{
			_dataObj = value;
		}

		private var _openCallBackFun:Function;

		private var _nativePath:String;
		private var _dataObj:*;

		public function MyFile(path:String=null)
		{
			super(path);

		}

		override public function get nativePath():String
		{
			if (_nativePath == null)
			{
				_nativePath=super.nativePath.replace(/\\/g, "\/");
			}
			return _nativePath;
		}

		override public function set nativePath(value:String):void
		{
			value=value.replace(/\\/g, "\/");
			super.nativePath=value;
			_nativePath=value;
		}


		public function openImage(openCallBackFun:Function, title:String="请选择图片"):void
		{
			_openCallBackFun=openCallBackFun;
			browseForOpen(title, [FileFilterUtils.images]);
			addOpenFileListener();
		}

		public function openXML(openCallBackFun:Function, title:String="请选择XML"):void
		{
			_openCallBackFun=openCallBackFun;
			browseForOpen(title, [FileFilterUtils.xmlFilter]);
			addOpenFileListener();
		}
		public function openFolder(openCallBackFun:Function,title:String="请选择一个目录"):void
		{
			_openCallBackFun=openCallBackFun;
			browseForDirectory(title)
			addOpenFileListener();
		}
		private function addOpenFileListener():void
		{
			this.addEventListener(Event.SELECT, onSelectedFileFun);
			this.addEventListener(Event.CANCEL, onCancelSelectFun);
		}


		protected function onCancelSelectFun(event:Event):void
		{
			removeOpenFileListener();
		}

		private function removeOpenFileListener():void
		{
			this.removeEventListener(Event.SELECT, onSelectedFileFun);
			this.removeEventListener(Event.CANCEL, onCancelSelectFun);
		}

		protected function onSelectedFileFun(event:Event):void
		{
			removeOpenFileListener();
			FunctionUtils.callFun(_openCallBackFun, this);
		}
	}
}
