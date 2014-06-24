package scene.logic
{
	import nut.core.Float4;
	import nut.ext.scene.terrain.Chunk;
	import nut.ext.scene.terrain.Terrain;
	
	import scene.scene.terrain.ChunkEd;

	public class ChunkHistoryData
	{
		static public const MASK_HEIGHT	:uint = 1;
		static public const MASK_BLEND	:uint = 1 << 1;
		static public const MASK_COLOR	:uint = 1 << 2;
		
		static public const MASK_HEIGHT_BLEND	:uint = MASK_HEIGHT | MASK_BLEND;
		static public const MASK_HEIGHT_COLOR	:uint = MASK_HEIGHT | MASK_COLOR;
		static public const MASK_BLEND_COLOR	:uint = MASK_BLEND | MASK_COLOR;
		
		static public const MASK_ALL	:uint = MASK_BLEND | MASK_COLOR | MASK_HEIGHT;
		
		private var _chunk			:ChunkEd			= null;
		private var _maskOld		:uint				= 0;
		private var _maskNew		:uint				= 0;
		private var _heightData		:Vector.<Number>	= null;
		private var _blendEditData	:Vector.<Float4>	= null;
		private var _colorEditData	:Vector.<Float4>	= null;
		
		public function ChunkHistoryData()
		{
		}

		public function get maskNew():uint
		{
			return _maskNew;
		}

		public function get chunk():Chunk
		{
			return _chunk;
		}

		public function set maskNew(value:uint):void
		{
			_maskNew = value;
		}

		public function get maskOld():uint
		{
			return _maskOld;
		}

		public function set maskOld(value:uint):void
		{
			_maskOld = value;
		}

		public function initOld(chunk:ChunkEd, mask:uint):void
		{
			if (_chunk == chunk && (_maskNew==mask || _maskOld==mask))
			{
				_maskOld = mask;
				return ;
			}
			
			_chunk = chunk;
			_maskOld = mask;
			
			var len:int = 0;
			var i:int = 0;
			
			if (mask & MASK_HEIGHT)
			{
				len = _chunk.heightData.length;
				
				if (_heightData == null)
					_heightData = new Vector.<Number>(len);
				
				for (i = 0; i != len; ++i)
				{
					_heightData[i] = _chunk.heightData[i];
				}
			}
			
			if (mask & MASK_BLEND)
			{
				len = _chunk.blendEditData.length;
				
				if (_blendEditData == null)
					_blendEditData = new Vector.<Float4>(len);
				
				for (i = 0; i != len; ++i)
				{
					_blendEditData[i] = _chunk.blendEditData[i].clone();
				}
			}
			
			if (mask & MASK_COLOR)
			{
				len = _chunk.colorEditData.length;
				
				if (_colorEditData == null)
					_colorEditData = new Vector.<Float4>(len);
				
				for (i = 0; i != len; ++i)
				{
					_colorEditData[i] = _chunk.colorEditData[i].clone();
				}
			}
		}
		
		public function initNew(chunk:ChunkEd, mask:uint):void
		{
			_chunk = chunk;
			_maskNew = mask;
			_maskOld = 0;
			
			var len:int = 0;
			var i:int = 0;
			
			if (mask & MASK_HEIGHT)
			{
				len = _chunk.heightData.length;
				
				if (_heightData == null)
					_heightData = new Vector.<Number>(len);
				
				for (i = 0; i != len; ++i)
				{
					_heightData[i] = _chunk.heightData[i];
				}
			}
			
			if (mask & MASK_BLEND)
			{
				len = _chunk.blendEditData.length;
				
				if (_blendEditData == null)
					_blendEditData = new Vector.<Float4>(len);
				
				for (i = 0; i != len; ++i)
				{
					_blendEditData[i] = _chunk.blendEditData[i].clone();
				}
			}
			
			if (mask & MASK_COLOR)
			{
				len = _chunk.colorEditData.length;
				
				if (_colorEditData == null)
					_colorEditData = new Vector.<Float4>(len);
				
				for (i = 0; i != len; ++i)
				{
					_colorEditData[i] = _chunk.colorEditData[i].clone();
				}
			}
		}
		
		public function undo():void
		{
			if (_maskOld == 0)
				return ;
				
			var len:int = 0;
			var i:int = 0;
			
			if (_maskOld & MASK_HEIGHT)
			{
				len = _chunk.heightData.length;
				
				for (i = 0; i != len; ++i)
				{
					_chunk.heightData[i] = _heightData[i];
				}
				
				_chunk.updateMesh();
			}
			
			if (_maskOld & MASK_BLEND)
			{
				len = _chunk.blendEditData.length;
				
				for (i = 0; i != len; ++i)
				{
					_chunk.blendEditData[i].copy(_blendEditData[i]);
				}
				
				updateBitmap(true);
			}
			
			if (_maskOld & MASK_COLOR)
			{
				len = _chunk.colorEditData.length;
				
				for (i = 0; i != len; ++i)
				{
					_chunk.colorEditData[i].copy(_colorEditData[i]);
				}
				
				updateBitmap(false);
			}
		}
		
		private function updateBitmap(isBlend:Boolean):void
		{
			var z:int;
			var x:int;
			var color:Float4;
			
			if (isBlend)
			{
				var bpNum:int = Terrain.BLEND_MAP_SIZE;
				
				for (z = 0; z != bpNum; ++z)
				{
					for (x = 0; x != bpNum; ++x)
					{
						color = _chunk.blendEditData[x+z*bpNum];
						_chunk.blendTexture.bitmapData.setPixel(x, z, color.getAsARGB());
					}
				}
				
				_chunk.blendTexture.invalidateContent();
			}
			else
			{
				var cpNum:int = Terrain.COLOR_MAP_SIZE;
				
				for (z = 0; z != cpNum; ++z)
				{
					for (x = 0; x != cpNum; ++x)
					{
						color = _chunk.colorEditData[x+z*cpNum];
						_chunk.colorTexture.bitmapData.setPixel32(x, z, color.getAsARGB());
					}
				}
				
				_chunk.colorTexture.invalidateContent();
			}
		}
		
		public function redo():void
		{
			if (_maskNew == 0)
				return;
			
			var len:int = 0;
			var i:int = 0;
			
			if (_maskNew & MASK_HEIGHT)
			{
				len = _chunk.heightData.length;
				
				for (i = 0; i != len; ++i)
				{
					_chunk.heightData[i] = _heightData[i];
				}
				
				_chunk.updateMesh();
			}
			
			if (_maskNew & MASK_BLEND)
			{
				len = _chunk.blendEditData.length;
				
				for (i = 0; i != len; ++i)
				{
					_chunk.blendEditData[i].copy(_blendEditData[i]);
				}
				
				updateBitmap(true);
			}
			
			if (_maskNew & MASK_COLOR)
			{
				len = _chunk.colorEditData.length;
				
				for (i = 0; i != len; ++i)
				{
					_chunk.colorEditData[i].copy(_colorEditData[i]);
				}
				
				updateBitmap(false);
			}
		}
	}
}