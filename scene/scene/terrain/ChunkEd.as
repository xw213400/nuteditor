package scene.scene.terrain
{
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;
	
	import nut.core.Float4;
	import nut.ext.scene.SegmentConst;
	import nut.ext.scene.terrain.Chunk;
	import nut.ext.scene.terrain.Terrain;
	
	public class ChunkEd extends Chunk
	{
		public var blendEditData	:Vector.<Float4>	= null;
		public var colorEditData	:Vector.<Float4>	= null;
		
		public function ChunkEd(terrain:Terrain, idx:int)
		{
			super(terrain, idx);
		}
		
		public function updateMesh():void
		{
			_chunkMesh.updateHeight();
		}
		
		override public function exportChunk(data:ByteArray):void
		{
			data.writeByte(SegmentConst.SEG_CHUNK_Surface);
			for (i=0; i!=4; ++i)
			{
				data.writeUTF(_surfaces[i]);
			}
			
			data.writeByte(SegmentConst.SEG_CHUNK_Height);
			for (var i:int=0; i!=Terrain.VERT_IDX_MAX; ++i)
			{
				data.writeShort(_heightData[i]*100);
			}
			
			if (_walkHeight != null)
			{
				data.writeByte(SegmentConst.SEG_CHUNK_WalkHeight);
				for (i=0; i!=Terrain.VERT_IDX_MAX; ++i)
				{
					data.writeShort(_walkHeight[i]*100);
				}
			}
			
			if (_pointLights.length > 0)
			{
				data.writeByte(SegmentConst.SEG_CHUNK_PointLight);
				data.writeByte(_pointLights.length);
				for (i=0; i!=_pointLights.length; ++i)
				{
					data.writeUnsignedInt(_pointLights[i]);
				}
			}
			
			var png:PNGEncoder = new PNGEncoder();
			var blendImage:ByteArray = png.encode(_blendTexture.bitmapData);
			var colorImage:ByteArray = png.encode(_colorTexture.bitmapData);
			
			data.writeByte(SegmentConst.SEG_CHUNK_BlendMap);
			data.writeUnsignedInt(blendImage.length);
			data.writeBytes(blendImage);
			
			data.writeByte(SegmentConst.SEG_CHUNK_ColorMap);
			data.writeUnsignedInt(colorImage.length);
			data.writeBytes(colorImage);
			
			data.writeByte(SegmentConst.SEG_End);
		}
	}
}