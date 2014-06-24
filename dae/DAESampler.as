package dae
{
	public class DAESampler extends DAEElement
	{
		public var input:Vector.<Number>;
		public var output:Vector.<Vector.<Number>>;
		public var dataType:String;
		public var interpolation:Vector.<String>;
		public var minTime:Number;
		public var maxTime:Number;
		private var _inputs:Vector.<DAEInput>;
		
		public function DAESampler(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			var list:XMLList = element.ns::input;
			var i:uint;
			_inputs = new Vector.<DAEInput>();
			
			for (i = 0; i < list.length(); i++)
				_inputs.push(new DAEInput(list[i]));
		}
		
		public function create(sources:Object):void
		{
			var input:DAEInput;
			var source:DAESource;
			var i:uint, j:uint;
			this.input = new Vector.<Number>();
			this.output = new Vector.<Vector.<Number>>();
			this.interpolation = new Vector.<String>();
			this.minTime = 0;
			this.maxTime = 0;
			
			for (i = 0; i < _inputs.length; i++) {
				input = _inputs[i];
				source = sources[input.source];
				
				switch (input.semantic) {
					case "INPUT":
						this.input = source.floats;
						this.minTime = this.input[0];
						this.maxTime = this.input[this.input.length - 1];
						break;
					case "OUTPUT":
						for (j = 0; j < source.floats.length; j += source.accessor.stride)
							this.output.push(source.floats.slice(j, j + source.accessor.stride));
						this.dataType = source.accessor.params[0].type;
						break;
					case "INTEROLATION":
						this.interpolation = source.strings;
				}
			}
		}
		
		public function getFrameData(time:Number):DAEFrameData
		{
			var frameData:DAEFrameData = new DAEFrameData(0, time);
			
			if (!this.input || this.input.length == 0)
				return null;
			
			frameData.valid = true;
			frameData.time = time;
			
			if (time <= this.input[0])
			{
				frameData.frame = 0;
				frameData.dt = 0;
				frameData.setData(output[0]);
			}
			else if (time > this.input[this.input.length-1])
			{
				frameData.frame = this.input.length-1;
				frameData.dt = 0;
				frameData.setData(output[frameData.frame]);
				
			}
			else
			{
				for (var i:int = 0; i < this.input.length-1; i++)
				{
					if (time > this.input[i] && time <= this.input[i+1])
					{
						frameData.frame = i;
						frameData.dt = (time-this.input[i])/(this.input[i+1]-this.input[i]);
						frameData.setData(output[i]);
						
						break;
					}
				}
				
				for (i = 0; i < frameData.data.length; i++)
				{
					var a:Number = this.output[frameData.frame][i];
					var b:Number = this.output[frameData.frame+1][i];
					frameData.data[i] += frameData.dt * (b-a);
				}
			}
			
			return frameData;
		}
	}
}