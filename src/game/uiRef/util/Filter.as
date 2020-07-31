package game.uiRef.util
{
	import flash.filesystem.File;

	public interface Filter
	{
		function accept(file:File):Boolean;
	}
}