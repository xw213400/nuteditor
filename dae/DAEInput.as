package dae
{
	internal class DAEInput extends DAEElement
	{
		public var semantic:String;
		public var source:String;
		public var offset:int;
		public var set:int;
		
		public function DAEInput(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			
			this.semantic = element.@semantic.toString();
			this.source = element.@source.toString().replace(/^#/, "");
			this.offset = readIntAttr(element, "offset");
			this.set = readIntAttr(element, "set");
		}
	}
}