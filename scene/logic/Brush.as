package scene.logic
{
	import flash.display.BitmapData;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import nut.core.Float4;
	import nut.core.Nut;
	import nut.ext.scene.terrain.Chunk;
	import nut.ext.scene.terrain.Terrain;
	import nut.util.NutMath;
	
	import scene.scene.terrain.ChunkEd;
	import scene.scene.terrain.TerrainEd;

	public class Brush
	{
		[Embed(source="../assets/scene/brush0.jpg")]
		static private var Brush0:Class;
		
		[Embed(source="../assets/scene/brush1.jpg")]
		static private var Brush1:Class;
		
		[Embed(source="../assets/scene/brush2.jpg")]
		static private var Brush2:Class;
		
		static private var _instance	:Brush		= null;
		
		static public const BRUSH_HEIGHT	:int = 1;
		static public const BRUSH_BLEND		:int = 2;
		static public const BRUSH_COLOR		:int = 3;
		static public const BRUSH_SPECULAR	:int = 4;
		
		static public const METHOD_UP		:int = 1;
		static public const METHOD_DOWN		:int = 2;
		static public const METHOD_SMOOTH	:int = 3;
		static public const METHOD_FLAT		:int = 4;
		
		private var _templates	:Dictionary = null;
		private var _size		:Number		= 16.0;
		private var _pos_x		:Number		= 0.0;
		private var _pos_z		:Number		= 0.0;
		private var _brush		:String		= "bt0";
		private var _mode		:int		= BRUSH_HEIGHT;
		private var _method		:int		= METHOD_UP;
		private var _strength	:Number		= 0.5;
		private var _enabled	:Boolean	= false;
		private var _surfaceIdx	:int		= 1;
		private var _currChunk	:Chunk		= null;
		private var _stepHeight	:Number		= 0;
		private var _color		:uint		= 0xFFFFFF;
		private var _brushColor	:Float4		= new Float4(0,1,1,1);
		private var _decal		:Decal		= null;

		static private const MAX_RECORDS	:uint = 30;
		private var _records:Vector.<ChunksRecord> = new Vector.<ChunksRecord>();
		private var _editedChunks:Dictionary = null;
		private var _recordId:int = 0;
		private var _recordMaxId:int = 0;
		
		public function Brush()
		{
			if (_instance)
				throw new Error("Brush is a Singleton!");
			
			_instance = this;
			
			_templates = new Dictionary();
			_templates["bt0"] = new Brush0().bitmapData;
			_templates["bt1"] = new Brush1().bitmapData;
			_templates["bt2"] = new Brush2().bitmapData;
			for (var i:int = 0; i != MAX_RECORDS; ++i)
			{
				_records.push(new ChunksRecord());
			}
		}

		public function get color():uint
		{
			return _color;
		}

		public function set color(value:uint):void
		{
			_color = value;
			_brushColor = NutMath.parseARGB(value);
			_brushColor.a = _brushColor.b;
			_brushColor.b = _brushColor.g;
			_brushColor.g = _brushColor.r;
			_brushColor.r = 0;
		}

		public function get stepHeight():Number
		{
			return _stepHeight;
		}

		public function set stepHeight(value:Number):void
		{
			_stepHeight = value;
		}

		public function set currChunk(value:Chunk):void
		{
			_currChunk = value;
		}

		public function get surfaceIdx():int
		{
			return _surfaceIdx;
		}

		public function set surfaceIdx(value:int):void
		{
			_surfaceIdx = value;
		}

		public function get enabled():Boolean
		{
			return _enabled;
		}

		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			if (_decal == null)
			{
				_decal = new Decal(8, 8, 16, 16);
				World3D.instance.gameScene.scene.addChild(_decal);
			}
			_decal.visible = value;
		}

		public function get strength():Number
		{
			return _strength;
		}

		public function set strength(value:Number):void
		{
			_strength = value;
		}

		public function get method():int
		{
			return _method;
		}

		public function set method(value:int):void
		{
			_method = value;
		}

		public function get mode():int
		{
			return _mode;
		}

		public function set mode(value:int):void
		{
			_mode = value;
		}

		public function get brush():String
		{
			return _brush;
		}

		public function set brush(value:String):void
		{
			_brush = value;
		}

		public function set size(value:Number):void
		{
			_size = value;
			
			if (_decal.terrain != null)
			{
				_decal.updateSize(_size, _size);
			}
		}

		public static function get instance():Brush
		{
			if (_instance == null)
				_instance = new Brush();
			
			return _instance;
		}
		
		public function initDecal():void
		{
			if (_decal == null)
			{
				_decal = new Decal(8,8, 16, 16);
				_decal.visible = false;
				Nut.scene.addChild(_decal);
			}
			if (_decal.terrain == null)
			{
			}
			_decal.terrain = World3D.instance.gameScene.terrain;
			_decal.visible = _enabled;
		}
		
		private function getDelta(x:Number, z:Number):Number
		{
			var bitmapData:BitmapData = _templates[brush];
			
			if (bitmapData == null)
				return 0.0;
			
			var ratio_x:Number = (x - _pos_x + _size*0.5) / _size;
			var ratio_z:Number = (z - _pos_z + _size*0.5) / _size;
			
			if (ratio_x<0.0 || ratio_x>=1.0 || ratio_z<0.0 || ratio_z>=1.0)
				return 0.0;
			
			var color:uint = bitmapData.getPixel((1.0-ratio_x)*bitmapData.width, ratio_z*bitmapData.height);
			var delta:Number = (color & 0xff) / 0xff;
			
			if (_method == METHOD_UP || _method == METHOD_FLAT)
				return delta * _strength;
			else if (_method == METHOD_DOWN)
				return -delta * _strength;
			
			return 0.0;
		}
		
		private function inBrushArea(x:Number, z:Number):Boolean
		{
			var ratio_x:Number = (x - _pos_x + _size*0.5) / _size;
			var ratio_z:Number = (z - _pos_z + _size*0.5) / _size;
			
			if (ratio_x<0.0 || ratio_x>=1.0 || ratio_z<0.0 || ratio_z>=1.0)
				return false;
			
			return true;
		}
		
		public function updateDecal(position:Vector3D):void
		{
			if (!_enabled)
				return ;
			
			var terrain:Terrain = World3D.instance.gameScene.terrain;
			if (terrain == null)
				return ;
			
			_decal.update(position);
		}
		
		private function addEditedChunk(chunk:Chunk, mask:uint):void
		{
			if (_editedChunks[chunk] == null)
			{
				_editedChunks[chunk] = uint(0);
			}
			
			_editedChunks[chunk] |= mask;
		}
		
		public function undo():void
		{
			if (_recordId == 0)
				return ;
			
			if (_recordId > 0)
				--_recordId;

			_records[_recordId].undo();
		}
		
		public function redo():void
		{
			if (_recordId == _recordMaxId)
				return ;
			
			if (_recordId < _recordMaxId)
				++_recordId;
			
			_records[_recordId].redo();
		}
		
		public function recordOldChunk(chunk:ChunkEd, mask:uint):void
		{
			_records[_recordId].recordOldChunk(chunk, mask);
		}
		
		public function recordNewChunk():void
		{
			if (_editedChunks == null)
				return ;

			var record:ChunksRecord = null;
			
			if (_recordId == MAX_RECORDS-1)
			{
				record = _records.shift();
				_records.push(record);
			}
			else
			{
				++_recordId;
				_recordMaxId = _recordId;
				record = _records[_recordId];
			}
			
			record.recordNewChunk(_editedChunks);
			
			_editedChunks = null;
		}
		
		public function doBrush(position:Vector3D, dt:Number):void
		{
			if (!_enabled || _brush == "" || _strength < 0.000001 || _templates[brush]==null)
				return ;
			
			var terrain:TerrainEd = World3D.instance.gameScene.terrain as TerrainEd;
			if (terrain == null)
				return ;
			
			if (_editedChunks == null)
				_editedChunks = new Dictionary();
			
			var bpNum:int = Terrain.BLEND_MAP_SIZE;
			var cpNum:int = Terrain.COLOR_MAP_SIZE;
			
			//颜色图和混合图如果拼成一张就不需要减一
			var bpSpace:Number = Terrain.CHUNK_SIZE/(bpNum-1);
			var cpSpace:Number = Terrain.CHUNK_SIZE/(cpNum-1);
			
			_pos_x = position.x;
			_pos_z = position.z;
			
			var chunkList:Array = terrain.findIntersectChunks(
				_pos_x-_size*0.5, _pos_x+_size*0.5,
				_pos_z-_size*0.5, _pos_z+_size*0.5);
			
			var chunkChanged:Dictionary = new Dictionary();
			
			for (var i:int = 0; i != chunkList.length; ++i)
			{
				var chunk:ChunkEd = terrain.getChunk(chunkList[i]) as ChunkEd;
				var ck_x:Number = chunk.idx_x*Terrain.CHUNK_SIZE-terrain.xChunks*Terrain.HALF_CHUNK_SIZE;
				var ck_z:Number = chunk.idx_z*Terrain.CHUNK_SIZE-terrain.zChunks*Terrain.HALF_CHUNK_SIZE;
				
				if (_mode == BRUSH_HEIGHT)
				{
					recordOldChunk(chunk, ChunkHistoryData.MASK_HEIGHT);
					
					if (_method == METHOD_UP || _method == METHOD_DOWN)
					{
						for (var z:int = 0; z != Terrain.VERT_NUM; ++z)
						{
							for (var x:int = 0; x != Terrain.VERT_NUM; ++x)
							{
								var idx:int = z*Terrain.VERT_NUM+x;
								var delta:Number = getDelta(ck_x+x*Terrain.UNIT_SIZE,ck_z+z*Terrain.UNIT_SIZE);
								var v_h:Number = chunk.heightData[idx];
								var v_d:Number = delta*dt*10;
								chunk.heightData[idx] = v_h + v_d;
							}
						}
						
						chunk.updateMesh();
						addEditedChunk(chunk, ChunkHistoryData.MASK_HEIGHT);
					}
					else if (_method == METHOD_FLAT)
					{
						for (z = 0; z != Terrain.VERT_NUM; ++z)
						{
							for (x = 0; x != Terrain.VERT_NUM; ++x)
							{
								idx = z*Terrain.VERT_NUM+x;
								delta = getDelta(ck_x+x*Terrain.UNIT_SIZE,ck_z+z*Terrain.UNIT_SIZE);
								v_h = chunk.heightData[idx];
								v_d = delta*dt*10;

								if (v_h - _stepHeight > 0)
									v_d = -v_d;
								
								if ((v_h-_stepHeight)*(v_h+v_d-_stepHeight) <= 0)
									chunk.heightData[idx] = _stepHeight;
								else
									chunk.heightData[idx] = v_h + v_d;
							}
						}
						
						chunk.updateMesh();
						addEditedChunk(chunk, ChunkHistoryData.MASK_HEIGHT);
					}
					else if (_method == METHOD_SMOOTH)
					{
						for (z = 0; z != Terrain.VERT_NUM; ++z)
						{
							for (x = 0; x != Terrain.VERT_NUM; ++x)
							{
								var v_x:Number = ck_x+x*Terrain.UNIT_SIZE;
								var v_z:Number = ck_z+z*Terrain.UNIT_SIZE;
								if (!inBrushArea(v_x, v_z))
									continue ;
								
								var h_m:Number = terrain.getHeight(v_x, v_z, false);
								var h_l:Number = terrain.getHeight(v_x-Terrain.UNIT_SIZE, v_z, false);
								var h_r:Number = terrain.getHeight(v_x+Terrain.UNIT_SIZE, v_z, false);
								var h_u:Number = terrain.getHeight(v_x, v_z-Terrain.UNIT_SIZE, false);
								var h_d:Number = terrain.getHeight(v_x, v_z+Terrain.UNIT_SIZE, false);
								
								var h_max:Number = Math.max(h_l, h_r, h_u, h_d);
								
								if (h_max < -9999) h_max = 0.0;
								if (h_m < -9999) h_m = h_max;
								if (h_l < -9999) h_l = h_m;
								if (h_r < -9999) h_r = h_m;
								if (h_u < -9999) h_u = h_m;
								if (h_d < -9999) h_d = h_m;
								
								var s:Number = dt*_strength;
								if (s > 1) s = 1;
								var h:Number = h_m + ((h_m+h_l+h_r+h_u+h_d)*0.2 - h_m)*s;
								var chunks:Array = terrain.setHeight(chunk, x, z, h);
								
								for each (var c:Chunk in chunks)
								{
									chunkChanged[c.idx] = c;
								}
							}
						}
					}
				}
				else if (_mode == BRUSH_BLEND && _currChunk != null)
				{
					if (_currChunk.getSurfacePath(_surfaceIdx) == "")
						continue;
					
					if (chunk.getSurfacePath(_surfaceIdx) == "")
						chunk.setSurfacePath(_surfaceIdx, _currChunk.getSurfacePath(_surfaceIdx));
					else if (_currChunk.getSurfacePath(_surfaceIdx) != chunk.getSurfacePath(_surfaceIdx))
						continue ;
					
					if (chunk.blendTexture.bitmapData == Chunk.DEFAULT_BLEND)
					{
						chunk.blendTexture.setContent(new BitmapData(bpNum, bpNum, false, 0xFF0000), false);
					}
					
					if (chunk.blendEditData == null)
					{
						chunk.blendEditData = new Vector.<Float4>(bpNum*bpNum);
						for (var ci:int = 0; ci != bpNum; ++ci)
						{
							for (var cj:int = 0; cj != bpNum; ++cj)
							{
								var argb:uint = chunk.blendTexture.bitmapData.getPixel(cj, ci);
								var cb:Float4 = NutMath.parseARGB(argb);
								cb.a = 1 - cb.r - cb.g - cb.b;
								chunk.blendEditData[cj+ci*bpNum] = cb;
							}
						}
					}
					
					recordOldChunk(chunk, ChunkHistoryData.MASK_BLEND);
					chunk.blendTexture.bitmapData.lock();
					
					for (z = 0; z != bpNum; ++z)
					{
						for (x = 0; x != bpNum; ++x)
						{
							delta = getDelta(ck_x+x*bpSpace,ck_z+z*bpSpace);
							delta *= dt*5;
							
							var color:Float4 = chunk.blendEditData[x+z*bpNum];

							if (_surfaceIdx == 0)
							{
								color.r += delta;
								if (color.r > 1)
									color.r = 1;
								else if (color.r < 0)
									color.r = 0;
								
								var sum:Number = color.g+color.b+color.a;
								if (sum < 0.000001)
								{
									color.g = 0.0;
									color.b = 0.0;
									color.a = 0.0;
								}
								else
								{
									color.g = (1-color.r) * color.g / sum;
									color.b = (1-color.r) * color.b / sum;
									color.a = (1-color.r) * color.a / sum;
								}
							}
							else if (_surfaceIdx == 1)
							{
								color.g += delta;
								if (color.g > 1)
									color.g = 1;
								else if (color.g < 0)
									color.g = 0;
								
								sum = color.r+color.b+color.a;
								if (sum < 0.000001)
								{
									color.r = 0.0;
									color.b = 0.0;
									color.a = 0.0;
								}
								else
								{
									color.r = (1-color.g) * color.r / sum;
									color.b = (1-color.g) * color.b / sum;
									color.a = (1-color.g) * color.a / sum;
								}
							}
							else if (_surfaceIdx == 2)
							{
								color.b += delta;
								if (color.b > 1)
									color.b = 1;
								else if (color.b < 0)
									color.b = 0;
								
								sum = color.r+color.g+color.a;
								if (sum < 0.000001)
								{
									color.r = 0.0;
									color.g = 0.0;
									color.a = 0.0;
								}
								else
								{
									color.r = (1-color.b) * color.r / sum;
									color.g = (1-color.b) * color.g / sum;
									color.a = (1-color.b) * color.a / sum;
								}
							}
							else if (_surfaceIdx == 3)
							{
								color.a += delta;
								if (color.a > 1)
									color.a = 1;
								else if (color.a < 0)
									color.a = 0;
								
								sum = color.r+color.g+color.b;
								if (sum < 0.000001)
								{
									color.r = 0.0;
									color.g = 0.0;
									color.b = 0.0;
								}
								else
								{
									color.r = (1-color.a) * color.r / sum;
									color.g = (1-color.a) * color.g / sum;
									color.b = (1-color.a) * color.b / sum;
								}
							}

							chunk.blendTexture.bitmapData.setPixel(x, z, color.getAsARGB());
						}
					}
					
					chunk.blendTexture.bitmapData.unlock();
					chunk.blendTexture.invalidateContent();
					addEditedChunk(chunk, ChunkHistoryData.MASK_BLEND);
				}
				else if (_mode == BRUSH_COLOR || _mode == BRUSH_SPECULAR)
				{
					if (chunk.colorTexture.bitmapData == Chunk.DEFAULT_COLOR)
					{
						chunk.colorTexture.setContent(new BitmapData(cpNum, cpNum, true, 0xFF00FFFF), false);
					}
					
					if (chunk.colorEditData == null)
					{
						chunk.colorEditData = new Vector.<Float4>(cpNum*cpNum);
						for (ci = 0; ci != cpNum; ++ci)
						{
							for (cj = 0; cj != cpNum; ++cj)
							{
								var cc:Float4 = NutMath.parseARGB(chunk.colorTexture.bitmapData.getPixel32(cj, ci));
								chunk.colorEditData[cj+ci*cpNum] = cc;
							}
						}
					}
					
					recordOldChunk(chunk, ChunkHistoryData.MASK_COLOR);
					chunk.colorTexture.bitmapData.lock();
					
					if (_mode == BRUSH_COLOR)
					{
						var minColor:Number = 15.1/255.0;
						for (z = 0; z != cpNum; ++z)
						{
							for (x = 0; x != cpNum; ++x)
							{
								delta = getDelta(ck_x+x*cpSpace,ck_z+z*cpSpace);
								delta *= dt*5;
								
								if (delta < 0)
									delta = 0;
								if (delta >= 1)
									delta = 0.999999;
								
								var colorValue:Float4 = chunk.colorEditData[x+z*cpNum];
								var dy:Number = _brushColor.g - colorValue.g;
								var dz:Number = _brushColor.b - colorValue.b;
								var dw:Number = _brushColor.a - colorValue.a;

								dy *= delta;
								dz *= delta;
								dw *= delta;

								colorValue.g += dy;
								colorValue.b += dz;
								colorValue.a += dw;
								
								if (colorValue.a < minColor)
									colorValue.a = minColor;
								
								chunk.colorTexture.bitmapData.setPixel32(x, z, colorValue.getAsARGB());
							}
						}
					}
					else if (_mode == BRUSH_SPECULAR)
					{
						for (z = 0; z != cpNum; ++z)
						{
							for (x = 0; x != cpNum; ++x)
							{
								delta = getDelta(ck_x+x*cpSpace,ck_z+z*cpSpace);
								delta *= dt*5;
								
								colorValue = chunk.colorEditData[x+z*cpNum];
								colorValue.r += delta;
								if (colorValue.r < 0)
									colorValue.r = 0.0;
								else if (colorValue.r > 1)
									colorValue.r = 1.0;
								
								chunk.colorTexture.bitmapData.setPixel32(x, z, colorValue.getAsARGB());
							}
						}
					}
					
					chunk.colorTexture.bitmapData.unlock();
					chunk.colorTexture.invalidateContent();
					addEditedChunk(chunk, ChunkHistoryData.MASK_COLOR);
				}
			}
			
			for each (chunk in chunkChanged)
			{
				chunk.updateMesh();
				addEditedChunk(chunk, ChunkHistoryData.MASK_HEIGHT);
			}
		}
		
		public function getTemplate(brush:String):BitmapData
		{
			return _templates[brush];
		}
		
		public function setCustomTemplate(template:BitmapData):void
		{
			_templates['btc'] = template;
		}
	}
}