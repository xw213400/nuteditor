package model.logic
{
	import flash.display.Stage;
	import flash.events.Event;
	
	import spark.components.Group;
	
	import common.logic.WorldBase;
	
	import nut.core.Nut;

	public class World3D extends WorldBase
	{
		static private var _instance:World3D	= null;
		
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
		
		override protected function onEnterFrame(evt:Event):void
		{
			super.onEnterFrame(evt);
			
			ModelLogic.instance.update(dt*0.001);
			
			Nut.scene.viewport.render();
		}
		
		override protected function initScene():void
		{
			super.initScene();
		}
	}
}