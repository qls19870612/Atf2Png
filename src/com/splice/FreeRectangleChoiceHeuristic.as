package com.splice
{
	public class FreeRectangleChoiceHeuristic
	{
		//把一个矩形放在一个自由矩形的短边相对的最合适的位置...
		public static const BestShortSideFit:int = 0; ///< -BSSF: Positions the Rectangle against the short side of a free Rectangle into which it fits the best.
		public static const BestLongSideFit:int = 1; ///< -BLSF: Positions the Rectangle against the long side of a free Rectangle into which it fits the best.
		
		//把一个矩形放在最小的与它匹配的空矩形里面
		public static const BestAreaFit:int = 2; ///< -BAF: Positions the Rectangle into the smallest free Rectangle into which it fits.
		public static const BottomLeftRule:int = 3; ///< -BL: Does the Tetris placement.
	
		//选择的矩形的位置要尽可能多的接触到其他矩形？
		public static const ContactPointRule:int = 4; ///< -CP: Choosest the placement where the Rectangle touches other Rectangles as much as possible.
		
	}
}