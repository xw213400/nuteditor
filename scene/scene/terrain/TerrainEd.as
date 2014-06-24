package scene.scene.terrain
{
	import flash.utils.Dictionary;
	
	import nut.ext.scene.GameScene;
	import nut.ext.scene.terrain.Chunk;
	import nut.ext.scene.terrain.Terrain;

	public class TerrainEd extends Terrain
	{
		public function TerrainEd(gameScene:GameScene, x_count:int, z_count:int)
		{
			super(gameScene, x_count, z_count);
		}
		
		override protected function createChunk(i:int):Chunk
		{
			return new ChunkEd(this, i);
		}
		
		public function createChunks():void
		{
			for (var i:int=0; i!=_chunkCount; ++i)
			{
				_chunks[i].createMesh(true);
				_gameScene.scene.addChild(_chunks[i].chunkMesh);
			}
		}
		
		public function setUVRepeat(path:String, uvRepeat:int):void
		{
			_uvRepeats[path] = uvRepeat;
			
			for (var i:int=0; i!=_chunkCount; ++i)
			{
				_chunks[i].updateUVRepeat();
			}
		}
		
		public function getUsedTextures():Vector.<String>
		{
			var texts:Dictionary = new Dictionary();
			
			for (var i:int=0; i!=_chunkCount; ++i)
			{
				for (var j:int=0; j!=3; ++j)
				{
					var path:String = _chunks[i].getSurfacePath(j);
					if (path.length > 0)
						texts[path]= path;
				}
			}
			
			var textures:Vector.<String> = new Vector.<String>();
			
			for each (path in texts)
			{
				textures.push(path);
			}
			
			return textures;
		}
		
		public function setSurface(path:String, idx:int):void
		{
			for (var i:int=0; i!=_chunkCount; ++i)
			{
				_chunks[i].setSurfacePath(idx, path);
			}
		}
		
		public function findIntersectChunks(minX:Number, maxX:Number, minZ:Number, maxZ:Number):Array
		{
			var chunkList:Array = new Array();
			
			var x_half:Number = _xChunks * HALF_CHUNK_SIZE;
			var z_half:Number = _zChunks * HALF_CHUNK_SIZE;
			
			if (maxX < minX || maxZ < minZ)
				return chunkList;
			
			if (minX > x_half || maxX < -x_half || minZ > z_half || maxZ < -z_half)
				return chunkList;
			
			var x_min_i:int = (minX+x_half) / CHUNK_SIZE;
			var x_max_i:int = (maxX+x_half) / CHUNK_SIZE;
			var z_min_i:int = (minZ+z_half) / CHUNK_SIZE;
			var z_max_i:int = (maxZ+z_half) / CHUNK_SIZE;
			
			if (x_min_i < 0)
				x_min_i = 0;
			
			if (x_max_i > _xChunks-1)
				x_max_i = _xChunks-1;
			
			if (z_min_i < 0)
				z_min_i = 0;
			
			if (z_max_i > _xChunks-1)
				z_max_i = _xChunks-1;
			
			for (var z:int=z_min_i; z<=z_max_i; ++z)
			{
				for (var x:int=x_min_i; x<=x_max_i; ++x)
				{
					chunkList.push(z*_xChunks+x);
				}
			}
			
			return chunkList;
		}
		
		public function setHeight(chunk:Chunk, x:int, z:int, height:Number):Array
		{
			var chunks:Array = new Array();
			
			chunk.heightData[z*VERT_NUM+x] = height;
			chunks.push(chunk);
			
			if (x == 0 && chunk.idx_x > 0)	//left 3
			{
				var left:Chunk = _chunks[chunk.idx-1];
				chunks.push(left);
				left.heightData[z*VERT_NUM+VERT_NUM-1] = height;
				
				if (z == 0 && chunk.idx_z > 0)
				{
					var leftUp:Chunk = _chunks[chunk.idx-1-_xChunks];
					chunks.push(leftUp);
					leftUp.heightData[VERT_IDX_MAX-1] = height;
				}
				else if (z == VERT_NUM-1 && chunk.idx_z < _zChunks-1)
				{
					var leftDown:Chunk = _chunks[chunk.idx-1+_xChunks];
					chunks.push(leftDown);
					leftDown.heightData[VERT_NUM-1] = height;
				}
			}
			else if (x == VERT_NUM-1 && chunk.idx_x < _xChunks-1)	//right 3
			{
				var right:Chunk = _chunks[chunk.idx+1];
				chunks.push(right);
				right.heightData[z*VERT_NUM] = height;
				
				if (z == 0 && chunk.idx_z > 0)
				{
					var rightUp:Chunk = _chunks[chunk.idx+1-_xChunks];
					chunks.push(rightUp);
					rightUp.heightData[(VERT_NUM-1)*VERT_NUM] = height;
				}
				else if (z == VERT_NUM-1 && chunk.idx_z < _zChunks-1)
				{
					var rightDown:Chunk = _chunks[chunk.idx+1+_xChunks];
					chunks.push(rightDown);
					rightDown.heightData[0] = height;
				}
			}
			
			if (z == 0 && chunk.idx_z > 0) 	//up
			{
				var up:Chunk = _chunks[chunk.idx-_xChunks];
				chunks.push(up);
				up.heightData[(VERT_NUM-1)*VERT_NUM+x] = height;
			}
			else if (z == VERT_NUM-1 && chunk.idx_z < _zChunks-1)	//down
			{
				var down:Chunk = _chunks[chunk.idx+_xChunks];
				chunks.push(down);
				down.heightData[x] = height;
			}
			
			return chunks;
		}
		
		public function fixChunkEdgeError():void
		{
			for (var z:int = 0; z!=_zChunks;++z)
			{
				for (var x:int = 0; x!=_xChunks-1;++x)
				{
					var chunk1:Chunk = _chunks[x+z*_xChunks];
					var chunk2:Chunk = _chunks[x+1+z*_xChunks];
					
					for (var i:int=0; i!=VERT_NUM; ++i)
					{
						chunk2.heightData[i*VERT_NUM] = chunk1.heightData[i*VERT_NUM+VERT_NUM-1];
					}
				}
			}
			
			for (x = 0; x!=_xChunks;++x)
			{
				for (z = 0; z!=_zChunks-1;++z)
				{
					chunk1 = _chunks[x+z*_xChunks];
					chunk2 = _chunks[x+(z+1)*_xChunks];
					
					for (i=0; i!=VERT_NUM; ++i)
					{
						chunk2.heightData[i] = chunk1.heightData[(VERT_NUM-1)*VERT_NUM+i];
					}
				}
			}
			
			for (x = 0; x!=_xChunks;++x)
			{
				for (z = 0; z!=_zChunks;++z)
				{
					(_chunks[x+z*_xChunks] as ChunkEd).updateMesh();
				}
			}
		}
		
		public function findConnectChunks(chunk:Chunk, surfaceIdx:int):Dictionary
		{
			var chunks:Dictionary = new Dictionary();
			var edge:Array = new Array();
			var path:String = chunk.getSurfacePath(surfaceIdx);
			
			if (path == "")
				return chunks;
			
			edge.push(chunk);
			while (edge.length > 0)
			{
				var c:Chunk = checkEdge(chunks, edge, surfaceIdx);
				chunks[c.idx] = c;
			}
			
			return chunks;
		}
		
		private function checkEdge(history:Dictionary, edge:Array, surfaceIdx:int):Chunk
		{
			var chunk:Chunk = edge.pop();
			var path:String = chunk.getSurfacePath(surfaceIdx);
			
			if (chunk.idx_z > 0)
			{
				var up:Chunk = _chunks[chunk.idx-_xChunks];
				if (history[up.idx] == null && up.getSurfacePath(surfaceIdx) == path)
					edge.push(up);
			}
			
			if (chunk.idx_z < _zChunks-1)
			{
				var down:Chunk = _chunks[chunk.idx+_xChunks];
				if (history[down.idx] == null && down.getSurfacePath(surfaceIdx) == path)
					edge.push(down);
			}
			
			if (chunk.idx_x > 0)
			{
				var left:Chunk = _chunks[chunk.idx-1];
				if (history[left.idx] == null && left.getSurfacePath(surfaceIdx) == path)
					edge.push(left);
			}
			
			if (chunk.idx_x <  _xChunks-1)
			{
				var right:Chunk = _chunks[chunk.idx+1];
				if (history[right.idx] == null && right.getSurfacePath(surfaceIdx) == path)
					edge.push(right);
			}
			
			return chunk;
		}
		
		public function showChunks(visible:Boolean):void
		{
			for (var i:int=0; i!=_chunkCount; ++i)
				_chunks[i].chunkMesh.visible = visible;
		}
	}
}