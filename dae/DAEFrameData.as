package dae
{
	public class DAEFrameData
	{
		public var frame:uint;
		public var time:Number;
		public var data:Vector.<Number>;
		public var dt:Number;
		public var valid:Boolean;
		
		public function DAEFrameData(frame:uint = 0, time:Number = 0.0, dt:Number = 0.0, valid:Boolean = false)
		{
			this.frame = frame;
			this.time = time;
			this.dt = dt;
			this.valid = valid;
		}
		
		public function setData(out:Vector.<Number>):void
		{
			if (data == null)
				data = new Vector.<Number>();
			
			data.splice(0, data.length);
			for (var i:int = 0; i!=out.length; ++i)
			{
				data.push(out[i]);
			}
		}
	}
}