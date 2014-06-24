package dae
{
	public class DAEGeometry extends DAEElement
	{
		public var mesh:DAEMesh;
		public var meshName:String = "";
		
		public function DAEGeometry(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			traverseChildren(element);
			meshName = element.attribute("name");
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			if (nodeName == "mesh")
				this.mesh = new DAEMesh(this, child); //case "spline"//case "convex_mesh":
		}
	}
}