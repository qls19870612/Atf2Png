package com.loaders
{
	import flash.events.Event;
 
	
	public class QueueEvent extends Event
	{
	 
		public static const ITEM_PROGRESS:String = "itemProgress";
		public static const ITEM_COMPLETE:String = "itemComplete";
		public static const QUEUE_COMPLETE:String = "queueComplete";
		public static const ITEM_IO_ERROR:String = "itemIOError";
		public var loaderItemInfo:LoaderItemInfo;
		public static const ITEM_START_LOAD:String="itemStartLoad";
		public function QueueEvent(type:String, loaderItemInfo:LoaderItemInfo=null)
		{
			super(type, bubbles);
			this.loaderItemInfo=loaderItemInfo;
		}
	}
}