package scene.logic
{
	import flash.geom.Vector3D;
	
	import nut.core.Float4;
	import nut.ext.scene.terrain.Terrain;

	public class TerrainWireFrame
	{
		static private var _instance:TerrainWireFrame = null;
		private var _grids:Vector.<ChunkWireFrame> = new Vector.<ChunkWireFrame>();
		
		public function TerrainWireFrame()
		{
		}

		public static function get instance():TerrainWireFrame
		{
			if (_instance == null)
				_instance = new TerrainWireFrame();
			
			return _instance;
		}
		
		public function showGrid(visible:Boolean, isWalkData:Boolean):void
		{
			var terrain:Terrain = World3D.instance.gameScene.terrain;
			var chunkCount:int = terrain.xChunks * terrain.zChunks;
			
			var color:Float4 = new Float4(0.8,0.8,0.8,1);
			if (isWalkData)
				color = new Float4(0.3,0.3,0.3,1);
			
			if (visible)
			{
				terrain.prepareWalkHeight();
				
				if (_grids.length == 0)
				{
					for (var i:int=0; i!=chunkCount; ++i)
					{
						var cwf:ChunkWireFrame = new ChunkWireFrame();
						_grids.push(cwf);
						cwf.color = color;
						cwf.updateSeg(terrain.getChunk(i), isWalkData);
						World3D.instance.gameScene.scene.addChild(cwf);
					}
				}
				else
				{
					for (i=0; i!=chunkCount; ++i)
					{
						_grids[i].visible = true;
						_grids[i].color = color;
						_grids[i].updateSeg(terrain.getChunk(i), isWalkData);
					}
				}
			}
			else
			{
				for (i=0; i!=_grids.length; ++i)
				{
					_grids[i].visible = false;
				}
			}
		}

	}
}