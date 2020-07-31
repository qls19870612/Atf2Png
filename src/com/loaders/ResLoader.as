package com.loaders
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import game.uiRef.util.FunctionUtils;

	public class ResLoader extends URLLoader implements ILoader
	{
		private var _url:String;
		private var urlRes:URLRequest;
		private var _loadCompleteFun:Function;
		private var _loadErrorFun:Function;
		private var _loadInfo:*;
 
		public function ResLoader(url:String="")
		{
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
				urlRes=null;
				return;
			}
//			trace(_url,"_url->ResLoader.url()");
			
			this.dataFormat=URLLoaderDataFormat.BINARY;

			urlRes=new URLRequest(_url);

			this.load(urlRes);
			this.addEventListener(Event.COMPLETE, onLoadedFun);
			this.addEventListener(IOErrorEvent.IO_ERROR, onIoErrorFun);
		}



		protected function onIoErrorFun(event:IOErrorEvent):void
		{
			trace(event, "event->ResLoader.onIoErrorFun()");
			var loadErrFun:Function = this.loadErrorFun;
			removeEvents();
			FunctionUtils.callFun(loadErrFun, this);
		}

		private function removeEvents():void
		{
			this.removeEventListener(Event.COMPLETE, onLoadedFun);
			this.removeEventListener(IOErrorEvent.IO_ERROR, onIoErrorFun);
			
			try
			{
				this.close();
			}
			catch (error:Error)
			{

			}
			urlRes=null;
			loadCompleteFun=null;
			loadErrorFun=null;

		}

		protected function onLoadedFun(event:Event):void
		{
//			trace(loadCompleteFun,"loadCompleteFun->ResLoader.onLoadedFun()");
//			trace(this.loadInfo,"this.loadInfo->ResLoader.onLoadedFun()");
			var loadCompFun:Function = loadCompleteFun;
			removeEvents();
			FunctionUtils.callFun(loadCompFun, this);


		}

		public function stop():void
		{
			removeEvents();
		}

	 
		
		 
		
		public function set loadCompleteFun(fun:Function):void
		{
			_loadCompleteFun = fun;
//			trace(_loadCompleteFun,"_loadCompleteFun->ResLoader.loadCompleteFun()");
			
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
