package dae
{
	public class DAEVisualScene extends DAENode
	{
		public function DAEVisualScene(parser:DAEParser, element:XML = null)
		{
			super(parser, element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
		}
		
		public function findNodeById(id:String, node:DAENode = null):DAENode
		{
			node = node || this;
			if (node.id == id)
				return node;
			
			for (var i:uint = 0; i < node.nodes.length; i++) {
				var result:DAENode = findNodeById(id, node.nodes[i]);
				if (result)
					return result;
			}
			
			return null;
		}
		
		public function findNodeBySid(sid:String, node:DAENode = null):DAENode
		{
			node = node || this;
			if (node.sid == sid)
				return node;
			
			for (var i:uint = 0; i < node.nodes.length; i++) {
				var result:DAENode = findNodeBySid(sid, node.nodes[i]);
				if (result)
					return result;
			}
			
			return null;
		}
		
		public function updateTransforms(node:DAENode, parent:DAENode = null):void
		{
			node.world = node.matrix.clone();
			if (parent && parent.world)
				node.world.append(parent.world);
			
			for (var i:uint = 0; i < node.nodes.length; i++)
				updateTransforms(node.nodes[i], node);
		}
	}
}