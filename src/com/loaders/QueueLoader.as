package com.loaders
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	[Event(name="itemComplete", type="com.loaders.QueueEvent")]
	[Event(name="itemProgress", type="com.loaders.QueueEvent")]
	[Event(name="queueComplete", type="com.loaders.QueueEvent")]
	[Event(name="itemIOError", type="com.loaders.QueueEvent")]
	public class QueueLoader extends EventDispatcher
	{
		private var queues:Array=[];
		private var _size:int;
		public var loadTotalCount:int;
	 
		/**<最大加载数量>*/
		private var _maxLoaderNum:int;
		private var _currLoaderNum:int = 0;
		private var resLoaderPool:Vector.<ResLoader> = new Vector.<ResLoader>;
		private var displayLoaderPool:Vector.<DisplayLoader> = new Vector.<DisplayLoader>;
		private var currLoadersDic:Dictionary = new Dictionary();
		private var _pause:Boolean;
		public function QueueLoader(maxLoaderNum:int = 1)
		{
			_maxLoaderNum = maxLoaderNum;
		}

 
		public function get pause():Boolean
		{
			return _pause;
		}

		public function set pause(value:Boolean):void
		{
			_pause = value;
			if(!value){
				checkLoad();
			}
		}

		public function get size():int
		{
			return _size;
		}

		public function set size(value:int):void
		{
			_size = value;
		}

		public function addArrayRes(urls:Array, data:Object=null):void
		{
			if (urls)
			{
				for (var i:int=0, ilen:int=urls.length; i < ilen; i++)
				{
					addRes(urls[i], data);
				}
			}
			checkLoad();
		}

		public function addSignalRes(url:String, data:Object=null):void
		{
		
			addRes(url, data);
			checkLoad();
		}

		private function addRes(url:String, data:Object=null):void
		{

			var loaderItem:LoaderItemInfo=new LoaderItemInfo(url);
			loaderItem.data=data;
			queues.push(loaderItem);
			size++;
		}

		/**
		 *如果未开始加载，则加载
		 *
		 */
		private function checkLoad():void
		{
			if (pause) 
			{
				return;
			}
			while (_currLoaderNum < _maxLoaderNum && queues.length)
			{
				load();
			}

		}

		private function load():void
		{
			_currLoaderNum ++;
			
			loadTotalCount++;
	 
			var currLoaderItem:LoaderItemInfo =queues.pop();
			this.dispatchEvent(new QueueEvent(QueueEvent.ITEM_START_LOAD, currLoaderItem));
			size--;
			var iloader:ILoader = getIloader(currLoaderItem);
			currLoadersDic[currLoaderItem.url] = iloader;
			iloader.loadInfo = currLoaderItem;
			iloader.loadCompleteFun=loadCompleteFun;
			iloader.loadErrorFun=loadErrorFun;
			iloader.url = currLoaderItem.url;


		}
		
		private function getIloader(currLoaderItem:LoaderItemInfo):ILoader
		{
			var iloader:ILoader;
			switch (currLoaderItem.type)
			{
				case LoaderItemInfo.UNKOWN:
				case LoaderItemInfo.FILE:
				case LoaderItemInfo.HISTORY:
				case LoaderItemInfo.TXT:
				case LoaderItemInfo.XXML:
				{
					if (resLoaderPool.length) 
					{
						iloader = resLoaderPool.pop();
					}
					else
					{
						iloader=new ResLoader();
					}
					currLoaderItem.resLoader=iloader as ResLoader;
					break;
				}
				case LoaderItemInfo.SWF:
				case LoaderItemInfo.IMAGE:
				{
					if (displayLoaderPool.length) 
					{
						iloader = displayLoaderPool.pop();						
					}
					else
					{
						iloader=new DisplayLoader();
					}
					currLoaderItem.displayLoader=iloader as DisplayLoader;
					break;
				}
			}
			return iloader;
		}
		
		private function loadErrorFun(loader:ILoader):void
		{
			trace(loader.loadInfo.toString(),"loader.loadInfo.toString()->QueueLoader.loadErrorFun()");
			removeFromCurrLoader(loader);
			checkCompleteAndLoad();

		}
		
		private function checkCompleteAndLoad():void
		{
			
			if (!queues.length && _currLoaderNum == 0)
			{
				stop();
				this.dispatchEvent(new QueueEvent(QueueEvent.QUEUE_COMPLETE));
				
				return;
			}
			checkLoad();
		}
		
		private function removeFromCurrLoader(loader:ILoader):void
		{
			_currLoaderNum --;
			delete currLoadersDic[loader.url];
			recyleLoader(loader);
		}
		
		private function loadCompleteFun(loader:ILoader):void
		{
			removeFromCurrLoader(loader);
			this.dispatchEvent(new QueueEvent(QueueEvent.ITEM_COMPLETE, loader.loadInfo));
			checkCompleteAndLoad();

		}
		
		private function recyleLoader(loader:ILoader):void
		{
			if (loader is ResLoader) 
			{
				resLoaderPool.push(loader);
			}
			else
			{
				displayLoaderPool.push(loader);
			}
		}
		
		public function stop():void
		{
			queues=[];
			for each (var iloader:ILoader in currLoadersDic) 
			{
				iloader.stop();
				recyleLoader(iloader);
				delete currLoadersDic[iloader.url];
			}
			
			size = 0;
//			currLoaderItem=null;
			loadTotalCount=0;
			_currLoaderNum = 0;
		}


	}
}
