package dae
{
	public class DAEColorOrTexture extends DAEElement
	{
		public var color:DAEColor;
		public var texture:DAETexture;
		
		public function DAEColorOrTexture(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.color = null;
			this.texture = null;
			traverseChildren(element);
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			switch (nodeName) {
				case "color":
					var values:Vector.<Number> = readFloatArray(child);
					this.color = new DAEColor();
					this.color.r = values[0];
					this.color.g = values[1];
					this.color.b = values[2];
					this.color.a = values.length > 3? values[3] : 1.0;
					break;
				
				case "texture":
					this.texture = new DAETexture();
					this.texture.texcoord = child.@texcoord.toString();
					this.texture.texture = child.@texture.toString();
					break;
				
				default:
					break;
			}
		}
	}
}