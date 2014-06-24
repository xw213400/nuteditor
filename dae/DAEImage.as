package dae
{
	import nut.core.NutTexture;

	public class DAEImage extends DAEElement
	{
		public var init_from:String;
		public var resource:NutTexture;
		
		public function DAEImage(element:XML = null):void
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			init_from = String(element.ns::init_from[0]);
			resource = null;
		}
	}
}