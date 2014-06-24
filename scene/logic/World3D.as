package scene.logic
{
	import common.command.CommandChannel;
	import common.logic.WorldBase;
	import common.logic.drag.DragAxis;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import nut.core.Mesh;
	import nut.core.Nut;
	import nut.core.PickController;
	import nut.enum.ResType;
	import nut.ext.scene.GameScene;
	import nut.ext.scene.terrain.Chunk;
	import nut.util.BytesLoader;
	
	import scene.command.Command;
	import scene.scene.GameSceneEd;
	import scene.scene.terrain.TerrainEd;
	
	import spark.components.Group;
	

	public class World3D extends WorldBase
	{
		static public const PICK_MASK_ARC	:uint	= 1<<1;
		static protected var _instance:World3D	= null;
		
		private var _gameScene	:GameSceneEd		= null;
		
		public function World3D(workFolder:String, stage:Stage, mouseArea:Group)
		{
			super(workFolder, stage, mouseArea);
			
			if (_instance)
				throw new Error("World3D is a Singleton!");
			
			_instance = this;
		}
		
		static public function get instance():World3D
		{
			return _instance;
		}

		public function get gameScene():GameSceneEd
		{
			return _gameScene;
		}
		
		public function createScene(sceneName:String):void
		{
			if (_gameScene != null)
			{
				_gameScene.dispose();
			}
			
			_gameScene = new GameSceneEd();
			_gameScene.name = sceneName;
			_gameScene.ambientLight = _ambientLight;
			_gameScene.sunLight = _sunLight;
			_dragAxis.cancelPick(_dragAxis.object3D);
		}
		
		public function openScene(path:String):void
		{
			if (_gameScene != null)
			{
				_gameScene.dispose();
			}
			
			_gameScene = new GameSceneEd();
			_gameScene.name = path;
			_gameScene.ambientLight = _ambientLight;
			_gameScene.sunLight = _sunLight;
			
			var bytesLoader:BytesLoader = new BytesLoader();
			bytesLoader.load(Nut.resMgr.getResUrl(ResType.SCENE)+path, openSceneComplete);
//			_gameScene.initialize(openSceneComplete);
			_dragAxis.cancelPick(_dragAxis.object3D);
		}
		
		private function openSceneComplete(data:ByteArray):void
		{
			_gameScene.decode(data);
			CommandChannel.instance.postCommand(Command.SceneEditor_OPEN_SCENE_OK);
			Brush.instance.initDecal();
		}
		
		public function saveScene():void
		{
			_gameScene.save();
		}
		
		public function createTerrain(x_count:int, z_count:int):void
		{
			_gameScene.createTerrain(x_count, z_count);
			Brush.instance.initDecal();
		}
		
		override protected function onMouseDown(evt:MouseEvent):void
		{
			super.onMouseDown(evt);
			
			if (_keyDowns[Keyboard.CONTROL] && _gameScene.terrain != null)
			{
				var rayPosition:Vector3D = new Vector3D();
				var rayDirection:Vector3D = new Vector3D();
				
				_arcCtrl.camera.unproject(_currPos.x, _currPos.y, rayPosition, rayDirection);
				
				rayDirection = rayDirection.subtract(rayPosition);
				rayDirection.normalize();
				
				var pos:Vector3D = _gameScene.terrain.pick(rayPosition, rayDirection, false);
				
				if (pos != null)
				{
					var chunks:Array = (_gameScene.terrain as TerrainEd).findIntersectChunks(pos.x, pos.x, pos.z, pos.z);
					
					if (chunks.length > 0)
					{
						var chunk:Chunk = _gameScene.terrain.getChunk(chunks[0]);
						CommandChannel.instance.postCommand(Command.DlgSurface_PICK_CHUNK, chunk);
					}
				}
			}
			else
			{
				_dragAxis.onMouseDown(_currPos.x, _currPos.y);
				PickController.instance.pick(evt.localX, evt.localY, PICK_MASK_ARC, onPickComplete);
			}
		}
		
		private function onPickComplete(mesh:Mesh):void
		{
			CommandChannel.instance.postCommand(Command.DlgWalkShape_PICK_MESH, mesh);
		}
		
		override protected function onMouseUp(evt:MouseEvent):void
		{
			super.onMouseUp(evt);
			Brush.instance.recordNewChunk();
		}
		
		override protected function onKeyDown(evt:KeyboardEvent):void
		{
			super.onKeyDown(evt);
			
			if(evt.keyCode == Keyboard.Z)
			{
				if(_keyDowns[Keyboard.CONTROL])
					Brush.instance.undo();
			}
			else if(evt.keyCode == Keyboard.Y)
			{
				if(_keyDowns[Keyboard.CONTROL])
					Brush.instance.redo();
			}
		}
		
		override protected function onEnterFrame(evt:Event):void
		{
			super.onEnterFrame(evt);
			
			if (_gameScene != null && _gameScene.terrain != null)
			{
				var rayPosition:Vector3D = new Vector3D();
				var rayDirection:Vector3D = new Vector3D();
				
				_arcCtrl.camera.unproject(_currPos.x, _currPos.y, rayPosition, rayDirection);
				
				rayDirection = rayDirection.subtract(rayPosition);
				rayDirection.normalize();

				var position:Vector3D = _gameScene.terrain.pick(rayPosition, rayDirection, false);
				if (position != null)
				{
					if (_mouseLPressed)
						Brush.instance.doBrush(position, dt);
					Brush.instance.updateDecal(position);
				}
			}

			Nut.scene.viewport.render();
		}
		
		override protected function initScene():void
		{
			super.initScene();
		}
	}
}