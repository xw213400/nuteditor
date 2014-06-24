package dae
{
	internal class DAEVertices extends DAEElement
	{
		public var mesh:DAEMesh;
		public var inputs:Vector.<DAEInput>;
		
		public function DAEVertices(mesh:DAEMesh, element:XML = null)
		{
			this.mesh = mesh;
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.inputs = new Vector.<DAEInput>();
			traverseChildren(element, "input");
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			nodeName = nodeName;
			this.inputs.push(new DAEInput(child));
		}
	}
}