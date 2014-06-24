package dae
{
	internal class DAEInstanceController extends DAEInstance
	{
		public var bind_material:DAEBindMaterial;
		public var skeleton:Vector.<String>;
		
		public function DAEInstanceController(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.bind_material = null;
			this.skeleton = new Vector.<String>();
			traverseChildren(element);
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			switch (nodeName) {
				case "skeleton":
					this.skeleton.push(String(child).replace(/^#/, ""));
					break;
				case "bind_material":
					this.bind_material = new DAEBindMaterial(child);
			}
		}
	}
}