package com.splice
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	/**
	 *  BitmapSplicer图片合成大图类
	 * @author guoqing.wen
	 * 
	 */
	public class BitmapSplicer
	{
		private static var maxBinWidth:int = 2048;
		private static var maxBinHeight:int = 2048;
		
		public function BitmapSplicer()
		{
		}
		

		
		/**
		 * 拼成两张大小最小的图片
		 * */
		public static function createSplicedBitmapTwo(bitmapDic:Dictionary, bitmapNameArr:Vector.<String>, 
													  rotation:Boolean = false, method:int = 0):Array
		{
			var retArr:Array = new Array();
			var retNameArr:Vector.<String> = null;
			var retBitmapData:BitmapData = null;
			var tempArrRects:Vector.<Rectangle> = new Vector.<Rectangle>;
			var tmpRect:Rectangle;
			var len:int = bitmapNameArr.length;
			var maxRectBin:MaxRectsBinPack = null;
			var bmp:BitmapData;
			var locationDic:Dictionary;
			
			for(var i:int=0;i < len; i++)
			{
				bmp = bitmapDic[bitmapNameArr[i]];
				//maxRectBin.insert( bmp.width, bmp.height, method);
				tmpRect = new Rectangle(0,0, bitmapDic[bitmapNameArr[i]].width, bitmapDic[bitmapNameArr[i]].height)
				tempArrRects.push(tmpRect);
			}
			maxRectBin = findMinFitBin(tempArrRects, rotation, method);
			if (maxRectBin == null)
			{
				return null;
			}
			var mWidth:int, mHeight:int;
			if (maxRectBin.binWidth == maxRectBin.binHeight)
			{
				mWidth = maxRectBin.binWidth;
				mHeight = maxRectBin.binWidth/2;
			}
			else
			{
				mWidth = mHeight = maxRectBin.binWidth < maxRectBin.binHeight ? maxRectBin.binWidth : maxRectBin.binHeight;
			}
			var minRectBin:MaxRectsBinPack = new MaxRectsBinPack(mWidth, mHeight, rotation);
			var no:Array = new Array();
			var resultRect:Rectangle = null;
			var twoNames:Vector.<String> = new Vector.<String>();
			
			minRectBin.insert2(tempArrRects, method);
			locationDic = new Dictionary();
			retNameArr = new Vector.<String>();
			for (i = minRectBin.usedRectangles.length - 1; i >= 0; i--) 
			{
				if (minRectBin.usedRectangles[i].width == 0 || minRectBin.usedRectangles[i].height == 0)
				{
					no.push(i);
				}
				else
				{
					retNameArr.push(bitmapNameArr[i]);
					locationDic[bitmapNameArr[i]] = minRectBin.usedRectangles[i].clone();
				}
			}
			
			tempArrRects = new Vector.<Rectangle>();
			//后面还没有可以装下
			for (i = no.length - 1; i >= 0; i--) 
			{
				bmp = bitmapDic[bitmapNameArr[no[i]]];
				resultRect = minRectBin.insert(bmp.width, bmp.height, method);
				if (resultRect.width != 0 && resultRect.height != 0)
				{
					locationDic[bitmapNameArr[no[i]]] = resultRect;
					retNameArr.push(bitmapNameArr[no[i]]);
					no[i] = -1;
				}
				else
				{
					twoNames.push(bitmapNameArr[no[i]]);
					tempArrRects.push(bitmapDic[bitmapNameArr[no[i]]].rect.clone());
				}
			}
			var twoRectBin:MaxRectsBinPack = findMinFitBin(tempArrRects, rotation, method);
			if (maxRectBin.binWidth * maxRectBin.binHeight <= minRectBin.binWidth * minRectBin.binHeight + twoRectBin.binWidth * twoRectBin.binHeight)
			{
				locationDic = new Dictionary();
				for (i = bitmapNameArr.length - 1; i >= 0; i--) 
				{
					locationDic[bitmapNameArr[i]] = maxRectBin.usedRectangles[i];
				}
				retBitmapData = getMaxBitmapData(maxRectBin.binWidth, maxRectBin.binHeight, bitmapNameArr, bitmapDic, locationDic);
				retArr.push([bitmapNameArr, retBitmapData, locationDic]);
			}
			else
			{
				//第一张大图
				retBitmapData = getMaxBitmapData(mWidth, mHeight, retNameArr, bitmapDic, locationDic);
				retArr.push([retNameArr, retBitmapData, locationDic]);
				//第二张大图
				locationDic = new Dictionary();
				for (i = twoNames.length - 1; i >= 0; i--) 
				{
					locationDic[twoNames[i]] = twoRectBin.usedRectangles[i];
				}
				retBitmapData = getMaxBitmapData(twoRectBin.binWidth, twoRectBin.binHeight, twoNames, bitmapDic, locationDic);
				retArr.push([twoNames, retBitmapData, locationDic]);
			}
			return retArr;
		}
		
		private static function getMaxBitmapData(width:int, height:int, retNameArr:Vector.<String>, bitmapDic:Dictionary, locationDic:Dictionary):BitmapData
		{
			var retBD:BitmapData = new BitmapData(width, height, true, 0x00000000);
			var destRect:Rectangle = null;
			for (var i:int = retNameArr.length - 1; i >= 0; i--) 
			{
				destRect = locationDic[retNameArr[i]];
				if (destRect)
				{
					retBD.copyPixels(bitmapDic[retNameArr[i]], bitmapDic[retNameArr[i]].rect, new Point(destRect.x, destRect.y));
				}
			}
			return retBD;
		}
//		/**
//		 * 检测2048*2048图能不能装下
//		 * */
//		public static function checkMinFitBin(bitmapNameArr:Vector.<String>, bitmapDic:Dictionary, rotation:Boolean = false, method:int = 0):Boolean
//		{
//			/*var tempArrRects:Vector.<Rectangle> = new Vector.<Rectangle>;
//			var tmpRect:Rectangle;*/
//			var bmp:BitmapData;
//			var maxRectBin:MaxRectsBinPack = new MaxRectsBinPack(2048, 2048, rotation);
//			for(var i:int=0;i < bitmapNameArr.length; i++)
//			{
//				bmp = bitmapDic[bitmapNameArr[i]];
//				maxRectBin.insert( bmp.width, bmp.height, method);
//				/*tmpRect = new Rectangle(0,0,bitmapDic[name].width,bitmapDic[name].height)
//				tempArrRects.push(tmpRect);*/
//			}
//			/*maxRectBin.insert2(tempArrRects, new Vector.<Rectangle>(), method);*/
//			
//			return checkVector(maxRectBin.usedRectangles);
//		}
		/**
		 * 检测2048*2048图能不能装下
		 * */
		public static function checkMinFitBin(bitmapNameArr:Vector.<String>, bitmapDic:Dictionary, rotation:Boolean = false, method:int = 0):Boolean
		{
			var tempArrRects:Vector.<Rectangle> = new Vector.<Rectangle>;
			var tmpRect:Rectangle;
			var bmp:BitmapData;
			var maxRectBin:MaxRectsBinPack = new MaxRectsBinPack(2048, 2048, rotation);
			for(var i:int=0;i < bitmapNameArr.length; i++)
			{
				bmp = bitmapDic[bitmapNameArr[i]];
				var name:String = bitmapNameArr[i];
				tmpRect = new Rectangle(0,0,bitmapDic[name].width,bitmapDic[name].height)
				tempArrRects.push(tmpRect);
			}
			maxRectBin.insert2(tempArrRects, method);
			
			return checkVector(maxRectBin.usedRectangles);
		}
		
		/**
		 * 把小图拼接成大图
		 * @param bitmapDic:小图的字典
		 * @param bitmapNameArr:小图名字的数组
		 * @param locationDic:拼接后得到的各个小图在大图中的位置的字典
		 * @param rotation:是否旋转
		 * @param method：拼接的方式，接收FreeRectangleChoiceHeuristic类常量
		 * @return 
		 * 
		 */
		public static function createSplicedBitmap(bitmapDic:Dictionary, bitmapNameArr:Vector.<String>, locationDic:Dictionary, rotation:Boolean = false, method:int = 0):BitmapData
		{
			var name:String;
			var tempArr : Array = new Array();
			var tempArrName : Array = new Array();
			var tempArrRects:Vector.<Rectangle> = new Vector.<Rectangle>;
			var k:int;
			var bmp:BitmapData;
			
			var rects:Vector.<Rectangle> = new Vector.<Rectangle>;
			var tmpRect:Rectangle;
			//过滤掉相同的小图,但保存位置信息
			for(var i:int=0;i<=bitmapNameArr.length-1;i++)
			{
				name = bitmapNameArr[i];
				var flag : Boolean = true;
				bmp = bitmapDic[bitmapNameArr[i]];
				tmpRect = new Rectangle(0,0,bitmapDic[name].width,bitmapDic[name].height);
				if (tmpRect.width > 2048 || tmpRect.height > 2048)
				{
					var maxScale:Number = tmpRect.width > tmpRect.height ? 2046/tmpRect.width : 2046/tmpRect.height;
					var tmp:BitmapData = new BitmapData(tmpRect.width*maxScale, maxScale*tmpRect.height,true, 0);
					var matrix:Matrix = new Matrix();
					matrix.scale(maxScale, maxScale);
					tmp.draw(bmp, matrix);
					bmp.dispose();
					bitmapDic[bitmapNameArr[i]] = tmp;
					bmp = tmp;
					tmpRect.width = tmp.width;
					tmpRect.height = tmp.height;
				}
				for ( k = 0; k < tempArrName.length; k ++)
				{
					if(compareBitmap(bmp,bitmapDic[tempArrName[k]]))
					{
						tempArr.push(k);
						flag = false;
						break;
					}
				}
				if(flag)
				{
					tempArr.push(-1);
					tempArrName.push(name);
					tempArrRects.push(tmpRect);
				}
			}
			var maxRectBin:MaxRectsBinPack = findMinFitBin(tempArrRects, rotation, method);
			if (maxRectBin == null)
			{
				return null;	
			}
			//创建透明BitmapData对象
			var splicedBitmapData:BitmapData = new BitmapData(maxRectBin.binWidth,maxRectBin.binHeight,true,0x00000000);
			var bmpRect : Rectangle;
			var rect :Rectangle;
			var point : Point;
			var count : int = 0;
			
			for(var j:int=0;j<=bitmapNameArr.length-1;j++)
			{
				 name = bitmapNameArr[j];
				 bmp= bitmapDic[name];
				 bmpRect= new Rectangle(0, 0, bmp.width, bmp.height);
				 rect = new Rectangle();
				 if(tempArr[j]==(-1))
				 {
					 rect = maxRectBin.usedRectangles[count];
					 point= new Point(rect.x ,rect.y );
					 splicedBitmapData.copyPixels(bmp,bmpRect,point);
					 count++;
				 }
				 else 
				 {
					 rect = maxRectBin.usedRectangles[tempArr[j]];
				 }
				 locationDic[name] = rect;
			 }		
			return splicedBitmapData;  //拼接后的大图
		}
		
		/**
		 * 有多张大图，拼接 
		 * @param bitmapDic
		 * @param bitmapNameArr
		 * @param locationDic
		 * @param rotation
		 * @param method
		 * @return 
		 * 
		 */
		public static function createSplicedBitmapArr(bitmapDic:Dictionary, bitmapNameArr:Vector.<String>, rotation:Boolean = false, method:int = 0):Array
		{
			var tmpNames:Vector.<String> = bitmapNameArr.concat();
			var newNames:Vector.<String> = new Vector.<String>();
			var retBitmapData:BitmapData = null;
			var retArr:Array = new Array();
			var pngCount:int = 0;
			var preCount:int = 0;
			var locationDic:Dictionary;
			var flag:Boolean = true;
			var i:int = 0;
			while(preCount < tmpNames.length)
			{
				i = 0;
				while(true)
				{
					pngCount = tmpNames.length - preCount - i;
					
					locationDic = new Dictionary();	
					newNames = new Vector.<String>();
					for (var k:int = preCount; k < preCount + pngCount; k++) 
					{
						newNames.push(tmpNames[k]);
					}
					retBitmapData = null;
					retBitmapData = createSplicedBitmap(bitmapDic, newNames, locationDic, rotation, method);
					if (retBitmapData)//当找到最多连续矩形的最大贴图，继续找后面有没有可以放下的图片
					{
						var addIndex:int = newNames.length;
						var addBitmapData:BitmapData = null;
						var tmpBitmapData:BitmapData = null;
						k++;
						var flagAdd:Boolean = k < tmpNames.length;
						var flagTmp:Boolean = false;
						while(k < tmpNames.length)
						{
							newNames[addIndex] = tmpNames[k];
							flagTmp = true;
							tmpBitmapData = createSplicedBitmap(bitmapDic, newNames, locationDic, rotation, method);
							if (tmpBitmapData)//找到一张，继续找下一张
							{
								flagTmp = false;
								addBitmapData && addBitmapData.dispose();
								addBitmapData = tmpBitmapData;
								addIndex++;
								tmpNames.splice(k, 1);
							}
							else
							{
								k++;
							}
						}
						if (addBitmapData)
						{
							if (flagTmp)//找到的情况下，最后一次有没有找到
							{
								newNames.splice(newNames.length - 1, 1);
							}
							retBitmapData.dispose();
							retBitmapData = addBitmapData;
						}
						else if (flagAdd)
						{
							newNames.splice(newNames.length - 1, 1);
						}
						retArr.push([newNames, retBitmapData, locationDic]);
						preCount += pngCount;
						break;
					}
					else
					{
						i++;
					}
				}
			}
			
			return retArr;
		}
		/**
		 * 有多张大图，拼接 
		 * @return 
		 * 
		 */
		public static function createSplicedBitmapArr2(bitmapDic:Dictionary, bitmapNameArr:Vector.<String>, rotation:Boolean = false, method:int = 0):Array
		{
			var newNames:Vector.<String> = new Vector.<String>();
			var len:Number = bitmapNameArr.length;
			var retBitmapData:BitmapData = null;
			var retArr:Array = new Array();
			var pngCount:int = 0;
			var preCount:int = 0;
			var locationDic:Dictionary;
			var flag:Boolean = true;
			var i:int = 0;
			while(preCount < len)
			{
				i = 0;
				while(true)
				{
					pngCount = len - preCount - i;
					
					locationDic = new Dictionary();	
					newNames = new Vector.<String>();
					for (var k:int = preCount; k < preCount + pngCount; k++) 
					{
						newNames.push(bitmapNameArr[k]);
					}
					retBitmapData = null;
					retBitmapData = createSplicedBitmap(bitmapDic, newNames, locationDic, rotation, method);
					if (retBitmapData)
					{
						retArr.push([newNames, retBitmapData, locationDic]);
						preCount += pngCount;
						break;
					}
					else
					{
						i++;
					}
				}
			}
			
			return retArr;
		}
		
		/**
		 * 搜索最小适合的矩形容器
		 * */
		private static function findMinFitBin(rects:Vector.<Rectangle>, rotation:Boolean = false, method:int = 0):MaxRectsBinPack
		{
			var wFlag:Boolean = false;
			var hFlag:Boolean = false;
			var flag:Boolean = true;
			var heightIndex:int = 0;
			var widthIndex:int = 0;
			var maxRectBin:MaxRectsBinPack = null;
			var areaArray:Array = new Array(32,64,128,256,512,1024,2048,4096,8192);	
			var rectsCopy:Vector.<Rectangle> = new Vector.<Rectangle>;
			while(1)
			{
				rectsCopy =  rects.concat();
//				trace("width="+areaArray[widthIndex]+" height="+areaArray[heightIndex]);
				maxRectBin = new MaxRectsBinPack(areaArray[widthIndex],areaArray[heightIndex], rotation);
				maxRectBin.insert2(rectsCopy, method);
				 
				
				
				if(areaArray[widthIndex]>maxBinWidth) wFlag = true;	
				if(areaArray[heightIndex]>maxBinHeight) hFlag = true;
				
				if(hFlag || wFlag )
				{
					return null;
				}
				if(checkVector(maxRectBin.usedRectangles)){
					break;
				}
				
				if(flag)
				{
					widthIndex++;
					flag = false;
				}
				else
				{
					heightIndex++;
					flag = true;
				}
			}
			return maxRectBin;
		}
		
		/**
		 *   	检验算法处理后的 结果。
		 *       若存在矩形（图片）宽高为0 代表此图片没地方放置 ，
		 *       则地图太小   不满足。
		 * @param vector:待检验的结果向量，
		 * @return 满足    true 
		 * 				不满足  false
		 * */
		private static function checkVector(vector:Vector.<Rectangle>):Boolean
		{
			for(var i:int = vector.length - 1; i >= 0  ; i--)
			{
				if(vector[i].width == 0 && vector[i].height ==0)  return false;
			}
			return true;
		}
		
		public static function compareBitmap(bit1:BitmapData,bit2 : BitmapData) : Boolean
		{
			if( bit1.width != bit2.width || bit1.height != bit2.height)
			{
				return false;
			}
			for(var i : uint = 0; i < bit1.width; i+=20)
			{
				for(var j : uint = 0; j < bit1.width; j+=20)
				{
					if(bit1.getPixel(i,j)!=bit2.getPixel(i,j))
					{
						return false;
					}
				}
			}
			if( bit1.compare( bit2 ) == 0 )
			{
				return true;
			}
			return false;
		}
		
		/**
		 * 把小图拼接成大图,小图在大图中是有序排列的,且每行小图占用面积一样，每列小图面积可以不一样
		 * 换行是根据图片名字换行,所以帧命名得取好了
		 * PNG--例如：test_standDown_000.png、test_standDown_001.png、test_standUp_000.png、test_standUp_001.png 
		 * SWF--例如: 无标签：11201_NULL_001.png、11201_NULL_002.png;有标签：11201_LableName_001.png、11201_LableName_002.png
		 * @time 20130325
		 * @param bitmapDic 小图的字典，
		 * @param bitmapNameArr  小图名字的数组
		 * @param locationDic  = null  返回拼接后得到的各个小图在大图中的位置的字典
		 * @return 拼接后的大图
		 * */
		public static function splicedBitmapOrderdDev(bitmapDic:Dictionary,bitmapNameArr:Array,
													  locationDic:Dictionary = null ):BitmapData 
													 
													  
		{
		
			var i:int;
			var j:int;
			var k:int;
			var name:String;
			var nameArr:Array = [];
			
			
			
			for(i=0;i<=bitmapNameArr.length-1;i++)    //去除空白帧
			{
				name = bitmapNameArr[i];
				if(name.search("空白帧") == -1)  nameArr.push(name);
			}
			
			
			var sliceStrip:int = 0;//根据标签数组，计算换行时取名，跳跃量,PNG和有标签的SWF为3位数判断换行
			var swfLabelStart:int = 0;
			var swfLabelEnd:int = 0;
			
			// 根据名字找出行列数
			var col:int = 0;
			var colMax:int = 0;//最大列数
			var w:int = 0;
			var wMax:int = 0;
			var wRowMax:int = 0;//记录每行图片的最大宽度
			var hMax:int = 0;//一行图片的最大高度
			
			var thisNameNum:int = 0;
			var lastNameNum:int = 0;
			var numIndexStart:int = 0;
			var numIndexEnd:int = 0;
			var rowColsArr:Array = [];//记录每行列数，最后数组长度就是行数
			var rowSpaceArr:Array = [];//记录每行图片的最大宽度
			var colSpaceArr:Array = [];//记录每行图片的最大高度
			for(i=0; i<=nameArr.length-1;i++)
			{ 
				numIndexStart = nameArr[i].lastIndexOf("_");
				numIndexEnd = nameArr[i].lastIndexOf(".");
				
				swfLabelEnd = nameArr[i].lastIndexOf("_", numIndexStart);
				swfLabelStart = nameArr[i].lastIndexOf("_", swfLabelEnd - 1);
				if(nameArr[i].slice(swfLabelStart + 1, swfLabelEnd) == "NULL")//lable是null，表明SWF中没有标签，判断名字换行数据，为1位数
				{
					sliceStrip = 2;
				}
				else
				{
					sliceStrip = 0;
				}
				
				if(numIndexStart != -1 && numIndexEnd != -1)
				{
					//thisNameNum = int(nameArr[i].charAt(numIndex -1));
					thisNameNum = parseInt(nameArr[i].slice(numIndexStart + 1 + sliceStrip, numIndexEnd));
					if(thisNameNum >= lastNameNum)//继续是一行
					{				
						col++;
						colMax = colMax > col ? colMax : col;//统计最大列数		
					
						w += bitmapDic[nameArr[i]].width;//统计一行图片宽度
						wMax = wMax > w ? wMax : w;//所有行图片的最大宽度	
						
						wRowMax = bitmapDic[nameArr[i]].width > wRowMax ? bitmapDic[nameArr[i]].width : wRowMax;//一行图片的最大宽度
						hMax = bitmapDic[nameArr[i]].height > hMax ? bitmapDic[nameArr[i]].height : hMax;//一行图片的最大高度
						
						lastNameNum = thisNameNum;//名字跟进
					}
					else//新行
					{					
						rowColsArr.push(col);	//记录每行列数						
						col = 1;//新行开始列数置1					
											
						rowSpaceArr.push(wRowMax);
						colSpaceArr.push(hMax);
						
						w = bitmapDic[nameArr[i]].width;//新行开始第一列图片宽度
						wRowMax = 0;//新行开始，间距置0，然后继续统计
						hMax = bitmapDic[nameArr[i]].height;////新行开始第一列图片高度
						lastNameNum = 0;
						thisNameNum = 0;
					}
				}
			}
			//记录最后一行
			rowColsArr.push(col);
			rowSpaceArr.push(wRowMax);
			colSpaceArr.push(hMax);
					
			//根据最大宽度，和 一张图片的最大高度*行数确定需要的最小背景矩形
			var bgRecWidth:int = wMax;
			var bgRecHeight:int = 0;
			
			for(i=0; i<=colSpaceArr.length-1;i++)
			{
				bgRecHeight += colSpaceArr[i];
			}
			//----------------------
			//由于图片宽高为2的整数幂，开始判断,找出图片宽高的最小2的整数幂数
			i=0;
			var accumulate:int = 1;
			while(bgRecWidth > accumulate)
			{
				accumulate *= 2;
			}
			bgRecWidth = accumulate;
//			accumulate = 1;//几组图片测试发现，高度好像不用要求2的幂....暂时先不要
//			while(bgRecHeight > accumulate)
//			{
//				accumulate *= 2;
//			}
//			bgRecHeight = accumulate;	
			//----------------------
			var rects:Vector.<Rectangle> = new Vector.<Rectangle>;
			var tmpRect:Rectangle;
			for(i=0;i<=nameArr.length-1;i++)
			{
				name = nameArr[i];
				tmpRect = new Rectangle(0,0,bitmapDic[name].width,bitmapDic[name].height)
				rects.push(tmpRect);
			}
			//创建透明BitmapData对象
			var splicedBitmapData:BitmapData = new BitmapData(bgRecWidth, bgRecHeight, true, 0x00000000); 
			j = 0;//控制换行
			k = 0;//var k:int = 0;行列数数组的下标
			var x:Number = 0;//背景上矩形图片的位置
			var y:Number = 0;
			var count : int =0;
			var newBmpWidth:Number = 0;//新的一行小图的宽度
			var newBmpHeight:Number = 0;//新的一行小图的高度
			var tempArr : Array = new Array();
			var tempArrName : Array = new Array();
			
			for(i=0;i<=nameArr.length-1;i++)
			{
				name = nameArr[i];
				var bmp:BitmapData = bitmapDic[name];
				
				//一行图片完了，换行
				if(j == rowColsArr[k])
				{				
					j=0;
					x = 0;
					if(count!=0)
					{
						count = 0;
						y += newBmpHeight;//列移动距离为一行图片的高度
					}
					k++;
				}
				newBmpWidth = rowSpaceArr[k];
				newBmpHeight = colSpaceArr[k];
				var rect:Rectangle = new Rectangle(x, y, newBmpWidth, newBmpHeight);//要存放该图片的矩形
				var bmpRect:Rectangle = rects[i];
				var point:Point = new Point(rect.x, rect.y);
				var flag : Boolean = true;
				
				for (var m : uint = 0; m < tempArr.length; m++)//用于过滤相同的图片 20130409 deng
				{
					if( compareBitmap (bmp,tempArr[m]) )
					{ 
						rect.x = locationDic[tempArrName[m]].x;
						rect.y =  locationDic[tempArrName[m]].y;
						rect.width =  locationDic[tempArrName[m]].width;
						rect.height =  locationDic[tempArrName[m]].height;
						flag = false;
						break;
					}
				}
				if(flag)
				{
					x += newBmpWidth;//绘制一行下一图片，宽度加
					tempArr.push(bmp);
					count++;
					tempArrName.push(name);
					splicedBitmapData.copyPixels(bmp, bmpRect, point);	
				}
				locationDic[name] = rect;
				j++;//判断是否该换行
			}
			return splicedBitmapData;  //拼接后的大图
			
		}
	}
}