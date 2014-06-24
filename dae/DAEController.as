package dae
{
	public class DAEController extends DAEElement
	{
		public var skin:DAESkin;
		
		public function DAEController(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			
			this.skin = null;
			
			if (element.ns::skin && element.ns::skin.length())
				this.skin = new DAESkin(element.ns::skin[0]);
			else
				throw new Error("DAEController: could not find a <skin> or <morph> element");
		}
	}
}