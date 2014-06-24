package dae
{
	internal class DAESource extends DAEElement
	{
		public var accessor:DAEAccessor;
		public var type:String;
		public var floats:Vector.<Number>;
		public var ints:Vector.<uint>;
		public var bools:Vector.<Boolean>;
		public var strings:Vector.<String>;
		
		public function DAESource(element:XML = null):void
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			traverseChildren(element);
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			switch (nodeName) {
				case "float_array":
					this.type = nodeName;
					this.floats = readFloatArray(child);
					break;
				case "int_array":
					this.type = nodeName;
					this.ints = parseUintList(child);
					break;
				case "bool_array":
					throw new Error("Cannot handle bool_array");
					break;
				case "Name_array":
				case "IDREF_array":
					this.type = nodeName;
					this.strings = readStringArray(child);
					break;
				case "technique_common":
					this.accessor = new DAEAccessor(child.ns::accessor[0]);
			}
		}
	}
}