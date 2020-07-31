package  game.uiRef.util
{
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	
	import com.riaspace.nativeApplicationUpdater.NativeApplicationUpdater;
	
	import flash.events.ErrorEvent;
	import flash.events.ProgressEvent;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;

	/**
	 *
	 *  新的更新器
	 * @author liangsong
	 * 创建时间：2015-7-15 下午2:57:01
	 * 
	 */
	public class MyUpdater
	{

		private static var _upDater:NativeApplicationUpdater;
		private static var _updateVersion:String ="";

		public static function get onStartDownLoadCallBack():Function
		{
			return _onStartDownLoadCallBack;
		}

		public static function set onStartDownLoadCallBack(value:Function):void
		{
			_onStartDownLoadCallBack = value;
		}

		public static function get currAppVersion():String
		{
			return _currAppVersion;
		}

		public static function get updateVersion():String
		{
			return _updateVersion;
		}

		public static function get initUpdateCallBack():Function
		{
			return _initUpdateCallBack;
		}

		public static function set initUpdateCallBack(value:Function):void
		{
			_initUpdateCallBack = value;
		}

		private static var _initUpdateCallBack:Function;
		private static var _currAppVersion:String;
		private static var _onStartDownLoadCallBack:Function;
 
		public function MyUpdater()
		{
		}
		
		public static function startInit(updateUrl:String, onStartDownLoadCallBack:Function = null , initUpdateCallBack:Function = null):void
		{
			MyUpdater.initUpdateCallBack = initUpdateCallBack;
			MyUpdater.onStartDownLoadCallBack = onStartDownLoadCallBack;
			_upDater = new NativeApplicationUpdater();
			_upDater.updateURL = updateUrl;
			_upDater.addEventListener( UpdateEvent.INITIALIZED, upDaterInitFun);
			_upDater.addEventListener( ErrorEvent.ERROR, upDaterError);
			_upDater.addEventListener( UpdateEvent.DOWNLOAD_START, downLoadStarEventFun);
			_upDater.addEventListener( ProgressEvent.PROGRESS, downLoadProgressEventFun);
			_upDater.addEventListener( UpdateEvent.DOWNLOAD_COMPLETE, downLoadCompleteEventFun);
			_upDater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, checkForUpdateFun);
			_upDater.isNewerVersionFunction = isNewerVersionFunction;
			_upDater.initialize();
			_currAppVersion = _upDater.currentVersion;
		}
		
		protected static function checkForUpdateFun(event:StatusUpdateEvent):void
		{
			if (!event.available) 
			{
				event.preventDefault();
			}
			_updateVersion = event.versionLabel;
		}
		
		private static function isNewerVersionFunction(currVersion:String, updateVersion:String):Boolean
		{
			var currVersions:Array = currVersion.split(".");
			var updateVersions:Array = updateVersion.split(".");
			var ilen:int = currVersions.length;
			for (var i:int = 0; i < ilen; i++) 
			{
				if (int(currVersions[i]) < int(updateVersions[i])) 
				{
					return true;
				}
			}
			return false;
		}		
	
		
		private static function removeEvents():void
		{
			_upDater.removeEventListener( UpdateEvent.INITIALIZED, upDaterInitFun);
			_upDater.removeEventListener( ErrorEvent.ERROR, upDaterError);
			_upDater.removeEventListener( UpdateEvent.DOWNLOAD_START, downLoadStarEventFun);
			_upDater.removeEventListener( UpdateEvent.DOWNLOAD_COMPLETE, downLoadCompleteEventFun);
		}
		protected static function downLoadProgressEventFun(event:ProgressEvent):void
		{
			showAlert("正在下载新版本进度:" + int(event.bytesLoaded /1024) + "KB/" + int(event.bytesTotal / 1024) + "KB"); 
		}
		
		protected static function downLoadCompleteEventFun(event:UpdateEvent):void
		{
			event.preventDefault();
			showAlert("下载了已完成,点击安装",okBtnFun);
		}
		private static function okBtnFun(event:CloseEvent):void
		{
			if (_initUpdateCallBack != null) 
			{
				_initUpdateCallBack();
			}
			_upDater.installUpdate();
		}
		protected static function downLoadStarEventFun(event:UpdateEvent):void
		{
			if (_onStartDownLoadCallBack != null) 
			{
				_onStartDownLoadCallBack();
			}
			showAlert("开始下载了");
		}
		
		private static function showAlert(param0:String,okBtnFunP:Function = null):void
		{
			Alert.show(param0,"",4,null,okBtnFunP);
		}
		
		protected static function upDaterError(event:ErrorEvent):void
		{
		}
		
		protected static function upDaterInitFun(event:UpdateEvent):void
		{
			
			_upDater.checkNow();
			
		}
	}
}
