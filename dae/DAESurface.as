package dae
{
	public class DAESurface extends DAEElement
	{
		public var type:String;
		public var init_from:String;
		
		public function DAESurface(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.type = element.@type.toString();
			this.init_from = String(element.ns::init_from[0]);
		}
	}
}