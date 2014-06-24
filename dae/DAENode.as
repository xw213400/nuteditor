package dae
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class DAENode extends DAEElement
	{
		public var type:String;
		public var parent:DAENode;
		public var parser:DAEParser;
		public var nodes:Vector.<DAENode>;
		public var transforms:Vector.<DAETransform>;
		public var instance_controllers:Vector.<DAEInstanceController>;
		public var instance_geometries:Vector.<DAEInstanceGeometry>;
		public var world:Matrix3D;
		public var channels:Vector.<DAEChannel>;
		private var _root:XML;
		
		public function DAENode(parser:DAEParser, element:XML = null, parent:DAENode = null)
		{
			this.parser = parser;
			this.parent = parent;
			this.channels = new Vector.<DAEChannel>();
			
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			
			_root = getRootElement(element);
			
			this.type = element.@type.toString().length? element.@type.toString() : "NODE";
			this.nodes = new Vector.<DAENode>();
			this.transforms = new Vector.<DAETransform>();
			this.instance_controllers = new Vector.<DAEInstanceController>();
			this.instance_geometries = new Vector.<DAEInstanceGeometry>();
			traverseChildren(element);
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			var instances:XMLList;
			var instance:DAEInstance;
			
			switch (nodeName) {
				case "node":
					this.nodes.push(new DAENode(this.parser, child, this));
					break;
				
				case "instance_controller":
					instance = new DAEInstanceController(child);
					this.instance_controllers.push(instance);
					break;
				
				case "instance_geometry":
					this.instance_geometries.push(new DAEInstanceGeometry(child));
					break;
				
				case "instance_node":
					instance = new DAEInstanceNode(child);
					instances = _root.ns::library_nodes.ns::node.(@id == instance.url);
					if (instances.length())
						this.nodes.push(new DAENode(this.parser, instances[0], this));
					break;
				
				case "matrix":
				case "translate":
				case "scale":
				case "rotate":
					this.transforms.push(new DAETransform(child));
					break;
			}
		}
		
		public function getMatrixBySID(sid:String):Matrix3D
		{
			var transform:DAETransform = getTransformBySID(sid);
			if (transform)
				return transform.matrix;
			
			return null;
		}
		
		public function getTransformBySID(sid:String):DAETransform
		{
			for each (var transform:DAETransform in this.transforms) {
				if (transform.sid == sid)
					return transform;
			}
			
			return null;
		}
		
		public function getAnimatedMatrix(time:Number):Matrix3D
		{
			var matrix:Matrix3D = new Matrix3D();
			var tdata:Vector.<Number>;
			var channelsBySID:Object = {};
			var transform:DAETransform;
			var channel:DAEChannel;
			
			for (var i:int = 0; i < this.channels.length; i++)
			{
				channel = this.channels[i];
				channelsBySID[channel.targetSid] = channel;
			}
			
			for (i = 0; i < this.transforms.length; i++)
			{
				transform = this.transforms[i];
				tdata = transform.data;
				if (channelsBySID.hasOwnProperty(transform.sid))
				{
					var m:Matrix3D = new Matrix3D();
					var rawData:Vector.<Number> = null;

					for (var j:int = 0; j < this.channels.length; j++)
					{
						channel = channels[j];
						var frameData:DAEFrameData = channel.sampler.getFrameData(time);
						
						if (frameData)
						{
							var odata:Vector.<Number> = frameData.data;
							
							switch (transform.type)
							{
								case "matrix":
									if (channel.arrayAccess && channel.arrayIndices.length > 1)
									{
										if (rawData == null)
											rawData = new Vector.<Number>(16);
										
										var r:int = channel.arrayIndices[0];
										var c:int = channel.arrayIndices[1];
										
										rawData[r*4+c] = odata[0];
									}
									else if (channel.dotAccess)
									{
										trace("unhandled matrix array access");
									}
									else if (odata.length == 16)
									{
										m.copyRawDataFrom(odata);
										m.transpose();
									}
									else
									{
										trace("unhandled matrix " + transform.sid + " " + odata);
									}
									break;
								case "rotate":
									if (channel.arrayAccess)
									{
										trace("unhandled rotate array access");
									}
									else if (channel.dotAccess)
									{	
										if (channel.dotAccessor == "ANGLE")
										{
											m.appendRotation(odata[0], new Vector3D(tdata[0], tdata[1], tdata[2]));
										}
										else
										{
											trace("unhandled rotate dot access " + channel.dotAccessor);
										}
									}
									else
									{
										trace("unhandled rotate");
									}
									break;
								case "scale":
									if (channel.arrayAccess)
									{
										trace("unhandled scale array access");
									}	
									else if (channel.dotAccess)
									{
										switch (channel.dotAccessor)
										{
											case "X":
												m.appendScale(odata[0], tdata[1], tdata[2]);
												break;
											case "Y":
												m.appendScale(tdata[0], odata[0], tdata[2]);
												break;
											case "Z":
												m.appendScale(tdata[0], tdata[1], odata[0]);
												break;
											default:
												trace("unhandled scale dot access " + channel.dotAccessor);
										}
									}
									else
									{
										trace("unhandled scale: " + odata.length);
									}
									break;
								case "translate":
									if (channel.arrayAccess)
									{
										trace("unhandled translate array access");
									}
									else if (channel.dotAccess)
									{	
										switch (channel.dotAccessor)
										{
											case "X":
												m.appendTranslation(odata[0], tdata[1], tdata[2]);
												break;
											case "Y":
												m.appendTranslation(tdata[0], odata[0], tdata[2]);
												break;
											case "Z":
												m.appendTranslation(tdata[0], tdata[1], odata[0]);
												break;
											default:
												trace("unhandled translate dot access " + channel.dotAccessor);
										}
									}
									else
									{
										m.appendTranslation(odata[0], odata[1], odata[2]);
									}
									break;
								default:
									trace("unhandled transform type " + transform.type);
									continue;
							}
						}
					}
					if (rawData != null)
						m.rawData = rawData;
					
					matrix.prepend(m);
				}
				else
				{
					matrix.prepend(transform.matrix);
				}
			}
			
			return matrix;
		}
		
		public function get matrix():Matrix3D
		{
			var matrix:Matrix3D = new Matrix3D();
			for (var i:uint = 0; i < this.transforms.length; i++)
				matrix.prepend(this.transforms[i].matrix);
			
			return matrix;
		}
	}
}