package com.loaders
{
	public interface ILoader
	{
		function set loadCompleteFun(fun:Function):void;
		function get loadCompleteFun():Function;
		function set loadErrorFun(fun:Function):void;
		function get loadErrorFun():Function;
		function set url(value:String):void;
		function get url():String; 
		/**<负载加载时需要用到的数据>*/
		function set loadInfo(value:*):void;
		function get loadInfo():*; 
		function stop():void;
	}
}