package  com.splice
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class BitmapTrimmer
	{
		public function BitmapTrimmer()
		{
		}
		
		/**
		 *  切割图片
		 * 参数：bitmap 传入的图片 ,
		 * 	          standard 切割alpha边界值 ,10进制uint,(小于边界值将被切割)
		 * 			  isSave  是否保存	,
		 * 			 rect  切割的矩形,
		 * @return 切割后图片
		 * */
		public static function trimBitmap(bitmapData:BitmapData,standard:uint, isSave:Boolean = false,rect:Rectangle = null):BitmapData
		{
			if( bitmapData == null ){
				return null;
			}
			var i:int;
			var j:int;
			var flag:Boolean = false;
			var bd:BitmapData = bitmapData;
			var cutH:int = 0;
			var cutW:int = 0;
			var right:int = 0;  //左
			var left:int = 0;  //右
			var top:int = 0;  //上
			var bottom:int = 0;  //下
			
			//找左边
			for(i=0;i<bd.width;i++)
			{
				if(!isSave) break; //如果保存，不需要切割左边
				flag = false;
				for(j=0;j<bd.height;j++)
				{
					if((bd.getPixel32(i,j)>>>24) >=standard)
					{
						flag = true;
						left=i;
						break;
					}
				}
				if(flag)break;
			}
			
			//找右边   从最后开始找
			for(i=bd.width - 1;i>=left;i--)
			{
				flag = false;
				for(j=0;j<bd.height;j++)
				{
					if((bd.getPixel32(i,j)>>>24)>=standard)
					{
						flag = true;
						right=i;
						break;
					}
				}
				if(flag)break;
			}
			//找上边
			for(j=0;j<bd.height;j++)
			{
				if(!isSave)  break; //如果保存，不需要切割上边
				flag = false;
				for(i=0;i<bd.width;i++)
				{
					if((bd.getPixel32(i,j)>>>24)>=standard)
					{
						flag = true;
						top=j;
						break;
					}
				}
				if(flag)break;
			}
			//找下边    从最后开始找
			for(j=bd.height-1;j>=top;j--)
			{
				flag = false;
				for(i=0;i<bd.width;i++)
				{
					if((bd.getPixel32(i,j)>>>24)>=standard)
					{
						flag = true;
						bottom=j;
						break;
					}
				}
				if(flag)break;
			}	
			
			cutW = Math.abs(right-left)+1;
			cutH = Math.abs(bottom-top)+1;
			
			//原图切割Bug guoqing.wen修改
			if( rect == null )
			{
				rect = new Rectangle(left, top, cutW, cutH);
			}
			else
			{
				rect.x = left;rect.y = top; rect.width = cutW; rect.height = cutH;
			}
			
			var trimmedBD:BitmapData = new BitmapData(cutW , cutH, true, 0x00000000);
			trimmedBD.copyPixels(bd,rect,new Point(0,0));
			
			if(isSave)
			{
				rect.x += 1;
				rect.y += 1;
				rect.width = bd.width;
				rect.height = bd.height;
			}
			
			return trimmedBD;
		}
	}
}