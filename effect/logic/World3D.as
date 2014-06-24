package effect.logic
{
	import common.logic.WorldBase;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import nut.core.Nut;
	import nut.ext.effect.EffectNode;
	
	import spark.components.Group;
	
	public class World3D extends WorldBase
	{
		static private var _instance:World3D	= null;
		
		private var _effect:EffectNode = null;
		
		public function World3D(workFolder:String, stage:Stage, mouseArea:Group)
		{
			super(workFolder, stage, mouseArea);
			
			_instance = this;
		}
		
		public function get effect():EffectNode
		{
			return _effect;
		}

		public function set effect(value:EffectNode):void
		{
			_effect = value;
			Nut.scene.addChild(_effect);
		}

		static public function get instance():World3D
		{
			return _instance;
		}
		
		override protected function onMouseMove(evt:MouseEvent):void
		{
			super.onMouseMove(evt);
			
			if (_mouseLPressed && _effect != null)
			{
				var rayPosition:Vector3D = new Vector3D();
				var rayDirection:Vector3D = new Vector3D();
				
				_arcCtrl.camera.unproject(_currPos.x, _currPos.y, rayPosition, rayDirection);
				
				rayDirection = rayDirection.subtract(rayPosition);
				rayDirection.normalize();
				
				rayDirection.scaleBy(rayPosition.y/rayDirection.y);
				rayPosition.decrementBy(rayDirection);
				
				_effect.position = rayPosition;
			}
		}
		
		override protected function onEnterFrame(evt:Event):void
		{
			super.onEnterFrame(evt);
			
			if (_effect != null)
			{	
				_effect.update(dt);
			}

			Nut.scene.viewport.render();
		}
		
		override protected function initScene():void
		{
			super.initScene();
		}
	}
}