package dae
{
	public class DAEBindVertexInput extends DAEElement
	{
		public var semantic:String;
		public var input_semantic:String;
		public var input_set:int;
		
		public function DAEBindVertexInput(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.semantic = element.@semantic.toString();
			this.input_semantic = element.@input_semantic.toString();
			this.input_set = readIntAttr(element, "input_set");
		}
	}
}