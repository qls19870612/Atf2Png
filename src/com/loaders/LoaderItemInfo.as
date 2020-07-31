package com.loaders
{


	public class LoaderItemInfo
	{
		public var data:Object;


		public static const SWF:String="swf";
		public static const FILE:String="file";
		public static const TXT:String="txt";
		public static const IMAGE:String="image";
		public static const UNKOWN:String="unkown";
		public static const XXML:String="xml";
		public static const HISTORY:String="hs";
		public static const AS_CODE:String="as";


		private var _url:String;
		private var _type:String;
		public var resLoader:ResLoader;
		public var displayLoader:DisplayLoader;
		private var _name:String;
		private var _extName:String="";
	

		public function LoaderItemInfo(url:String)
		{
			_url=url.replace(/\\/g, "\/");
		}

		public function get url():String
		{
			return _url;
		}

		public function set url(value:String):void
		{
			_url=value;
			_extName="";
			_name=null;
			_type=null;
		}

		public function get extName():String
		{
			if (!_extName)
			{
				var a:String=this.type;
			}
			return _extName;
		}

		public function get fileName():String
		{
			return name + "." + extName;
		}

		public function get name():String
		{
			if (!_name)
			{
				url=url.replace(/\\/g, "\/");
				var arr1:Array=url.split("\/");
				var url1:String=arr1[arr1.length - 1];
				var arr:Array=url1.split(".");
				if (arr.length > 1)
				{
					_name=arr[arr.length - 2];
				}
				else
				{
					_name=url1;
				}

			}
			return _name;
		}

		public function set name(value:String):void
		{
			_name=value;
		}

		public function toString():String
		{
			return "[url=" + url + "]" + "[data=" + data + "]"
		}

		public function get type():String
		{
			if (!_type)
			{
				var lastDotIndex:int=url.lastIndexOf(".");
				if (lastDotIndex == -1)
				{
					return UNKOWN;
				}
				_type=url.substr(lastDotIndex + 1).toLowerCase();
				_extName=_type;
				if (_type == "png" || _type == "jpg" || _type == "jpeg")
				{
					_type=IMAGE;
				}
				else if (_type == "swf")
				{
					_type=SWF;
				}
				else if (_type == "txt")
				{
					_type=TXT;
				}
				else if (_type == "xml")
				{
					_type=XXML;
				}
				else if(_type == "hs")
				{
					_type = HISTORY;
				}
				else if (_type == "as") 
				{
					_type = AS_CODE;
				}
				else
				{
					_type=FILE;
				}
			}
			return _type;
		}
		public function get isXml():Boolean
		{
			return type == XXML;
		}
		public function get isImage():Boolean
		{
			return type == IMAGE;
		}
		public function get isFolder():Boolean
		{
			return type == UNKOWN;
		}
		public function get isSwf():Boolean
		{
			return type == SWF;
		}
		public function get isHistory():Boolean
		{
			return type == HISTORY;
		}
		public function get isAsCode():Boolean
		{
			return type == AS_CODE;
		}
	}
}
