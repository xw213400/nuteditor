package effect.logic
{
	public class EditData
	{
		static public const T_Invalid				:uint = 0;
		static public const T_Effect				:uint = 1;
		static public const T_Particle				:uint = 2;
		static public const T_BoxInit				:uint = 3;
		static public const T_ColorFadeAff			:uint = 4;
		static public const T_ColorInterpolateAff	:uint = 5;
		static public const T_ColorRangeInit		:uint = 6;
		static public const T_AxisForceAff			:uint = 7;
		static public const T_CentriForceAff		:uint = 8;
		static public const T_HollowEllipsoidInit	:uint = 9;
		static public const T_LinearForceAff		:uint = 10;
		static public const T_RingInit				:uint = 11;
		static public const T_SpeedBoxInit			:uint = 12;
		static public const T_SpeedSphereInit		:uint = 13;
		static public const T_RotateInit			:uint = 14;
		static public const T_ScaleAff				:uint = 15;
		static public const T_ScaleInterpolateAff	:uint = 16;
		static public const T_ScaleRangeInit		:uint = 17;
		
		static public const LABELS :Vector.<String> = new <String>[
			"",
			"",
			"",
			"Box初始化",
			"颜色渐变影响器",
			"颜色插值影响器",
			"颜色范围初始化",
			"轴向心力影响器",
			"向心力影响器",
			"空心椭球初始化",
			"线性力影响器",
			"环初始化",
			"速度Box初始化",
			"速度球初始化",
			"旋转初始化",
			"大小影响器",
			"大小插值影响器",
			"大小初始化"
		];
		
		private var _type:uint;
		private var _data:Object;
		private var _enabled:Boolean;
		private var _parent:Object;
		
		public function EditData(type:uint, data:Object, parent:Object=null)
		{
			_enabled = true;
			_type = type;
			_data = data;
			_parent = parent;
		}

		public function get type():uint
		{
			return _type;
		}

		public function set type(value:uint):void
		{
			_type = value;
		}

		public function get parent():Object
		{
			return _parent;
		}

		public function set parent(value:Object):void
		{
			_parent = value;
		}

		public function get enabled():Boolean
		{
			return _enabled;
		}

		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}

		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}

	}
}