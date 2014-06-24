package common.ui.custom
{
	import flash.events.MouseEvent;
	
	import spark.components.NumericStepper;
	
	public class NoWheelNumericStepper extends NumericStepper
	{
		public function NoWheelNumericStepper()
		{
			super();
		}
		
		override protected function system_mouseWheelHandler(event:MouseEvent):void
		{
			
		}
	}
}