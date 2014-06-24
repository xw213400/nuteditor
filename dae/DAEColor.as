package dae
{
	public class DAEColor
	{
		public var r:Number;
		public var g:Number;
		public var b:Number;
		public var a:Number;
		
		public function DAEColor()
		{
		}
		
		public function get rgb():uint
		{
			var c:uint = 0;
			c |= int(r*255.0) << 16;
			c |= int(g*255.0) << 8;
			c |= int(b*255.0);
			
			return c;
		}
		
		public function get rgba():uint
		{
			return (int(a*255.0) << 24 | this.rgb);
		}
	}
}