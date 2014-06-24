package common.ui.custom
{		
	import flash.events.Event;
	
	import mx.controls.CheckBox;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.controls.treeClasses.TreeListData;
	
	public class TreeItemCheckBoxRenderer extends TreeItemRenderer	
	{
		protected var _showCheckBox	:Boolean = false;			
		protected var _checkBox		:CheckBox;  
		
		public function TreeItemCheckBoxRenderer()
		{
			super();
		}
		
		override protected function createChildren(): void	
		{
			super.createChildren();
			
			_checkBox = new CheckBox();  
			_checkBox.addEventListener(Event.CHANGE, changeHandler);
			
			addChild(_checkBox);
		}
		
		/** 
		 * 点击checkbox时,更新dataProvider 
		 * @param event 
		 */
		protected function changeHandler( event:Event ): void	
		{  
			if( data && data.Checked != undefined )	
			{  
				data.checked = _checkBox.selected;
				data.data.enabled = _checkBox.selected;
			}  	
		}   
		
		/** 
		 * 初始化控件时, 给checkbox赋值 
		 */
		override protected function commitProperties():void	
		{
			super.commitProperties();  
			
			if (!data) return;
			
			_showCheckBox = data.hasOwnProperty("checked");
			
			if (_showCheckBox)
			{
				_checkBox.selected = data.checked;
			}
			else
			{
				_checkBox.visible = false;
			}
		}  
		
		/** 
		 * 重置itemRenderer的宽度 
		 */
		override protected function measure(): void
		{
			super.measure();
			
			if(_showCheckBox)
				measuredWidth += _checkBox.getExplicitOrMeasuredWidth();  
		}  
		
		/** 
		 * 重新排列位置, 将label后移 
		 * @param unscaledWidth 
		 * @param unscaledHeight 
		 */
		override protected function updateDisplayList(unscaledWidth: Number , unscaledHeight: Number):void
		{  
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if ( data && data.color != undefined)
				label.setColor(data.color);
			
			if(!_showCheckBox)
				return;
			
			_checkBox.visible=true;
			
			var startx: Number = data ? TreeListData( listData ).indent : 0;  
			
			if(disclosureIcon)
			{
				disclosureIcon.x = startx;  	
				startx = disclosureIcon.x + disclosureIcon.width;         
				disclosureIcon.setActualSize(disclosureIcon.width,  disclosureIcon.height);  
				disclosureIcon.visible = data ?  TreeListData( listData ).hasChildren : false;  
			}   
			
			
			if(icon) {  
				icon.x = startx;  
				startx = icon.x + icon.measuredWidth;  			
				icon.setActualSize(icon.measuredWidth, icon.measuredHeight);  	
			}  
			
			_checkBox.move(startx, ( unscaledHeight - _checkBox.height ) / 2 );  
			label.x = startx + _checkBox.getExplicitOrMeasuredWidth();
		}
	}
}