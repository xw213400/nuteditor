package common.logic
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import nut.core.Nut;
	import nut.enum.ResType;

	public class SaveResHelper
	{
		static private var _onComplete :Function = null;
		static private var _resType :int = -1;
		static private var _saveFile :File = null;
		static private var _resName :String = "";
		
//		static public function save(resType:int,onComplete:Function):void
//		{
//			_resType = resType;
//			_onComplete = onComplete;
//			
//			var file :File = new File(Nut.resMgr.getResUrl(_resType));
//			
//			file.addEventListener(Event.SELECT,onSelectFolder);
//			
//			if (_resType == ResType.MODEL)
//				file.browseForSave("Save Model");
//		}
//		
//		static private function onSelectFolder(evt:Event):void
//		{
//			var file :File = evt.target as File;
//			var rawExists :Boolean = file.exists;
//			var url :String = file.url;
//			_resName = Nut.resMgr.solveName(url, _resType);
//
//			if (_resType == ResType.MODEL)
//				_saveFile = file.parent.resolvePath(_resName+".mdl");
//			else if (_resType == ResType.EFFECT)
//				_saveFile = file.parent.resolvePath(_resName+".eff");
//			
//			if (!rawExists && _saveFile.exists)
//			{
//				if (_resType == ResType.MODEL)
//					Alert.show("This Model is already exists. Do you want to cover it?", "resource alert", Alert.OK|Alert.CANCEL, null, onAlertClose);
//			}
//			else
//			{
//				if (_onComplete != null)
//					_onComplete(_saveFile, _resName);
//			}
//		}
//		
//		static private function onAlertClose(evt:CloseEvent):void
//		{
//			if (evt.detail == Alert.OK)
//			{
//				if (_onComplete != null)
//					_onComplete(_saveFile, _resName);
//			}
//		}
		
		static public function saveFile(name:String, data:ByteArray, compress:Boolean=true):void
		{
			var file:File = new File(Nut.resMgr.baseUrl + name);
			var fs:FileStream = new FileStream();
			
			if (compress)
				data.compress(CompressionAlgorithm.LZMA);
			
			fs.open(file, FileMode.WRITE);
			fs.position = 0;
			fs.writeBytes(data);
			fs.close();
		}
	}
}