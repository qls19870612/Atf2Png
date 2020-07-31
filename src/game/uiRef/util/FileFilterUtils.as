package  game.uiRef.util
{
	import flash.net.FileFilter;

	public class FileFilterUtils
	{
		public static var jpgFilter:FileFilter=new FileFilter("JPG图片", "*.jpg");
		public static var pngFilter:FileFilter=new FileFilter("PNG图片", "*.png");
		public static var images:FileFilter=new FileFilter("jpg,png图片", "*.png;*.jpg");
		public static var xmlFilter:FileFilter=new FileFilter("XML文件", "*.xml");
		public static var as3Filter:FileFilter=new FileFilter("AS3类文件", "*.as");

		public function FileFilterUtils()
		{
		}
	}
}
