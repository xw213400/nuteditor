package dae
{
	public class DAEEffect extends DAEElement
	{
		public var shader:DAEShader;
		public var surface:DAESurface;
		public var sampler:DAESampler2D;
		public var material:*;
		public var image:*;
		
		public function DAEEffect(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.shader = null;
			this.surface = null;
			this.sampler = null;
			traverseChildren(element);
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			if (nodeName == "profile_COMMON")
				deserializeProfile(child);
		}
		
		private function deserializeProfile(element:XML):void
		{
			var children:XMLList = element.children();
			
			for (var i:uint = 0; i < children.length(); i++) {
				var child:XML = children[i];
				var name:String = child.name().localName;
				
				switch (name) {
					case "technique":
						deserializeShader(child);
						break;
					case "newparam":
						deserializeNewParam(child);
				}
			}
		}
		
		private function deserializeNewParam(element:XML):void
		{
			var children:XMLList = element.children();
			
			for (var i:uint = 0; i < children.length(); i++) {
				var child:XML = children[i];
				var name:String = child.name().localName;
				
				switch (name) {
					case "surface":
						this.surface = new DAESurface(child);
						this.surface.sid = element.@sid.toString();
						break;
					case "sampler2D":
						this.sampler = new DAESampler2D(child);
						this.sampler.sid = element.@sid.toString();
						break;
					default:
						trace("[WARNING] unhandled newparam: " + name);
				}
			}
		}
		
		private function deserializeShader(technique:XML):void
		{
			var children:XMLList = technique.children();
			this.shader = null;
			
			for (var i:uint = 0; i < children.length(); i++) {
				var child:XML = children[i];
				var name:String = child.name().localName;
				
				switch (name) {
					case "constant":
					case "lambert":
					case "blinn":
					case "phong":
						this.shader = new DAEShader(child);
				}
			}
		}
	}
}