package scene.logic
{
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import nut.core.Float4;
	import nut.core.Geometry;
	import nut.core.Mesh;
	
	public class ArcMesh extends Mesh
	{
		private var _arc:Number = 0.0;
		private var _slope		:Number = 0.0;
		private var _segments	:uint = 16;
		
		public function ArcMesh(arc:Number=0, slope:Number=0)
		{
			var indices :ByteArray = new ByteArray();
			
			indices.endian = Endian.LITTLE_ENDIAN;
			for (var i:int=0; i<_segments; ++i)
			{
				var base:int = i*2;
				
				indices.writeShort(base);
				indices.writeShort(base+2);
				indices.writeShort(base+3);
				indices.writeShort(base+3);
				indices.writeShort(base+1);
				indices.writeShort(base);
			}
			
			super(new Geometry(indices, (_segments+1)*2));
			
			_arc = arc;
			
			createGeometry();
		}
		
		public function set slope(value:Number):void
		{
			_slope = value;
			
//			var posBuffer:VertexComponent = _geometry.getVertexComponent('position');
//			var position:Vector.<Number> = posBuffer.vertices;
//			var vidx:uint = 0;
//			
//			for (var i:int=0; i<=_segments; ++i)
//			{
//				var p1:Vector3D = getPoint(i);
//				var p2:Vector3D = p1.clone();
//				
//				p1.x = -0.5;
//				p2.x = 0.5;
//				
//				position[vidx++] = p1.x;
//				position[vidx++] = p1.y;
//				position[vidx++] = p1.z;
//				position[vidx++] = p2.x;
//				position[vidx++] = p2.y;
//				position[vidx++] = p2.z;
//			}
//			
//			posBuffer.vertices = position;
		}

		public function set arc(value:Number):void
		{
			_arc = value;
			
//			var posBuffer:VertexComponent = _geometry.getVertexComponent('position');
//			var position:Vector.<Number> = posBuffer.vertices;
//			var vidx:uint = 0;
//			
//			for (var i:int=0; i<=_segments; ++i)
//			{
//				var p1:Vector3D = getPoint(i);
//				var p2:Vector3D = p1.clone();
//				
//				p1.x = -0.5;
//				p2.x = 0.5;
//				
//				position[vidx++] = p1.x;
//				position[vidx++] = p1.y;
//				position[vidx++] = p1.z;
//				position[vidx++] = p2.x;
//				position[vidx++] = p2.y;
//				position[vidx++] = p2.z;
//			}
//			
//			posBuffer.vertices = position;
		}

		public function createGeometry():void
		{
			var vertices:Vector.<Number>;
			var uvs		:Vector.<Number>;
			
			vertices = new Vector.<Number>((_segments+1)*6, true);
			uvs = new Vector.<Number>((_segments+1)*4, true);
			
			var vidx	:int = 0;
			var idxUvs	:int = 0;
			
			for (var i:int=0; i<=_segments; ++i)
			{
				var p1:Vector3D = getPoint(i);
				var p2:Vector3D = p1.clone();
				
				p1.x = -0.5;
				p2.x = 0.5;
				
				vertices[vidx++] = p1.x;
				vertices[vidx++] = p1.y;
				vertices[vidx++] = p1.z;
				
				uvs[idxUvs++] = -1;
				uvs[idxUvs++] = p1.z;
				
				vertices[vidx++] = p2.x;
				vertices[vidx++] = p2.y;
				vertices[vidx++] = p2.z;
				
				uvs[idxUvs++] = 1;
				uvs[idxUvs++] = p2.z;
			}
			
			_geometry.vertexbuffer.addComponentFromFloats('position', Context3DVertexBufferFormat.FLOAT_3, vertices);
			_geometry.vertexbuffer.addComponentFromFloats('uv', Context3DVertexBufferFormat.FLOAT_2, uvs);
		}
		
		private function getPoint(seg:uint):Vector3D
		{
			var abs_arc:Number = Math.abs(_arc);
			
			if (abs_arc < 0.001 || abs_arc > 3.141)
			{
				var z:Number = seg/_segments-0.5;
				var h:Number = Math.tan(_slope)*z;
				
				return new Vector3D(0, h, z);
			}
			
			var parc:Number = _arc/_segments*seg - _arc*0.5;
			var r:Number = 0.5 / Math.sin(_arc*0.5);
			var h1:Number = r - r*Math.cos(_arc*0.5);
			var pz:Number = r*Math.sin(parc);
			var h2:Number = r - r*Math.cos(parc);
			var height:Number = h1 - h2;
			
			var hslope:Number = Math.tan(_slope)*pz;
			height += hslope;
			
			return new Vector3D(0, height, pz);
		}
	}
}