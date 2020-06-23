package
{
	public class Rect
	{
		public var name:String;
		public var x:int;
		public var y:int;
		public var w:int;
		public var h:int;
		public var fx:int;
		public var fy:int;
		public var fw:int;
		public var fh:int;
		public var subImageName:String;
		
		public function Rect(xml:XML)
		{
			name = xml.@name;
			x = xml.@x;
			y = xml.@y;
			w = xml.@width;
			h = xml.@height;
			fx = xml.@frameX;
			fy = xml.@frameY;
			fw = xml.@frameWidth;
			fh = xml.@frameHeight;
			subImageName = name + ".png";
		}
	}
}