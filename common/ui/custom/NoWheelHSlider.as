package common.ui.custom
{
	import flash.events.MouseEvent;
	
	import spark.components.HSlider;
	
	public class NoWheelHSlider extends HSlider
	{
		public function NoWheelHSlider()
		{
			super();
		}
		
		override protected function system_mouseWheelHandler(event:MouseEvent):void
		{
			
		}
	}
}