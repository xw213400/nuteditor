package common.logic
{
	import common.logic.drag.DragAxis;
	
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import nut.core.Float4;
	import nut.core.Geometry;
	import nut.core.Mesh;
	import nut.core.Nut;
	import nut.core.NutCamera;
	import nut.core.PickController;
	import nut.core.Viewport;
	import nut.core.light.AmbientLight;
	import nut.core.light.DirectionLight;
	import nut.util.camera.ArcCameraController;
	import nut.util.geometries.Line;
	import nut.util.geometries.LineSet;
	import nut.util.shaders.LineShader;
	
	import spark.components.Group;
	

	public class WorldBase
	{
		static public const PICK_MASK_DRAG	:uint	= 1<<0;

		protected var _mousePos			:Point				= null;
		protected var _currPos			:Point				= new Point();
		protected var _mouseOut			:Boolean			= true;
		protected var _mouseLPressed	:Boolean			= false;
		protected var _arcCtrl			:ArcCameraController= null;
		protected var _keyDowns			:Vector.<Boolean>	= null;
		protected var _time				:int				= 0;
		protected var _dt				:Number				= 0;
		protected var _dragAxis			:DragAxis			= null;
		protected var _ambientLight		:AmbientLight 		= null;
		protected var _sunLight			:DirectionLight 	= null;
		
		public function WorldBase(workFolder:String, stage:Stage, mouseArea:Group)
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			Nut.initialize(workFolder);
			Nut.scene.viewport = new Viewport(stage, mouseArea.width, mouseArea.height);
			Nut.scene.camera = new NutCamera();
			
			Nut.scene.camera.perspective(Math.PI/4, mouseArea.height/mouseArea.width, 0.1, 10000);
			_arcCtrl = new ArcCameraController(Nut.scene.camera, new Vector3D(0,0,30), new Vector3D(0,0,0), new Vector3D(0,1,0));
			
			_keyDowns = new Vector.<Boolean>(256);
			for(var i:int=0;i<256;i++)
				this._keyDowns[i] = false;
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			mouseArea.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			mouseArea.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRMouseDown);
			mouseArea.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onRMouseUp);
			mouseArea.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			mouseArea.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			mouseArea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			mouseArea.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			initScene();
		}

		public function get sunLight():DirectionLight
		{
			return _sunLight;
		}

		public function get ambientLight():AmbientLight
		{
			return _ambientLight;
		}

		public function get dt():Number
		{
			return _dt;
		}

		public function get dragAxis():DragAxis
		{
			return _dragAxis;
		}

		public function get mouseLPressed():Boolean
		{
			return _mouseLPressed;
		}

		protected function onMouseOut(evt:MouseEvent):void
		{
			_mouseOut = true;
			_dragAxis.mouseUp();
		}

		protected function onMouseMove(evt:MouseEvent):void
		{
			_mouseOut = false;
			
			_currPos.x = evt.localX / Nut.scene.viewport.targetWidth;
			_currPos.y = evt.localY / Nut.scene.viewport.targetHeight;
			
			if (_mousePos)
			{
				_arcCtrl.rotH(_mousePos.x-evt.localX);
				_arcCtrl.rotV(_mousePos.y-evt.localY);
				_mousePos.x = evt.localX;
				_mousePos.y = evt.localY;
			}

			if (_dragAxis.visible)
			{
				PickController.instance.pick(evt.localX, evt.localY, PICK_MASK_DRAG, onMouseHover);
				_dragAxis.mouseMove(_currPos.x, _currPos.y);
			}
		}
		
		private function onMouseHover(mesh:Mesh):void
		{
			_dragAxis.notifyPick(mesh);
		}
		
		protected function onRMouseDown(evt:MouseEvent):void
		{
			_mousePos = new Point(evt.localX, evt.localY);
		}
		
		protected function onRMouseUp(evt:MouseEvent):void
		{
			_mousePos = null;
		}
		
		protected function onMouseDown(evt:MouseEvent):void
		{
			_mouseLPressed = true;
		}
		
		protected function onMouseUp(evt:MouseEvent):void
		{
			_mouseLPressed = false;
			_dragAxis.mouseUp();
		}
		
		protected function onMouseWheel(evt:MouseEvent):void
		{
			_arcCtrl.zoom(1+evt.delta*0.01);
			_dragAxis.update();
		}
		
		protected function onKeyDown(evt:KeyboardEvent):void
		{
			_keyDowns[evt.keyCode] = true;
			if (evt.keyCode == Keyboard.CONTROL)
				_dragAxis.ctrlDown();
		}
		
		protected function onKeyUp(evt:KeyboardEvent):void
		{
			_keyDowns[evt.keyCode] = false;
			if (evt.keyCode == Keyboard.CONTROL)
				_dragAxis.ctrlUp();
		}
		
		public function resize(w:int, h:int):void
		{
			Nut.scene.viewport.resetSize(w, h);
			_arcCtrl.camera.perspective(Math.PI/4, h/w, 0.1, 10000);
		}
		
		protected function onEnterFrame(evt:Event):void
		{
			var lastTime:int = _time;
			_time = getTimer();
			_dt = (_time-lastTime)*0.001;
			
			if (!_mouseOut)
			{
				var forward:Vector3D = _arcCtrl.forward;
				var right:Vector3D = _arcCtrl.right;
				
				if (_keyDowns[Keyboard.W])
					_arcCtrl.move(forward.x*_dt, 0, forward.z*_dt);
				if (_keyDowns[Keyboard.S])
					_arcCtrl.move(-forward.x*_dt, 0, -forward.z*_dt);
				if (_keyDowns[Keyboard.A])
					_arcCtrl.move(-right.x*_dt, 0, -right.z*_dt);
				if (_keyDowns[Keyboard.D])
					_arcCtrl.move(right.x*_dt, 0, right.z*_dt);
			}
		}
		
		public function get camera():NutCamera
		{
			return _arcCtrl.camera;
		}
		
		protected function initScene():void
		{
			_dragAxis = new DragAxis();
			Nut.scene.addChild(_dragAxis);
			_dragAxis.pickMask = PICK_MASK_DRAG;
			
			_ambientLight = new AmbientLight();
			_sunLight = new DirectionLight(true);
			Nut.scene.addLight(_sunLight);
			
			var gridMesh:Mesh = new Mesh(genGridGeom(6, 6));
			gridMesh.material.addShader(LineShader.instance);
			Nut.scene.addChild(gridMesh);
		}
		
		private function genGridGeom(col:int, row:int):Geometry
		{
			var h:int;
			var w:int;
			var lines:Vector.<Line> = new Vector.<Line>();
			var colorGrid:Float4 = new Float4(1,1,1,1);
			var colorXAxis:Float4 = new Float4(1,0,0,1);
			var colorZAxis:Float4 = new Float4(0,0,1,1);
			var u:Number = 1.0;
			var start:Vector3D;
			var end:Vector3D;
			
			for (h = -col; h <= col; ++h)
			{
				for (w = -row; w != row; ++w)
				{
					start = new Vector3D(w*u, 0, h*u);
					end = new Vector3D((w+1)*u, 0, h*u);
					
					if (h==0 && w>=0)
						lines.push(new Line(start, end, colorXAxis));
					else
						lines.push(new Line(start, end, colorGrid));
				}
			}
			
			for (h = -col; h != col; ++h)
			{
				for (w = -row; w <= row; ++w)
				{
					start = new Vector3D(w*u, 0, h*u);
					end = new Vector3D(w*u, 0, (h+1)*u);
					
					if (w==0 && h>=0)
						lines.push(new Line(start, end, colorZAxis));
					else
						lines.push(new Line(start, end, colorGrid));
				}
			}
			
			return new LineSet(lines, 1);
		}
	}
}