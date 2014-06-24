package dae
{
	import flash.geom.Matrix3D;

	public class DAEElement
	{
		public var id:String;
		public var name:String;
		public var sid:String;
		public var userData:*;
		protected var ns:Namespace;
		
		public function DAEElement(element:XML = null)
		{
			if (element)
				deserialize(element);
		}
		
		public function deserialize(element:XML):void
		{
			ns = element.namespace();
			id = element.@id.toString();
			name = element.@name.toString();
			sid = element.@sid.toString();
		}
		
		public function dispose():void
		{
		}
		
		protected function traverseChildHandler(child:XML, nodeName:String):void
		{
		}
		
		protected function traverseChildren(element:XML, name:String = null):void
		{
			var children:XMLList = name? element.ns::[name] : element.children();
			var count:int = children.length();
			
			for (var i:uint = 0; i < count; i++)
				traverseChildHandler(children[i], children[i].name().localName);
		}
		
		protected function convertMatrix(matrix:Matrix3D):void
		{
			var indices:Vector.<int> = Vector.<int>([2, 6, 8, 9, 11, 14]);
			var raw:Vector.<Number> = matrix.rawData;
			for (var i:uint = 0; i < indices.length; i++)
				raw[indices[i]] *= -1.0;
			
			matrix.rawData = raw;
		}
		
		protected function getRootElement(element:XML):XML
		{
			var tmp:XML = element;
			while (tmp.name().localName != "COLLADA")
				tmp = tmp.parent();
			
			return (tmp.name().localName == "COLLADA"? tmp : null);
		}
		
		protected function parseUintList(xml : XML):Vector.<uint>
		{
			var feed			: String		= String(xml);
			var feedLength		: uint			= feed.length;
			var floats:Vector.<uint> = new Vector.<uint>();
			
			var currentNumber	: uint			= 0;
			var lastWasSpace	: Boolean		= false;
			var numId			: uint			= 0;
			
			for (var charId : uint = 0; charId < feedLength; ++charId)
			{
				var charCode : uint = feed.charCodeAt(charId) - 48;
				
				if (charCode < 10)
				{
					currentNumber	*= 10;
					currentNumber	+= charCode;
					lastWasSpace	= false;
				}
				else if (!lastWasSpace)
				{
					floats[numId++]	= currentNumber;
					currentNumber	= 0;
					lastWasSpace	= true;
				}
			}
			
			if (!lastWasSpace)
				floats[numId++] = currentNumber;
			
			return floats;
		}
		
		protected function readFloatArray(element:XML):Vector.<Number>
		{
			var raw:String = String(element);
			var parts:Array = raw.split(/[ \t\n\r]+/g);
			var floats:Vector.<Number> = new Vector.<Number>(parts.length);
			
			for (var i:uint = 0; i < parts.length; i++)
				floats[i] = parseFloat(parts[i]);
			
			return floats;
		}
		
//		protected function readIntArray(element:XML):Vector.<int>
//		{
//			var raw:String = String(element);
//			var parts:Array = raw.split(/\s+/);
//			var ints:Vector.<int> = new Vector.<int>();
//			
//			for (var i:uint = 0; i < parts.length; i++)
//				ints.push(parseInt(parts[i], 10));
//			
//			return ints;
//		}
		
//		protected function readUintArray(element:XML):Vector.<uint>
//		{
//			var raw:String = readText(element);
//			var parts:Array = raw.split(/\s+/);
//			var ints:Vector.<uint> = new Vector.<uint>();
//			
//			for (var i:uint = 0; i < parts.length; i++)
//				ints.push(parseInt(parts[i], 10));
//			
//			return ints;
//		}
		
		protected function readStringArray(element:XML):Vector.<String>
		{
			var raw:String = String(element);
			var parts:Array = raw.split(/\s+/);
			var strings:Vector.<String> = new Vector.<String>();
			
			for (var i:uint = 0; i < parts.length; i++)
				strings.push(parts[i]);
			
			return strings;
		}
		
		protected function readIntAttr(element:XML, name:String, defaultValue:int = 0):int
		{
			var v:int = parseInt(element.@[name], 10);
			v = v == 0? defaultValue : v;
			return v;
		}
		
//		protected function readText(element:XML):String
//		{
//			return trimString(element.text().toString());
//		}
		
//		protected function trimString(s:String):String
//		{
//			return s.replace(/^\s+/, "").replace(/\s+$/, "");
//		}
	}
}