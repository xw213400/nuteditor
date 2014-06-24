package dae
{
	public class DAEVertex
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var nx:Number;
		public var ny:Number;
		public var nz:Number;
		public var u:Number;
		public var v:Number;
		public var u2:Number;
		public var v2:Number;
		public var numTexcoordSets:uint = 0;
		public var index:uint = 0;
		public var daeIndex:uint = 0;
		
		public function DAEVertex(numTexcoordSets:uint)
		{
			this.numTexcoordSets = numTexcoordSets;
			x = y = z = nx = ny = nz = u = v = u2 = v2 = 0;
		}
		
		public function normalize():void
		{
			var rl:Number = 1.0 / Math.sqrt(nx*nx + ny*ny + nz*nz);
			nx *= rl;
			ny *= rl;
			nz *= rl;
		}
	}
}