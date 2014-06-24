package dae
{
	internal class DAEScene extends DAEElement
	{
		public var instance_visual_scene:DAEInstanceVisualScene;
		
		public function DAEScene(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.instance_visual_scene = null;
			traverseChildren(element);
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			if (nodeName == "instance_visual_scene")
				this.instance_visual_scene = new DAEInstanceVisualScene(child);
		}
	}
}