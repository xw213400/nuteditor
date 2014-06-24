package dae
{
	internal class DAEAccessor extends DAEElement
	{
		public var params:Vector.<DAEParam>;
		public var source:String;
		public var stride:int;
		public var count:int;
		
		public function DAEAccessor(element:XML = null):void
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.params = new Vector.<DAEParam>();
			this.source = element.@source.toString().replace(/^#/, "");
			this.stride = readIntAttr(element, "stride", 1);
			this.count = readIntAttr(element, "count", 0);
			traverseChildren(element, "param");
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			if (nodeName == "param")
				this.params.push(new DAEParam(child));
		}
	}
}