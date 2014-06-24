package dae
{
	internal class DAEMesh extends DAEElement
	{
		public var geometry:DAEGeometry;
		public var sources:Object;
		public var vertices:DAEVertices;
		public var primitives:Vector.<DAEPrimitive>;
		
		public function DAEMesh(geometry:DAEGeometry, element:XML = null)
		{
			this.geometry = geometry;
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.sources = {};
			this.vertices = null;
			this.primitives = new Vector.<DAEPrimitive>();
			traverseChildren(element);
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			switch (nodeName) {
				case "source":
					var source:DAESource = new DAESource(child);
					this.sources[source.id] = source;
					break;
				case "vertices":
					this.vertices = new DAEVertices(this, child);
					break;
				case "triangles":
				case "polylist":
				case "polygon":
					this.primitives.push(new DAEPrimitive(child));
			}
		}
	}
}