package dae
{
	public class DAEBindMaterial extends DAEElement
	{
		public var instance_material:Vector.<DAEInstanceMaterial>;
		
		public function DAEBindMaterial(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.instance_material = new Vector.<DAEInstanceMaterial>();
			traverseChildren(element);
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			if (nodeName == "technique_common") {
				for (var i:uint = 0; i < child.children().length(); i++)
					this.instance_material.push(new DAEInstanceMaterial(child.children()[i]));
			}
		}
	}
}