package dae
{
	public class DAEMaterial extends DAEElement
	{
		public var instance_effect:DAEInstanceEffect;
		
		public function DAEMaterial(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.instance_effect = null;
			traverseChildren(element);
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			if (nodeName == "instance_effect")
				this.instance_effect = new DAEInstanceEffect(child);
		}
	}
}