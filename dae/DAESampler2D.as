package dae
{
	public class DAESampler2D extends DAEElement
	{
		public var source:String;
		
		public function DAESampler2D(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.source = String(element.ns::source[0]);
		}
	}
}