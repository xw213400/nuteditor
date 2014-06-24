package dae
{
	import flash.geom.Matrix3D;

	public class DAESkin extends DAEElement
	{
		public var source:String;
		public var bind_shape_matrix:Matrix3D;
		public var joints:Vector.<String>;
		public var inv_bind_matrix:Vector.<Matrix3D>;
		public var weights:Vector.<Vector.<DAEVertexWeight>>;
		public var jointSourceType:String;
		public var maxBones:uint;
		
		public function DAESkin(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			
			this.source = element.@source.toString().replace(/^#/, "");
			this.bind_shape_matrix = new Matrix3D();
			this.inv_bind_matrix = new Vector.<Matrix3D>();
			this.joints = new Vector.<String>();
			this.weights = new Vector.<Vector.<DAEVertexWeight>>();
			
			var children:XMLList = element.children();
			var i:uint;
			var sources:Object = {};
			
			for (i = 0; i < element.ns::source.length(); i++) {
				var source:DAESource = new DAESource(element.ns::source[i]);
				sources[source.id] = source;
			}
			
			for (i = 0; i < children.length(); i++) {
				var child:XML = children[i];
				var name:String = child.name().localName;
				
				switch (name) {
					case "bind_shape_matrix":
						parseBindShapeMatrix(child);
						break;
					case "source":
						break;
					case "joints":
						parseJoints(child, sources);
						break;
					case "vertex_weights":
						parseVertexWeights(child, sources);
						break;
					default:
						break;
				}
			}
		}
		
		public function getJointIndex(joint:String):int
		{
			for (var i:uint = 0; i < this.joints.length; i++) {
				if (this.joints[i] == joint)
					return i;
			}
			return -1;
		}
		
		private function parseBindShapeMatrix(element:XML):void
		{
			var values:Vector.<Number> = readFloatArray(element);
			this.bind_shape_matrix = new Matrix3D(values);
			this.bind_shape_matrix.transpose();
		}
		
		private function parseJoints(element:XML, sources:Object):void
		{
			var list:XMLList = element.ns::input;
			var input:DAEInput;
			var source:DAESource;
			var i:uint, j:uint;
			
			for (i = 0; i < list.length(); i++) {
				input = new DAEInput(list[i]);
				source = sources[input.source];
				
				switch (input.semantic) {
					case "JOINT":
						this.joints = source.strings;
						this.jointSourceType = source.type;
						break;
					case "INV_BIND_MATRIX":
						for (j = 0; j < source.floats.length; j += source.accessor.stride) {
							var matrix:Matrix3D = new Matrix3D(source.floats.slice(j, j + source.accessor.stride));
							matrix.transpose();
							inv_bind_matrix.push(matrix);
						}
				}
			}
		}
		
		private function parseVertexWeights(element:XML, sources:Object):void
		{
			var list:XMLList = element.ns::input;
			var input:DAEInput;
			var inputs:Vector.<DAEInput> = new Vector.<DAEInput>();
			var source:DAESource;
			var i:uint, j:uint, k:uint;
			
			if (!element.ns::vcount.length() || !element.ns::v.length())
				throw new Error("Can't parse vertex weights");
			
			var vcount:Vector.<uint> = parseUintList(element.ns::vcount[0]);
			var v:Vector.<uint> = parseUintList(element.ns::v[0]);
			var numWeights:uint = parseInt(element.@count.toString(), 10);
			numWeights = numWeights;
			var index:uint = 0;
			this.maxBones = 0;
			
			for (i = 0; i < list.length(); i++)
				inputs.push(new DAEInput(list[i]));
			
			for (i = 0; i < vcount.length; i++) {
				var numBones:uint = vcount[i];
				var vertex_weights:Vector.<DAEVertexWeight> = new Vector.<DAEVertexWeight>();
				
				this.maxBones = Math.max(this.maxBones, numBones);
				
				for (j = 0; j < numBones; j++) {
					var influence:DAEVertexWeight = new DAEVertexWeight();
					
					for (k = 0; k < inputs.length; k++) {
						input = inputs[k];
						source = sources[input.source];
						
						switch (input.semantic) {
							case "JOINT":
								influence.joint = v[index + input.offset];
								break;
							case "WEIGHT":
								influence.weight = source.floats[v[index + input.offset]];
								break;
							default:
								break;
						}
					}
					influence.vertex = i;
					vertex_weights.push(influence);
					index += inputs.length;
				}
				
				this.weights.push(vertex_weights);
			}
		}
	}
}