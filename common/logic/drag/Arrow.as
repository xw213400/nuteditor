package common.logic.drag
{
	import flash.geom.Vector3D;
	
	import nut.core.Float4;
	import nut.core.Mesh;
	import nut.core.Node;
	import nut.enum.DepthTest;
	import nut.enum.PassType;
	import nut.util.NutMath;
	import nut.util.geometries.Cone;
	import nut.util.geometries.Cylinder;
	import nut.util.shaders.PickShader;
	import nut.util.shaders.PositionColorShader;

	public class Arrow extends Node
	{
		private var _axis		:String		= 'x';
		private var _cylinder	:Mesh		= null;
		private var _cone		:Mesh		= null;
		private var _color		:Float4		= new Float4(1,0,0,1);
		private var _colorHover	:Float4		= new Float4(1,1,0,1);
		private var _dragAxis	:DragAxis	= null;
		private var _isMouseIn	:Boolean	= false;
		private var _isRotate	:Boolean	= false;
		
		public function Arrow(dragAxis:DragAxis, axis:String='x')
		{
			super();
			
			_dragAxis = dragAxis;
			_axis = axis;
			
			if (axis == 'y')
			{
				_color.x = 0;
				_color.y = 1;
			}
			else if (axis == 'z')
			{
				_color.x = 0;
				_color.z = 1;
			}
			
			_cone = new Mesh(Cone.getCone(16));
			_cone.material.addShader(PositionColorShader.instance, PassType.DEPTHSORT);
			_cone.material.setDepthTest("PositionColorShader", true, DepthTest.ALWAYS);
			_cone.material.getProperty("PositionColorShader","color").value = _color;
			_cone.material.addShader(PickShader.getShader(_cone));
			_cone.material.setDepthTest("PickShader", false, DepthTest.ALWAYS);
			_cone.scale = new Vector3D(0.3, 1, 0.3);
			
			if (axis == 'x')
			{
				_cone.position = new Vector3D(2.5, 0, 0);
				_cone.setRotation(new Vector3D(0,0,-NutMath.HALF_PI));
			}
			else if (axis == 'z')
			{
				_cone.position = new Vector3D(0, 0, 2.5);
				_cone.setRotation(new Vector3D(NutMath.HALF_PI,0,0));
			}
			else
			{
				_cone.position = new Vector3D(0, 2.5, 0);
			}
			
			_cylinder = new Mesh(Cylinder.getCylinder(16, 16));
			_cylinder.material.addShader(PositionColorShader.instance, PassType.DEPTHSORT);
			_cylinder.material.setDepthTest("PositionColorShader", true, DepthTest.ALWAYS);
			_cylinder.material.getProperty("PositionColorShader","color").value = _color;
			_cylinder.material.addShader(PickShader.getShader(_cylinder));
			_cylinder.material.setDepthTest("PickShader", false, DepthTest.ALWAYS);
			_cylinder.scale = new Vector3D(0.1, 2, 0.1);
			
			if (axis == 'x')
			{
				_cylinder.position = new Vector3D(1, 0, 0);
				_cylinder.setRotation(new Vector3D(0,0,-NutMath.HALF_PI));
			}
			else if (axis == 'z')
			{
				_cylinder.position = new Vector3D(0, 0, 1);
				_cylinder.setRotation(new Vector3D(-NutMath.HALF_PI,0,0));
			}
			else
			{
				_cylinder.position = new Vector3D(0, 1, 0);
			}
			
			addChild(_cylinder);
			addChild(_cone);
		}
		
		public function get isMouseIn():Boolean
		{
			return _isMouseIn;
		}

		public function get axis():String
		{
			return _axis;
		}
		
		public function isPicked(mesh:Mesh):Boolean
		{
			var mouseIn:Boolean = (_cylinder == mesh || _cone == mesh);

			if (mouseIn)
			{
				onMeshMouseOver();
			}
			else
			{
				onMeshMouseOut();
			}
			
			return mouseIn;
		}
		
		private function onMeshMouseOver():void
		{
			if (_dragAxis.isDraging())
				return ;
			
			_isMouseIn = true;
			_cylinder.material.getProperty(PositionColorShader.instance.name, "color").value = _colorHover;
			_cone.material.getProperty(PositionColorShader.instance.name, "color").value = _colorHover;
		}
		
		public function onMeshMouseOut():void
		{	
			if (!_isMouseIn || _dragAxis.isDraging())
				return ;
			
			_isMouseIn = false;
			
			_cylinder.material.getProperty(PositionColorShader.instance.name, "color").value = _color;
			_cone.material.getProperty(PositionColorShader.instance.name, "color").value = _color;
		}
	}
}