package dae
{
	public class DAEInstanceGeometry extends DAEInstance
	{
		public var bind_material:DAEBindMaterial;
		
		public function DAEInstanceGeometry(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.bind_material = null;
			traverseChildren(element);
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			if (nodeName == "bind_material")
				this.bind_material = new DAEBindMaterial(child);
		}
	}
}