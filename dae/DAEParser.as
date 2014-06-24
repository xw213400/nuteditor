package dae
{
	import flash.display.BitmapData;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import model.logic.World3D;
	
	import nut.core.Geometry;
	import nut.core.Mesh;
	import nut.core.Nut;
	import nut.core.NutTexture;
	import nut.core.ResourceManager;
	import nut.core.material.ShaderBase;
	import nut.ext.model.Bone;
	import nut.ext.model.BoneAnim;
	import nut.ext.model.Model;
	import nut.ext.model.NutAnimation;
	import nut.ext.model.Skeleton;
	import nut.ext.model.SkinDataProvider;
	import nut.util.BytesLoader;
	import nut.util.shaders.PositionDiffuseShader;
	import nut.util.shaders.PositionPhongShader;
	import nut.util.shaders.SkeletonDiffuseShader;
	import nut.util.shaders.SkeletonPhongShader;
	import nut.util.shaders.SuperShader;
	
	/**
	 * DAEParser provides a parser for the DAE data type.
	 */
	public class DAEParser
	{
		private var _doc:XML;
		private var _ns:Namespace;
		private var _parseState:uint = 0;
		private var _dependencyCount:uint = 0;
		private var _configFlags:uint;
		private var _parseFlags:uint;
		private var _libImages:Object;
		private var _libEffects:Object;
		private var _libMaterials:Object;
		private var _libGeometries:Object;
		private var _libControllers:Object;
		private var _libAnimations:Object;
		private var _scene:DAEScene;
		private var _root:DAEVisualScene;
		private var _model :Model;
		private var _meshes:Vector.<Mesh>;
		private var _skeleton:Skeleton;
		private var _animationInfo:DAEAnimationInfo;
		private var _context:String = "";
		
		public function DAEParser()
		{
			_parseState = DAEParserState.PARSE_GEOMETRIES;
		}
		
		public function get context():String
		{
			return _context;
		}

		public function set context(value:String):void
		{
			_context = value;
		}

		public function get skeleton():Skeleton
		{
			return _skeleton;
		}

		public function get model():Model
		{
			return _model;
		}

		/**
		 * Indicates whether or not a given file extension is supported by the parser.
		 * @param extension The file extension of a potential file to be parsed.
		 * @return Whether or not the given file type is supported.
		 */
		public static function supportsType(extension:String):Boolean
		{
			extension = extension.toLowerCase();
			return extension == "dae";
		}
		
		/**
		 * Tests whether a data block can be parsed by the parser.
		 * @param data The data block to potentially be parsed.
		 * @return Whether or not the given data is supported.
		 */
		public static function supportsData(data:*):Boolean
		{
			if (String(data).indexOf("COLLADA") != -1 || String(data).indexOf("collada") != -1)
				return true;
			
			return false;
		}
		
		private function loadImage(id:String, url:String):void
		{
			var loader:BytesLoader = new BytesLoader();
			loader.load(_context+url, onImageLoaded, BytesLoader.TEXTURE, id);
		}
		
		private function onImageLoaded(data:BitmapData, id:String):void
		{
			if (data != null)
				(_libImages[id] as DAEImage).resource.setContent(data);
			else
				(_libImages[id] as DAEImage).resource.setContent(ResourceManager.DFT_BITMAP);
		}

		public function parse(xml:XML):void
		{
			_doc = xml;
			_ns = _doc.namespace();
			
			_model = new Model();
			
			_libImages = parseLibrary(_doc._ns::library_images._ns::image, DAEImage);
			for (var id:String in _libImages)
			{
				var image:DAEImage = _libImages[id] as DAEImage;
				image.resource = new NutTexture();
				image.resource.setContent(ResourceManager.DFT_BITMAP);
				image.resource.name = image.init_from;
				loadImage(id, image.init_from);
			}
			
			_libEffects = parseLibrary(_doc._ns::library_effects._ns::effect, DAEEffect);
			
			_libMaterials = parseLibrary(_doc._ns::library_materials._ns::material, DAEMaterial);
			
			setupMaterials();
			
			//DAEParserState.PARSE_GEOMETRIES
			_libGeometries = parseLibrary(_doc._ns::library_geometries._ns::geometry, DAEGeometry);
			translateMeshes();
			
			//DAEParserState.PARSE_CONTROLLERS
			_libControllers = parseLibrary(_doc._ns::library_controllers._ns::controller, DAEController);
			
			//DAEParserState.PARSE_ANIMATIONS
			_libAnimations = parseLibrary(_doc._ns::library_animations._ns::animation, DAEAnimation);
			
			//DAEParserState.PARSE_VISUAL_SCENE
			if (_doc.._ns::scene && _doc.._ns::scene.length())
			{
				_scene = new DAEScene(_doc.._ns::scene[0]);
				
				var list:XMLList = _doc.._ns::visual_scene.(@id == _scene.instance_visual_scene.url);
				
				if (list.length())
				{
					_root = new DAEVisualScene(this, list[0]);
					_root.updateTransforms(_root);
					_skeleton = new Skeleton();
					_skeleton.root = parseSceneGraph(_root);
					
					_animationInfo = parseAnimationInfo();
					if (_animationInfo.numFrames > 0)
						parseAnimation();
					
					_model.skeleton = _skeleton;
					
					parseController(_root);
				}
			}
			
			for (var i:int = 0; i != _meshes.length; ++i)
			{
				var mesh:Mesh = _meshes[i];
				var diffuseMap:NutTexture = mesh.material.getTexture("PositionDiffuseShader","diffuseMap");
				
				mesh.material.addLight(World3D.instance.ambientLight);
				mesh.material.addLight(World3D.instance.sunLight);
				
				mesh.material.clearPass();
				mesh.material.addShader(SuperShader.getShader(mesh));
				mesh.material.getProperty("SuperShader","diffuseMap").value = diffuseMap;
			}
		}
		
		private function parseLibrary(list:XMLList, clas:Class):Object
		{
			var library:Object = {};
			for (var i:uint = 0; i < list.length(); i++) {
				var obj:* = new clas(list[i]);
				library[ obj.id ] = obj;
			}
			
			return library;
		}
		
		private function setupMaterials():void
		{
			for each (var material:DAEMaterial in _libMaterials)
			{
				if (_libEffects.hasOwnProperty(material.instance_effect.url))
				{
					var effect:DAEEffect = _libEffects[material.instance_effect.url] as DAEEffect;
					effect.material = setupMaterial(material, effect);
					effect.name = material.name;
				}
			}
		}
		
		private function setupMaterial(material:DAEMaterial, effect:DAEEffect):ShaderBase
		{
			if (!effect || !material)
				return null;
			
			var shader:ShaderBase = PositionDiffuseShader.instance;
			var diffuse:DAEColorOrTexture = effect.shader.props["diffuse"];
			
			if (diffuse && diffuse.texture)
			{
				var image:DAEImage;
				if (diffuse.texture)
					image = _libImages[diffuse.texture.texture];
				if (effect.surface)
					image = _libImages[effect.surface.init_from];
				
				if (image.resource !== null)
				{
					effect.image = image.resource;
//					shader.data.setProperty("diffuseMap", image.resource);
				}
			}
			
			if (effect.image == null)
				effect.image = Nut.resMgr.getTexture("default");
			
//			mat.name = material.id;
			
			return shader;
		}
		
		private function getMeshEffects(bindMaterial:DAEBindMaterial, mesh:DAEMesh):Vector.<DAEEffect>
		{
			var effects:Vector.<DAEEffect> = new Vector.<DAEEffect>();
			if (!bindMaterial)
				return effects;
			
			var material:DAEMaterial;
			var effect:DAEEffect;
			var instance:DAEInstanceMaterial;
			var i:uint, j:uint;
			
			for (i = 0; i < mesh.primitives.length; i++) {
				if (!bindMaterial.instance_material)
					continue;
				for (j = 0; j < bindMaterial.instance_material.length; j++) {
					instance = bindMaterial.instance_material[j];
					if (mesh.primitives[i].material == instance.symbol) {
						material = _libMaterials[instance.target] as DAEMaterial;
						effect = _libEffects[material.instance_effect.url];
						if (effect)
							effects.push(effect);
						break;
					}
				}
			}
			
			return effects;
		}
		
		private function translateMeshes():void
		{
			_meshes = new Vector.<Mesh>();
			var daeGeometry:DAEGeometry;
			
			for (var id:String in _libGeometries)
			{
				daeGeometry = _libGeometries[id] as DAEGeometry;
				if (daeGeometry.mesh)
				{
					var geoms:Vector.<Geometry> = translateGeometries(daeGeometry.mesh);
					for (var i:int = 0; i!= geoms.length; ++i)
					{
						var mesh:Mesh = new Mesh(geoms[i]);
						mesh.extra = id;
						_meshes.push(mesh);
					}
				}
			}
		}
		
		private function translateGeometries(mesh:DAEMesh):Vector.<Geometry>
		{
			var geoms:Vector.<Geometry> = new Vector.<Geometry>();
			for (var i:uint = 0; i < mesh.primitives.length; i++) {
				var geom:Geometry = translatePrimitive(mesh, mesh.primitives[i]);
				if (geom)
					geoms.push(geom);
			}
			
			return geoms;
		}
		
		private function translatePrimitive(mesh:DAEMesh, primitive:DAEPrimitive, reverseTriangles:Boolean=true):Geometry
		{
			var geom:Geometry = null;
			var indexData:ByteArray = new ByteArray();
			var positions:Vector.<Number> = new Vector.<Number>();
			var normals:Vector.<Number> = new Vector.<Number>();
			var uvs:Vector.<Number> = new Vector.<Number>();
			var uv2s:Vector.<Number> = new Vector.<Number>();
			var faces:Vector.<DAEFace> = primitive.create(mesh);
			var v:DAEVertex, f:DAEFace;
			var i:int;
			
			indexData.endian = Endian.LITTLE_ENDIAN;
			
			// vertices, normals and uvs
			for (i = 0; i < primitive.vertices.length; i++)
			{
				v = primitive.vertices[i];
				positions.push(v.x, v.y, v.z);
				normals.push(v.nx, v.ny, v.nz);

				if (v.numTexcoordSets > 0)
				{
					uvs.push(v.u, 1.0 - v.v);
					if (v.numTexcoordSets > 1)
						uv2s.push(v.u2, 1.0 - v.v2);
				}
			}
			
			for (i = 0; i < faces.length; i++)
			{
				f = faces[i];
				for (var j:int = f.vertices.length-1; j > -1; --j)
				{
					v = f.vertices[j];
					indexData.writeShort(v.index);
				}
			}
			
			geom = new Geometry(indexData, primitive.vertices.length);
			
			if (positions.length > 0)
				geom.vertexbuffer.addComponentFromFloats('position', Context3DVertexBufferFormat.FLOAT_3, positions);
			
			if (normals.length > 0)
				geom.vertexbuffer.addComponentFromFloats('normal', Context3DVertexBufferFormat.FLOAT_3, normals);
			
			if (uvs.length > 0)
				geom.vertexbuffer.addComponentFromFloats('uv', Context3DVertexBufferFormat.FLOAT_2, uvs);
			
			if (uv2s.length > 0)
				geom.vertexbuffer.addComponentFromFloats('uv2', Context3DVertexBufferFormat.FLOAT_2, uv2s);
			
			return geom;
		}
		
		private function parseSceneGraph(node:DAENode):Bone
		{
			var bone:Bone = new Bone();
			
			bone.name = node.id;
			bone.transform.copyFrom(node.matrix);
			
			for (var i:uint = 0; i < node.nodes.length; i++)
			{
				var child:Bone = parseSceneGraph(node.nodes[i]);
				bone.addChild(child);
			}
			
			if (node.instance_geometries.length > 0)
			{
				processGeometries(node);
			}
			
			return bone;
		}
		
		private function parseController(node:DAENode):void
		{
			for (var i:uint = 0; i < node.nodes.length; i++)
			{
				parseController(node.nodes[i]);
			}
			
			if (node.instance_controllers.length > 0)
			{
				processControllers(node);
			}
		}
		
		private function processGeometries(node:DAENode):void
		{
			var instance:DAEInstanceGeometry;
			var daeGeometry:DAEGeometry;
			var effects:Vector.<DAEEffect>;
			
			for (var i:int = 0; i < node.instance_geometries.length; i++)
			{
				instance = node.instance_geometries[i];
				daeGeometry = _libGeometries[instance.url] as DAEGeometry;
				effects = getMeshEffects(instance.bind_material, daeGeometry.mesh);
				
				if (daeGeometry && daeGeometry.mesh)
				{
					if (node.name != "")
					{
						var meshes:Vector.<Mesh> = getMeshByName(instance.url);
						for (var k:int = 0; k != meshes.length; ++k)
						{
							_model.addBindMesh(node.id, meshes[k]);
							meshes[k].transform = node.world;
						}
						if (effects.length == meshes.length) {
							for (var j:int = 0; j < meshes.length; j++)
							{
								meshes[j].material.name = effects[j].name;
								meshes[j].material.addShader(effects[j].material);
								meshes[j].material.getProperty("PositionDiffuseShader","diffuseMap").value = effects[j].image;
							}
						}
					}
				}
			}
		}
		
		private function getMeshByName(name:String):Vector.<Mesh>
		{
			var meshes:Vector.<Mesh> = new Vector.<Mesh>();
			
			if (_meshes != null)
			{
				for each (var mesh:Mesh in _meshes)
				{
					if (mesh.extra == name)
						meshes.push(mesh);
				}
			}
			
			return meshes;
		}
		
		private function processControllers(node:DAENode):void
		{
			var instance:DAEInstanceController;
			var controller:DAEController;
			var weights:uint;
			var jpv:uint;
			var daeGeometry:DAEGeometry;
			var effects:Vector.<DAEEffect>;
			
			for (var i:int = 0; i < node.instance_controllers.length; i++)
			{
				instance = node.instance_controllers[i];
				controller = _libControllers[instance.url] as DAEController;
				
				var meshes:Vector.<Mesh> = processController(controller, instance);
				if (meshes.length == 0)
					continue;
				
				daeGeometry = _libGeometries[meshes[0].extra] as DAEGeometry;
				effects = getMeshEffects(instance.bind_material, daeGeometry.mesh);
				
				if (effects.length == meshes.length)
				{
					for (j = 0; j < meshes.length; j++)
					{
						meshes[j].material.name = effects[j].name;
						meshes[j].material.addShader(effects[j].material);
						meshes[j].material.getProperty("PositionDiffuseShader","diffuseMap").value = effects[j].image;
					}
				}
				
				var skin:DAESkin = controller.skin;
				var skinDataProvider:SkinDataProvider = new SkinDataProvider(controller.id, skin.bind_shape_matrix);

				for (var j:int = 0; j != meshes.length; ++j)
				{
					_model.addBindMesh(node.id, meshes[j]);
//					skinController.addMesh(meshes[j].userData as String);
					meshes[j].skinDataProvider = skinDataProvider;
					applySkinController(meshes[j], _libGeometries[meshes[j].extra].mesh, controller.skin, j);
				}

				for (var n:int = 0; n < skin.joints.length; n++)
				{
					var node:DAENode = _root.findNodeBySid(controller.skin.joints[n]);
					if (node != null)
					{
						skinDataProvider.addJoint(node.id, skin.inv_bind_matrix[n]);
					}
				}
				
				_model.addSkinProvider(skinDataProvider);
			}
		}
		
		private function parseAnimation():void
		{
			var numFrames:int = _animationInfo.maxTime*30;
			var animation:NutAnimation = new NutAnimation("test");
			
			for each (var bone:Bone in _skeleton.bones)
			{
				var node:DAENode = _root.findNodeById(bone.name) || _root.findNodeBySid(bone.name);
				if (node == null || node.channels.length == 0)
					continue;
//				trace("=====: "+bone.name);
				var boneAnim:BoneAnim = new BoneAnim(bone.name);
				for (var i:int = 0; i <= numFrames; ++i)
				{
					var time:Number = i/numFrames*_animationInfo.maxTime;
					var matrix:Matrix3D = node.getAnimatedMatrix(time) || node.matrix;
					boneAnim.addMatrix(matrix);

//					if (bone.name == 'mixamorig_RightHand')
//					traceMatrix(i.toString(), matrix);
				}
				
				animation.addAnim(boneAnim);
			}
			
			_skeleton.addAnim(animation);
		}
		
		private function traceMatrix(info:String, matrix:Matrix3D):void
		{
			trace('---'+info+'---');
			var m:Vector.<Vector3D> = matrix.decompose();
			trace('pos:', m[0].x.toPrecision(3), m[0].y.toPrecision(3), m[0].z.toPrecision(3));
			trace('rot:', m[1].x.toPrecision(3), m[1].y.toPrecision(3), m[1].z.toPrecision(3));
			trace('sca:', m[2].x.toPrecision(3), m[2].y.toPrecision(3), m[2].z.toPrecision(3));
		}
		
		private function processController(controller:DAEController, instance:DAEInstanceController):Vector.<Mesh>
		{
			var meshes:Vector.<Mesh> = new Vector.<Mesh>();
			
			if (controller == null || controller.skin == null)
				return meshes;
			
			meshes = processControllerSkin(controller, instance);
			
			return meshes;
		}
		
		private function processControllerSkin(controller:DAEController, instance:DAEInstanceController):Vector.<Mesh>
		{
			var meshes:Vector.<Mesh> = getMeshByName(controller.skin.source);
			
			if (meshes.length == 0)
				meshes = processController(_libControllers[controller.skin.source], instance);
			
			if (meshes.length == 0)
				return meshes;
			
			return meshes;
		}
		
		private function parseAnimationInfo():DAEAnimationInfo
		{
			var info:DAEAnimationInfo = new DAEAnimationInfo();
			info.minTime = Number.MAX_VALUE;
			info.maxTime = -info.minTime;
			info.numFrames = 0;
			
			for each (var animation:DAEAnimation in _libAnimations) {
				for each (var channel:DAEChannel in animation.channels) {
					var node:DAENode = _root.findNodeById(channel.targetId);
					if (node) {
						node.channels.push(channel);
						info.minTime = Math.min(info.minTime, channel.sampler.minTime);
						info.maxTime = Math.max(info.maxTime, channel.sampler.maxTime);
						info.numFrames = Math.max(info.numFrames, channel.sampler.input.length);
					}
				}
			}
			
			return info;
		}
		
		private function applySkinController(m:Mesh, mesh:DAEMesh, skin:DAESkin, i:int):void
		{
			var skinned_geom:Geometry;
			var primitive:DAEPrimitive;
			var j:uint, k:uint;

			var maxBones:int = skin.maxBones;
			if (maxBones%2==1)
			{
				maxBones++;
			}
			
			var bws:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
			
			for (j=0; j!=maxBones; j+=2)
			{
				bws.push(new Vector.<Number>());
			}
			
			primitive = mesh.primitives[i];

			for (j = 0; j < primitive.vertices.length; j++)
			{
				var weights:Vector.<DAEVertexWeight> = skin.weights[primitive.vertices[j].daeIndex];
				
				for (k = 0; k < weights.length; k++)
				{
					var influence:DAEVertexWeight = weights[k];
					// indices need to be multiplied by 3 (amount of matrix registers)
					bws[k>>1].push(influence.joint*3);
					bws[k>>1].push(influence.weight);
				}
				
				for (k = weights.length; k < maxBones; k++)
				{
					bws[k>>1].push(influence.joint*3);
					bws[k>>1].push(0);
				}
			}
			
			skinned_geom = m.geometry;
			skinned_geom.maxBones = maxBones;

			var formats:Array = new Array();
			var names:Array = new Array();
			
			for (j=0; j!=maxBones; j+=2)
			{
				formats.push(Context3DVertexBufferFormat.FLOAT_4);
				names.push('bone'+((j+1)*10+j+2).toString());
				skinned_geom.vertexbuffer.addComponentFromFloats(
					'bone'+((j+1)*10+j+2).toString(), 
					Context3DVertexBufferFormat.FLOAT_4, bws[j/2]);
			}
		}
	}
}
