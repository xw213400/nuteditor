package common.ui.custom
{
	import flash.events.MouseEvent;
	
	import spark.components.BorderContainer;
	import spark.components.Label;

	public class BasePanel
	{
		private var _parent	:*;
		private var _bar	:Label;
		private var _close	:Label;
		private var _border	:BorderContainer;

		public function BasePanel():void
		{
			_border = new BorderContainer();
			
			_bar = new Label();
			_bar.setStyle("backgroundColor", "#D2E8F4");
			_bar.setStyle("textAlign", "center");
			_bar.setStyle("verticalAlign", "middle");
			_bar.height = 20;
			_bar.addEventListener(MouseEvent.MOUSE_DOWN,onBarDown);

			_close = new Label();
			_close.width = 20;
			_close.height = 20;
			_close.text = "╳";
			_close.setStyle("backgroundColor", "#CC3333");
			_close.setStyle("textAlign", "center");
			_close.setStyle("verticalAlign", "middle");
			_close.setStyle("color", "#FFFFFF");
			_close.setStyle("fontSize", "16");
			_close.addEventListener(MouseEvent.CLICK,onCloseClick);
		}

		private function onStop(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
		}

		private function onCloseClick(event:MouseEvent):void
		{
			_parent.visible = false;
		}

		private function onBarUp(event:MouseEvent):void
		{
			_parent.stage.removeEventListener(MouseEvent.MOUSE_UP,onBarUp);
			_parent.stage.removeEventListener(MouseEvent.MOUSE_OUT,onBarOut);
			_parent.stopDrag();
		}
		
		private function onBarOut(event:MouseEvent):void
		{
			_parent.stage.removeEventListener(MouseEvent.MOUSE_UP,onBarUp);
			_parent.stage.removeEventListener(MouseEvent.MOUSE_OUT,onBarOut);
			_parent.stopDrag();
		}

		private function onBarDown(event:MouseEvent):void
		{
			_parent.startDrag();
			_parent.stage.addEventListener(MouseEvent.MOUSE_UP,onBarUp);
			_parent.stage.addEventListener(MouseEvent.MOUSE_OUT,onBarOut);
		}

		public function init(parent:*, title:String):void
		{
			_parent = parent;
			
			parent.addElement(_close);
			parent.addElement(_bar);
			parent.addElementAt(_border,0);
			
			parent.addEventListener(MouseEvent.MOUSE_DOWN,onStop);
			parent.addEventListener(MouseEvent.MOUSE_WHEEL,onStop);

			_border.width = _parent.width;
			_border.height = _parent.height;
			_bar.width = _close.x =_parent.width - _close.width;
			_bar.text = title;
		}
	}
}
