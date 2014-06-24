package dae
{
	public class DAEPrimitive extends DAEElement
	{
		public var type:String;
		public var material:String;
		public var count:int;
		public var vertices:Vector.<DAEVertex>;
		private var _inputs:Vector.<DAEInput>;
		private var _p:Vector.<uint>;
		private var _vcount:Vector.<uint>;
		private var _texcoordSets:Vector.<int>;
		
		public function DAEPrimitive(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.type = element.name().localName;
			this.material = element.@material.toString();
			this.count = readIntAttr(element, "count", 0);
			
			_inputs = new Vector.<DAEInput>();
			_p = null;
			_vcount = null;
			
			var list:XMLList = element.ns::input;
			
			for (var i:uint = 0; i < list.length(); i++)
				_inputs.push(new DAEInput(list[i]));
			
			if (element.ns::p && element.ns::p.length())
				_p = parseUintList(element.ns::p[0]);
			
			if (element.ns::vcount && element.ns::vcount.length())
				_vcount = parseUintList(element.ns::vcount[0]);
		}
		
		public function create(mesh:DAEMesh):Vector.<DAEFace>
		{
			if (!prepareInputs(mesh))
				return null;
			
			var faces:Vector.<DAEFace> = new Vector.<DAEFace>();
			var input:DAEInput;
			var source:DAESource;
			//var numInputs : uint = _inputs.length;  //shared inputs offsets VERTEX and TEXCOORD
			var numInputs:uint;
			if (_inputs.length > 1)
			{
				var offsets:Array = [];
				for each (var daei:DAEInput in _inputs)
				{
					if (!offsets[daei.offset]) {
						offsets[daei.offset] = true;
						numInputs++;
					}
				}
			}
			else
				numInputs = _inputs.length;
			
			var idx:uint = 0, index:uint;
			var i:uint, j:uint;
			var vertexDict:Object = {};
			var idx32:uint;
			this.vertices = new Vector.<DAEVertex>();
			
			while (idx < _p.length)
			{
				var vcount:uint = _vcount != null? _vcount.shift() : 3;
				var face:DAEFace = new DAEFace();
				
				for (i = 0; i < vcount; i++)
				{
					var t:uint = i*numInputs;
					var vertex:DAEVertex = new DAEVertex(_texcoordSets.length);
					
					for (j = 0; j < _inputs.length; j++) {
						input = _inputs[j];
						index = _p[idx + t + input.offset];
						source = mesh.sources[input.source] as DAESource;
						idx32 = index*source.accessor.params.length;
						
						switch (input.semantic) {
							case "VERTEX":
								vertex.x = source.floats[idx32 + 0];
								vertex.y = source.floats[idx32 + 1];
								vertex.z = source.floats[idx32 + 2];
								vertex.daeIndex = index;
								break;
							case "NORMAL":
								vertex.nx = source.floats[idx32 + 0];
								vertex.ny = source.floats[idx32 + 1];
								vertex.nz = source.floats[idx32 + 2];
								vertex.normalize();
								break;
							case "TEXCOORD":
								if (input.set == _texcoordSets[0])
								{
									vertex.u = source.floats[idx32 + 0];
									vertex.v = source.floats[idx32 + 1];
								}
								else
								{
									vertex.u2 = source.floats[idx32 + 0];
									vertex.v2 = source.floats[idx32 + 1];
								}
								break;
							default:
								break;
						}
					}
					
					vertex.index = this.vertices.length;
					face.vertices.push(vertex);
					this.vertices.push(vertex);
				}
				
				if (face.vertices.length > 3)
				{
					// triangulate
					var v0:DAEVertex = face.vertices[0];
					for (var k:uint = 1; k < face.vertices.length-1; k++)
					{
						var f:DAEFace = new DAEFace();
						f.vertices.push(v0);
						f.vertices.push(face.vertices[k]);
						f.vertices.push(face.vertices[k + 1]);
						faces.push(f);
					}
					
				}
				else if (face.vertices.length == 3)
					faces.push(face);
				idx += (vcount*numInputs);
			}
			return faces;
		}
		
		private function prepareInputs(mesh:DAEMesh):Boolean
		{
			var input:DAEInput;
			var i:uint, j:uint;
			var result:Boolean = true;
			_texcoordSets = new Vector.<int>();
			
			for (i = 0; i < _inputs.length; i++) {
				input = _inputs[i];
				
				if (input.semantic == "TEXCOORD")
					_texcoordSets.push(input.set);
				
				if (!mesh.sources[input.source]) {
					result = false;
					if (input.source == mesh.vertices.id) {
						for (j = 0; j < mesh.vertices.inputs.length; j++) {
							if (mesh.vertices.inputs[j].semantic == "POSITION") {
								input.source = mesh.vertices.inputs[j].source;
								result = true;
								break;
							}
						}
					}
				}
			}
			
			return result;
		}
	}
}