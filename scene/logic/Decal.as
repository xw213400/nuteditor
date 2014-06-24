package scene.logic
{
	import flash.geom.Vector3D;
	
	import nut.core.Mesh;
	import nut.core.Node;
	import nut.core.Float4;
	import nut.ext.scene.terrain.Terrain;
	import nut.util.geometries.Line;
	import nut.util.geometries.LineSet;
	import nut.util.shaders.LineShader;

	public class Decal extends Node
	{
		private var _terrain	:Terrain = null;
		private var _col		:int = 0;
		private var _row		:int = 0;
		private var _heights	:Vector.<Vector3D> = null;
		private var _lineSet	:LineSet = null;
		
		public function Decal(col:int, row:int, xLen:Number, zLen:Number)
		{
			super();
			
			_col = col;
			_row = row;
			
			_heights = new Vector.<Vector3D>((w+1)*(h+1));
			
			var sw:Number = -xLen*0.5;
			var sh:Number = -zLen*0.5;
			
			for (var h:int = 0; h <= row; ++h)
			{
				var ph:Number = sh + h*zLen/row;
				for (var w:int = 0; w <= col; ++w)
				{
					var pw:Number = sw + w*xLen/col;
					var idx:int = w + h*(col+1);
					
					_heights[idx] = new Vector3D(pw, 0, ph, 1);
				}
			}
			
			if (_heights.length>0)
				genGridGeom();
		}

		public function get terrain():Terrain
		{
			return _terrain;
		}

		public function set terrain(value:Terrain):void
		{
			_terrain = value;
		}
		
		private function genGridGeom():void
		{
			var h:int;
			var w:int;
			var lines:Vector.<Line> = new Vector.<Line>();
			var colorGrid:Float4 = new Float4(1,0.5,0.5,1);
			var u:Number = 1.0;
			var v0:Vector3D;
			var v1:Vector3D;
			
			for (h = 0; h <= _row; ++h)
			{
				for (w = 0; w != _col; ++w)
				{
					v0 = _heights[w+h*(_col+1)];
					v1 = _heights[w+1+h*(_col+1)];
					
					lines.push(new Line(v0, v1, colorGrid));
				}
			}
			
			for (h = 0; h != _row; ++h)
			{
				for (w = 0; w <= _col; ++w)
				{
					v0 = _heights[w+h*(_col+1)];
					v1 = _heights[w+(h+1)*(_col+1)];
					
					lines.push(new Line(v0, v1, colorGrid));
				}
			}
			
			_lineSet = new LineSet(lines, 1);
			var lineMesh:Mesh = new Mesh(_lineSet);
			lineMesh.material.addShader(LineShader.instance);
			
			this.addChild(lineMesh);
		}
		
		public function updateSize(xLen:Number, zLen:Number):void
		{
			var sh:Number = -zLen*0.5;
			var sw:Number = -xLen*0.5;
			
			for (var h:int = 0; h <= _row; ++h)
			{
				var ph:Number = sh + h*zLen/_row;
				for (var w:int = 0; w <= _col; ++w)
				{
					var pw:Number = sw + w*xLen/_col;
					var idx:int = w + h*(_col+1);
					
					_heights[idx] = new Vector3D(pw, 0, ph, 1);
				}
			}

			updateSeg();
		}
		
		private function updateSeg():void
		{
			var h:int;
			var w:int;
			var segIdx:int = 0;
			
			for (h = 0; h <= _row; ++h)
			{
				for (w = 0; w != _col; ++w)
				{
					var line:Line = _lineSet.getLine(segIdx) as Line;
					line.s = _heights[w+h*(_col+1)];
					line.e = _heights[w+1+h*(_col+1)];
					segIdx++;
				}
			}
			
			for (h = 0; h != _row; ++h)
			{
				for (w = 0; w <= _col; ++w)
				{
					line = _lineSet.getLine(segIdx) as Line;
					line.s = _heights[w+h*(_col+1)];
					line.e = _heights[w+(h+1)*(_col+1)];
					segIdx++;
				}
			}
			
			_lineSet.update();
		}
		
		public function update(pos:Vector3D):void
		{
			for (var i:int = 0; i != _heights.length; ++i)
			{
				var h :Vector3D = _heights[i];
				var x :Number = pos.x + h.x;
				var z :Number = pos.z + h.z;
				var v :Number = _terrain.getHeight(x, z, false);
				
				if (v == Terrain.INVALID_HEIGHT)
					h.y = - pos.y;
				else
					h.y = v + 0.05 - pos.y;
			}
			
			this.position = pos;
			if (_heights.length>0)
				updateSeg();
		}
	}
}