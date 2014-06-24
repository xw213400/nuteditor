package dae
{
	public class DAEShader extends DAEElement
	{
		public var type:String;
		public var props:Object;
		
		public function DAEShader(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.type = element.name().localName;
			this.props = {};
			traverseChildren(element);
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			switch (nodeName) {
				case "ambient":
				case "diffuse":
				case "specular":
				case "emission":
				case "transparent":
				case "reflective":
					this.props[nodeName] = new DAEColorOrTexture(child);
					break;
				case "shininess":
				case "reflectivity":
				case "transparency":
				case "index_of_refraction":
					this.props[nodeName] = parseFloat(String(child.ns::float[0]));
					break;
				default:
					trace("[WARNING] unhandled DAEShader property: " + nodeName);
			}
		}
	}
}