package dae
{
	public class DAEInstanceMaterial extends DAEInstance
	{
		public var target:String;
		public var symbol:String;
		public var bind_vertex_input:Vector.<DAEBindVertexInput>;
		
		public function DAEInstanceMaterial(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.target = element.@target.toString().replace(/^#/, "");
			this.symbol = element.@symbol.toString();
			this.bind_vertex_input = new Vector.<DAEBindVertexInput>();
			traverseChildren(element);
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			if (nodeName == "bind_vertex_input")
				this.bind_vertex_input.push(new DAEBindVertexInput(child));
		}
	}
}