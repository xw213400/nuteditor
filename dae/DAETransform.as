package dae
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class DAETransform extends DAEElement
	{
		public var type:String;
		public var data:Vector.<Number>;
		
		public function DAETransform(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.type = element.name().localName;
			this.data = readFloatArray(element);
		}
		
		public function get matrix():Matrix3D
		{
			var matrix:Matrix3D = new Matrix3D();
			
			switch (this.type) {
				case "matrix":
					matrix = new Matrix3D(this.data);
					matrix.transpose();
					break;
				case "scale":
					matrix.appendScale(this.data[0], this.data[1], this.data[2]);
					break;
				case "translate":
					matrix.appendTranslation(this.data[0], this.data[1], this.data[2]);
					break;
				case "rotate":
					var axis:Vector3D = new Vector3D(this.data[0], this.data[1], this.data[2]);
					matrix.appendRotation(this.data[3], axis);
			}
			
			return matrix;
		}
	}
}