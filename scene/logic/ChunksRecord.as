package scene.logic
{
	import flash.utils.Dictionary;
	
	import nut.ext.scene.terrain.Chunk;
	
	import scene.scene.terrain.ChunkEd;

	public class ChunksRecord
	{
		private var _record		:Dictionary		= new Dictionary();
		
		public function ChunksRecord()
		{
		}
		
		private function debug(str:String):void
		{
			trace("======"+str+"======");
			
			for each (var history:ChunkHistoryData in _record)
			{
				if (history.chunk)
				trace(history.chunk.idx, history.maskOld, history.maskNew);
			}
		}
		
		public function recordOldChunk(chunk:ChunkEd, mask:uint):void
		{
			var history:ChunkHistoryData = _record[chunk];
			
			if (history == null)
			{
				history = new ChunkHistoryData();
				_record[chunk] = history;
			}

			history.initOld(chunk, mask);
		}
		
		public function undo():void
		{
			for each (var history:ChunkHistoryData in _record)
			{
				history.undo();
			}
		}
		
		public function redo():void
		{
			for each (var history:ChunkHistoryData in _record)
			{
				history.redo();
			}
		}
		
		public function recordNewChunk(editedChunks:Dictionary):void
		{
//			debug("recordNewChunk begin");
			
			for each (var history:ChunkHistoryData in _record)
			{
				history.maskNew = 0;
				history.maskOld = 0;
			}
			
			for (var key:Object in editedChunks)
			{
				var mask:uint = editedChunks[key];
				var chunk:ChunkEd = key as ChunkEd;
				
				history = _record[chunk];
				
				if (history == null)
				{
					history = new ChunkHistoryData();
					_record[chunk] = history;
				}
				
				history.initNew(chunk, mask);
			}
			
//			debug("recordNewChunk end");
		}
	}
}