package common.logic
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import nut.core.Nut;
	import nut.enum.ResType;

	public class LoadResHelper
	{
		static private var _onComplete	:Function	= null;
		static private var _url			:String		= "";
		
		static public function load(title:String, filter:FileFilter, onComplete:Function):void
		{
			_onComplete = onComplete;
			
			var file :File = new File(Nut.resMgr.baseUrl);

			file.addEventListener(Event.SELECT,onSelectRes);
			file.browseForOpen(title, [filter]);
		}
		
		static private function onSelectRes(evt:Event):void
		{
			var fileStream :FileStream = new FileStream();
			var file :File = evt.target as File;
			
			_url = file.url;
			
			fileStream.addEventListener(Event.COMPLETE, onLoadComplete);
			fileStream.openAsync(file, FileMode.READ);
		}
		
		static private function onLoadComplete(evt:Event):void
		{
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			
			var fileStream :FileStream = evt.target as FileStream;
			
			fileStream.readBytes(data, 0, fileStream.bytesAvailable);
			fileStream.close();
			
			if (data.bytesAvailable == 0)
				return;
			
			if (_onComplete != null)
			{
				_onComplete(data, _url);
			}
		}
	}
}