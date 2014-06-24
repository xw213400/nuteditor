package common.ui.custom
{
	import flash.events.Event;
	
	import mx.controls.treeClasses.TreeItemRenderer;
	
	public class TreeItemColorRenderer extends TreeItemRenderer
	{
		public function TreeItemColorRenderer()
		{
			super();
		}

		override protected function updateDisplayList(unscaledWidth: Number , unscaledHeight: Number):void
		{  
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if ( data && data.color != undefined)
				label.setColor(data.color);
		}
	}
}