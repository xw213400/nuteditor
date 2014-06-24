package common.logic.drag
{
	import flash.geom.Vector3D;
	
	import nut.core.Float4;
	import nut.core.Mesh;
	import nut.core.Node;
	import nut.core.Nut;
	import nut.enum.DepthTest;
	import nut.enum.PassType;
	import nut.util.geometries.Sphere;
	import nut.util.shaders.PositionColorShader;

	public class DragAxis extends Node
	{
		static public const DRAG_MASK_NONE		:uint = 0;
		static public const DRAG_MASK_POS_X		:uint = 1 << 0;
		static public const DRAG_MASK_POS_Y		:uint = 1 << 1;
		static public const DRAG_MASK_POS_Z		:uint = 1 << 2;
		static public const DRAG_MASK_ROT_X		:uint = 1 << 3;
		static public const DRAG_MASK_ROT_Y		:uint = 1 << 4;
		static public const DRAG_MASK_ROT_Z		:uint = 1 << 5;
		static public const DRAG_MASK_POS_ALL	:uint = DRAG_MASK_POS_X|DRAG_MASK_POS_Y|DRAG_MASK_POS_Z;
		static public const DRAG_MASK_ROT_ALL	:uint = DRAG_MASK_ROT_X|DRAG_MASK_ROT_Y|DRAG_MASK_ROT_Z;
		static public const DRAG_MASK_ALL		:uint = DRAG_MASK_POS_ALL|DRAG_MASK_ROT_ALL;
		
		
		private var _arrow_x	:Arrow = null;
		private var _arrow_y	:Arrow = null;
		private var _arrow_z	:Arrow = null;
		private var _object3D	:Node = null;
		private var _dragMask	:uint = DRAG_MASK_ALL;
		private var _currAxis	:Arrow = null;
		private var _rotateMode	:Boolean = false;
		private var _startDelta	:Number = 0.0;
		private var _startPos	:Vector3D = null;
		private var _startRot	:Vector3D = null;

		public function get dragMask():uint
		{
			return _dragMask;
		}

		private var _onDrag		:Function = null;
		
		public function DragAxis()
		{
			super();
			
			_arrow_x = new Arrow(this, 'x');
			_arrow_y = new Arrow(this, 'y');
			_arrow_z = new Arrow(this, 'z');
			
			addChild(_arrow_x);
			addChild(_arrow_y);
			addChild(_arrow_z);
			
			var center:Mesh = new Mesh(Sphere.getSphere(16,16));
			center.material.addShader(PositionColorShader.instance, PassType.DEPTHSORT);
			center.material.setDepthTest("PositionColorShader", true, DepthTest.ALWAYS);
			center.material.getProperty("PositionColorShader", "color").value = new Float4(1,1,1,1);
			center.material.setDepthPriority("PositionColorShader", 20);
			center.scale = new Vector3D(0.3, 0.3, 0.3);
			addChild(center);
			
			this.visible = false;
		}

		public function get object3D():Node
		{
			return _object3D;
		}
		
		public function notifyPick(mesh:Mesh):Boolean
		{
			if (mesh == null)
			{
				_arrow_x.onMeshMouseOut();
				_arrow_y.onMeshMouseOut();
				_arrow_z.onMeshMouseOut();
				
				return false;
			}
			
			var isPicked:Boolean = false;
			
			isPicked = _arrow_x.isPicked(mesh) || isPicked;
			isPicked = _arrow_y.isPicked(mesh) || isPicked;
			isPicked = _arrow_z.isPicked(mesh) || isPicked;
			
			return isPicked;
		}

		public function pickObject3D(value:Node, onDrag:Function, dragMask:uint):void
		{
			_object3D = value;
			_onDrag = onDrag;
			_dragMask = dragMask;
			
			if (_object3D != null)
			{
				this.visible = true;
				updatePosition();
			}
		}
		
		public function cancelPick(value:Node):void
		{
			if (_object3D != value)
				return ;
			
			_object3D = null;
			this.visible = false;
		}
		
		public function update():void
		{
			var len:Number = Nut.scene.camera.position.subtract(this.position).length;
			var sca:Number = len * 0.03;
			
			this.scale = new Vector3D(sca, sca, sca);
			updatePosition();
		}

		private function updatePosition():void
		{
			if (_object3D != null)
			{
				this.position = _object3D.position;
			}
		}
		
		public function ctrlDown():void
		{
			_rotateMode = true;
		}
		
		public function ctrlUp():void
		{
			_rotateMode = false;
		}
		
		public function mouseUp():void
		{
			if (_currAxis != null)
			{
//				_currAxis.mouseUp();
				_currAxis = null;
				_startDelta = 0.0;
			}
		}
		
		private function getDelta(x:Number, y:Number):Number
		{
			//鼠标射线上两点
			var o:Vector3D = new Vector3D();
			var d:Vector3D = new Vector3D();
			
			Nut.scene.camera.unproject(x, y, o, d);
			
			//鼠标射线的单位向量(坐标轴坐标系旋转为0)
			d.decrementBy(o);
			d.normalize();
			
			//转换到坐标轴坐标系
			o.decrementBy(this.position);
			
			//现在以x轴为例，设鼠标射线与xy平面交点为p,则 o,p同为鼠标射线上的点，d为方向，有参数方程：
			//p - o = d*t; 展开有：
			//p.x = d.x*t + o.x;
			//与xy平面相交时，有p.z=0,可算出t=-o.z/d.z;
			
			var t:Number = 0.0;
			
			if (_currAxis.axis == 'x')
			{
				if (Math.abs(d.y) > Math.abs(d.z))
					t = -o.y/d.y;
				else
					t = -o.z/d.z;
				
				t = d.x*t + o.x + position.x;
			}
			else if (_currAxis.axis == 'y')
			{
				if (Math.abs(o.x) > Math.abs(o.z))
					t = -o.x/d.x;
				else
					t = -o.z/d.z;
				
				t = d.y*t + o.y + position.y;
			}
			else
			{
				if (Math.abs(o.y) > Math.abs(o.x))
					t = -o.y/d.y;
				else
					t = -o.x/d.x;
				
				t = d.z*t + o.z + position.z;
			}
			
			return t;
		}
		
		public function mouseMove(x:Number, y:Number):void
		{
			if (_currAxis == null || _object3D == null)
				return ;
			
			var rot:Vector3D;
			var pos:Vector3D;

			if (_currAxis.axis == 'x')
			{
				if (_rotateMode && (_dragMask & DRAG_MASK_ROT_X))
				{
					rot = _object3D.getRotation();
					rot.x = _startRot.x + (getDelta(x, y)-_startDelta)*10;
					_object3D.setRotation(rot);
					
					if (_onDrag != null)
						_onDrag(_object3D);
				}
				else if (!_rotateMode && (_dragMask & DRAG_MASK_POS_X))
				{
					pos = this.position;
					pos.x = _startPos.x + getDelta(x, y)-_startDelta;
					this.position = pos;
					_object3D.position = pos;
					
					if (_onDrag != null)
						_onDrag(_object3D);
				}
			}
			else if (_currAxis.axis == 'y')
			{
				if (_rotateMode && (_dragMask & DRAG_MASK_ROT_Y))
				{
					rot = _object3D.getRotation();
					rot.y = _startRot.y + (getDelta(x, y)-_startDelta)*10;
					_object3D.setRotation(rot);
					
					if (_onDrag != null)
						_onDrag(_object3D);
				}
				else if (!_rotateMode && (_dragMask & DRAG_MASK_POS_Y))
				{
					pos = this.position;
					pos.y = _startPos.y + getDelta(x, y)-_startDelta;
					this.position = pos;
					_object3D.position = pos;
					
					if (_onDrag != null)
						_onDrag(_object3D);
				}
			}
			else if (_currAxis.axis == 'z')
			{
				if (_rotateMode && (_dragMask & DRAG_MASK_ROT_Z))
				{
					rot = _object3D.getRotation();
					rot.z = _startRot.z + (getDelta(x, y)-_startDelta)*10;
					object3D.setRotation(rot);
					
					if (_onDrag != null)
						_onDrag(_object3D);
				}
				else if (!_rotateMode && (_dragMask & DRAG_MASK_POS_Z))
				{
					pos = this.position;
					pos.z = _startPos.z + getDelta(x, y)-_startDelta;
					this.position = pos;
					_object3D.position = pos;
					
					if (_onDrag != null)
						_onDrag(_object3D);
				}
			}
		}
		
		public function isDraging():Boolean
		{
			return _currAxis != null;
		}
		
		public function onMouseDown(x:Number, y:Number):void
		{
			_currAxis = null;
			
			if (_arrow_x.isMouseIn)
				_currAxis = _arrow_x;
			else if (_arrow_y.isMouseIn)
				_currAxis = _arrow_y;
			else if (_arrow_z.isMouseIn)
				_currAxis = _arrow_z;
			
			if (_currAxis == null)
				return ;
			
			_startDelta = getDelta(x, y);
			_startPos = this.position;
			_startRot = this.getRotation();
		}
	}
}