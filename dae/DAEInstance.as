package dae
{
	internal class DAEInstance extends DAEElement
	{
		public var url:String;
		
		public function DAEInstance(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.url = element.@url.toString().replace(/^#/, "");
		}
	}
}