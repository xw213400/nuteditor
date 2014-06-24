package model.logic
{
	import common.command.CommandChannel;
	
	import dae.DAEParser;
	
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.getTimer;
	
	import model.command.Command;
	
	import nut.core.Nut;
	import nut.ext.model.Model;
	import nut.ext.model.Skeleton;

	public class ModelLogic
	{
		static private var _instance :ModelLogic = null;
		private var _model :Model = null;
		private var _skeleton :Skeleton = null;
		private var _daePath	:String = "";
		
		public function ModelLogic()
		{
			CommandChannel.instance.bindHandler(Command.ModelEditor_OPEN_DAE, onOpenDAE);
			CommandChannel.instance.bindHandler(Command.ModelEditor_OPEN_MDL, onOpenMDL);
		}

		public function get model():Model
		{
			return _model;
		}

		public function get daePath():String
		{
			return _daePath;
		}

		public static function get instance():ModelLogic
		{
			if (!_instance)
				_instance = new ModelLogic();
			
			return _instance;
		}
		
		public function update(dt:Number):void
		{
			if (_model != null && _model.skeleton != null && _model.skeleton.hasAnim())
				_model.updateAt("test", getTimer()*0.001);
		}
		
		private function onOpenMDL(data:ByteArray, url:String):void
		{
			data.uncompress(CompressionAlgorithm.LZMA);
			_daePath = "";
			
			_model = new Model();
			_model.decode(data);
			Nut.scene.addChild(_model);
			CommandChannel.instance.postCommand(Command.ModelLogic_MODEL_READY, _model);
		}
		
		private function onOpenDAE(data:ByteArray, url:String):void
		{
			var xml:XML = new XML(data.readUTFBytes(data.length));
			if (!solvePath(xml))
				return;
			
			var path:String = url;
			path.replace("\\","/");
			var name:String = path.split("/").pop();
			path = path.substr(0, path.length-name.length);
			
			_daePath = path;
			
			var parser :DAEParser = new DAEParser();
			
			parser.context = path;
			parser.parse(xml);
			_model = parser.model;
			_skeleton = parser.skeleton;
			
			if (_model)
			{
				Nut.scene.addChild(_model);
				CommandChannel.instance.postCommand(Command.ModelLogic_MODEL_READY, _model);
			}
			
			if (_skeleton)
			{
				_model.skeleton = _skeleton;
				CommandChannel.instance.postCommand(Command.ModelLogic_SKELETON_READY, _skeleton);
			}
		}

		private function solvePath(xml:XML):Boolean
		{
			var ns:Namespace = xml.namespace();
			var list:XMLList = xml.ns::library_images.ns::image;
			for (var i:uint = 0; i < list.length(); i++)
			{
				var image:XML = list[i];
				var init_from:String = image.ns::init_from[0];
				
				var pattern:RegExp = /[A-Z]:/;
				if (init_from.search(pattern) > -1)
					return false;
				
				init_from.replace("\\","/");
				var temp:String = init_from.substr(0, 8);
				if (temp == "file:///")
					init_from = init_from.substr(8, init_from.length-8);
				
				temp = init_from.substr(0, 7);
				if (temp == "file://")
					init_from = init_from.substr(7, init_from.length-7);
				
				image.ns::init_from[0] = init_from;
			}
			
			return true;
		}
	}
}