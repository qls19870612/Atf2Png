package com.loaders
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import game.uiRef.util.FunctionUtils;

	public class DisplayLoader extends Loader implements ILoader
	{
		private var _url:String;
		private var _loadErrorFun:Function;
		private var _loadCompleteFun:Function;
		private var _loadInfo:*;
		 
		public function DisplayLoader(url:String="")
		{
			super();
			this.url=url; 
			
		}

		public function get url():String
		{
			return _url;
		}

		public function set url(value:String):void
		{
			if (value == _url)
			{
				return;
			}
			_url=value; 
			if (!_url)
			{
				return;
			}
			contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
//			contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);
			contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoErrorHandler);
//			var context:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
//			context.allowCodeImport = true;
//			context.allowLoadBytesCodeExecution = true;
			load(new URLRequest(_url));
		}

		override public function loadBytes(bytes:ByteArray, context:LoaderContext=null):void
		{
			contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
			super.loadBytes(bytes, context);
		}


		protected function onIoErrorHandler(event:IOErrorEvent):void
		{
			var loadErrFun:Function = loadErrorFun;
			removeEvents();
			
			trace(this.url,"this.url->DisplayLoader.onIoErrorHandler()");
			trace(event, "event->DisplayLoader.onIoErrorFun()");
			this.loadCompleteFun = null;
			this.loadErrorFun = null;
			unloadAndStop();
			FunctionUtils.callFun(loadErrFun, this);
		}

		private function removeEvents():void
		{
			contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompleteHandler);
//			contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgressHandler);
			contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIoErrorHandler);
			

//			loadCompleteFun=null;
//			loadErrorFun=null;
		}
//
//		protected function onProgressHandler(event:ProgressEvent):void
//		{
//			FunctionUtils.callFun(loadProgressFun, this);
//
//		}


		protected function onCompleteHandler(event:Event):void
		{ 
			var loadCompFun:Function = loadCompleteFun;
			
			removeEvents();
			FunctionUtils.callFun(loadCompFun, this);
//			this.addEventListener(Event.ENTER_FRAME,onNextFrame);
		}
		
		protected function onNextFrame(event:Event):void
		{
			var loadCompFun:Function =this.loadCompleteFun;
			this.loadCompleteFun = null;
			this.loadErrorFun = null;
			this.removeEventListener(Event.ENTER_FRAME,onNextFrame);
			FunctionUtils.callFun(loadCompFun, this);
		}
		
	 
		
		public function stop():void
		{
			removeEvents();

		}

		public static function getBitmapData(domain:ApplicationDomain, className:String):BitmapData
		{
			if (!domain.hasDefinition(className))
			{
				return null;
			}
			var clazz:Class;
			clazz=domain.getDefinition(className) as Class;

			return new clazz(0, 0) as BitmapData;

		}
 
		
		public function set loadCompleteFun(fun:Function):void
		{
			_loadCompleteFun = fun;
		}
		
		public function get loadCompleteFun():Function
		{
			return _loadCompleteFun;
		}
		
		public function set loadErrorFun(fun:Function):void
		{
			_loadErrorFun = fun;
		}
		
		public function get loadErrorFun():Function
		{
			return _loadErrorFun;
		}
		
		public function set loadInfo(value:*):void
		{
			_loadInfo = value;
		}
		
		public function get loadInfo():*
		{
			return _loadInfo;
		}
		
		
	}
}
