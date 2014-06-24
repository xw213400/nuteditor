package dae
{
	internal class DAEParam extends DAEElement
	{
		public var type:String;
		
		public function DAEParam(element:XML = null):void
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.type = element.@type.toString();
		}
	}

}