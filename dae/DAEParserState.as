package dae
{
	public class DAEParserState
	{
		public static const LOAD_XML:uint = 0;
		public static const PARSE_IMAGES:uint = 1;
		public static const PARSE_MATERIALS:uint = 2;
		public static const PARSE_GEOMETRIES:uint = 3;
		public static const PARSE_CONTROLLERS:uint = 4;
		public static const PARSE_VISUAL_SCENE:uint = 5;
		public static const PARSE_ANIMATIONS:uint = 6;
		public static const PARSE_COMPLETE:uint = 7;
	}
}