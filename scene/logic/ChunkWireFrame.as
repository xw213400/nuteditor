package scene.logic
{
	import flash.geom.Vector3D;
	
	import nut.core.Mesh;
	import nut.core.Node;
	import nut.core.Float4;
	import nut.ext.scene.terrain.Chunk;
	import nut.ext.scene.terrain.Terrain;
	import nut.util.geometries.Line;
	import nut.util.geometries.LineSet;
	import nut.util.shaders.LineShader;
	
	public class ChunkWireFrame extends Node
	{
		private var _heights :Vector.<Vector3D> = new Vector.<Vector3D>(Terrain.VERT_IDX_MAX);
		private var _initialized :Boolean = false;
		private var _color:Float4 = new Float4(1,1,1,1);
		private var _lineSet:LineSet;
		
		public function ChunkWireFrame()
		{
			super();
			
			for (var z:int = 0; z != Terrain.VERT_NUM; ++z)
			{
				for (var x:int = 0; x != Terrain.VERT_NUM; ++x)
				{
					var idx:int = z*Terrain.VERT_NUM + x;
					var pos_x:Number = (x-Terrain.UNIT_NUM*0.5)*Terrain.UNIT_SIZE;
					var pos_z:Number = (z-Terrain.UNIT_NUM*0.5)*Terrain.UNIT_SIZE;
					
					_heights[idx] = new Vector3D();
					_heights[idx].x = pos_x;
					_heights[idx].z = pos_z;
				}
			}
		}

		public function set color(value:Float4):void
		{
			_color = value;
		}

		private function updateHeights(heights:Vector.<Number>):void
		{
			for (var i:int = 0; i != _heights.length; ++i)
			{
				_heights[i].y = heights[i];
			}
		}
		
		private function initSegment(chunk:Chunk, walkData:Boolean=false):void
		{
			var h:int;
			var w:int;
			var v0:Vector3D;
			var v1:Vector3D;
			var heights:Vector.<Number>;
			
			if (walkData && chunk.walkHeight!=null && chunk.walkHeight.length!=0)
				heights = chunk.walkHeight;
			else
				heights = chunk.heightData;
			
			updateHeights(heights);
			
			var lines:Vector.<Line> = new Vector.<Line>();
			
			for (h = 0; h <= Terrain.UNIT_NUM; ++h)
			{
				for (w = 0; w != Terrain.UNIT_NUM; ++w)
				{
					v0 = _heights[w+h*Terrain.VERT_NUM];
					v1 = _heights[w+1+h*Terrain.VERT_NUM];
					
					lines.push(new Line(v0, v1, _color));
				}
			}
			
			for (h = 0; h != Terrain.UNIT_NUM; ++h)
			{
				for (w = 0; w <= Terrain.UNIT_NUM; ++w)
				{
					v0 = _heights[w+h*Terrain.VERT_NUM];
					v1 = _heights[w+(h+1)*Terrain.VERT_NUM];
					
					lines.push(new Line(v0, v1, _color));
				}
			}
			
			_lineSet = new LineSet(lines);
			var lineMesh:Mesh = new Mesh(_lineSet);
			lineMesh.material.addShader(LineShader.instance);
			this.addChild(lineMesh);
			
			this.position = chunk.chunkMesh.position;
			
			_initialized = true;
		}
		
		public function updateSeg(chunk:Chunk, walkData:Boolean=false):void
		{
			if (!_initialized)
			{
				initSegment(chunk, walkData);
				
				return ;
			}
				
			var h:int;
			var w:int;
			var v0:Vector3D;
			var v1:Vector3D;
			var heights:Vector.<Number>;
			var line:Line;
			
			if (walkData && chunk.walkHeight!=null && chunk.walkHeight.length!=0)
				heights = chunk.walkHeight;
			else
				heights = chunk.heightData;
			
			updateHeights(heights);
			
			var segIdx:int = 0;
			for (h = 0; h <= Terrain.UNIT_NUM; ++h)
			{
				for (w = 0; w != Terrain.UNIT_NUM; ++w)
				{
					line = _lineSet.getLine(segIdx);
					line.s = _heights[w+h*Terrain.VERT_NUM];
					line.e = _heights[w+1+h*Terrain.VERT_NUM];
					line.c = _color;
					segIdx++;
				}
			}
			
			for (h = 0; h != Terrain.UNIT_NUM; ++h)
			{
				for (w = 0; w <= Terrain.UNIT_NUM; ++w)
				{
					line = _lineSet.getLine(segIdx);
					line.s = _heights[w+h*Terrain.VERT_NUM];
					line.e = _heights[w+(h+1)*Terrain.VERT_NUM];
					line.c = _color;
					segIdx++;
				}
			}
			
			_lineSet.update();
		}
	}
}