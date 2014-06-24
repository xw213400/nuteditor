package scene.scene
{
	import common.logic.SaveResHelper;
	
	import flash.utils.ByteArray;
	
	import nut.core.NutScene;
	import nut.core.light.AmbientLight;
	import nut.core.light.DirectionLight;
	import nut.ext.scene.GameScene;
	import nut.ext.scene.SegmentConst;
	import nut.util.BytesLoader;
	
	import scene.scene.terrain.TerrainEd;
	
	public class GameSceneEd extends GameScene
	{
		private var _nav		:XML		= null;
		
		public function GameSceneEd()
		{
			super();
		}
		
		public function get nav():XML
		{
			return _nav;
		}
		
		public function set nav(value:XML):void
		{
			_nav = value;
		}
		
		public function save():void
		{
			var data:ByteArray = super.encode();
			
			SaveResHelper.saveFile('scene/'+_name, data);
		}
		
		public function saveNav(url:String):void
		{
			if (nav != null)
			{
				var xmlData:ByteArray = new ByteArray();
				xmlData.writeUTFBytes(nav.toXMLString());
				SaveResHelper.saveFile('scene/'+_name+'.xml', xmlData, false);
			}
		}
		
		override protected function newTerrain(x_count:int, z_count:int):void
		{
			_terrain = new TerrainEd(this, x_count, z_count);
		}
		
		public function createTerrain(x_count:int, z_count:int):void
		{
			newTerrain(x_count, z_count);
			(_terrain as TerrainEd).createChunks();
		}
	}
}