package dae
{
	public class DAEChannel extends DAEElement
	{
		public var source:String;
		public var target:String;
		public var sampler:DAESampler;
		public var targetId:String;
		public var targetSid:String;
		public var arrayAccess:Boolean;
		public var dotAccess:Boolean;
		public var dotAccessor:String;
		public var arrayIndices:Array;
		
		public function DAEChannel(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			
			this.source = element.@source.toString().replace(/^#/, "");
			this.target = element.@target.toString();
			this.sampler = null;
			var parts:Array = this.target.split("/");
			this.targetId = parts.shift();
			this.arrayAccess = this.dotAccess = false;
			var tmp:String = parts.shift();
			
			if (tmp.indexOf("(") >= 0) {
				parts = tmp.split("(");
				this.arrayAccess = true;
				this.arrayIndices = new Array();
				this.targetSid = parts.shift();
				for (var i:uint = 0; i < parts.length; i++)
					this.arrayIndices.push(parseInt(parts[i].replace(")", ""), 10));
				
			} else if (tmp.indexOf(".") >= 0) {
				parts = tmp.split(".");
				this.dotAccess = true;
				this.targetSid = parts[0];
				this.dotAccessor = parts[1];
				
			} else
				this.targetSid = tmp;
		}
	}
}