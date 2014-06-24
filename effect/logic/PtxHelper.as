package effect.logic
{
	import nut.core.Float4;
	import nut.core.material.DataProvider;
	import nut.core.material.Material;
	import nut.ext.effect.particle.ParticleSystem;
	import nut.util.shaders.particle.ParticleShader;

	public class PtxHelper
	{
		static public function addComponent(ptx:ParticleSystem, type:uint):Boolean
		{
			var data:DataProvider = ptx.material.getData("ParticleShader");
			
			if (type == EditData.T_BoxInit)
			{
				if (data.getProperty("boxXRange") == null)
				{
					data.addProperty("boxXRange", Float4.X_AXIS.clone());
					data.addProperty("boxYRange", Float4.Y_AXIS.clone());
					data.addProperty("boxZRange", Float4.Z_AXIS.clone());
					
					ptx.material.refreshShader(ParticleShader.getShader(ptx));
					
					return true;
				}
			}
			else if (type == EditData.T_LinearForceAff)
			{
				if (data.getProperty("forceAdj") == null)
				{
					data.addProperty("forceAdj", Float4.Y_AXIS.clone());
					
					ptx.material.refreshShader(ParticleShader.getShader(ptx));
					
					return true;
				}
			}
			else if (type == EditData.T_ColorRangeInit)
			{
				if (data.getProperty("colorMin") == null)
				{
					data.addProperty("colorMin", Float4.BLACK.clone());
					data.addProperty("colorMax", Float4.WHITE.clone());
					
					ptx.material.refreshShader(ParticleShader.getShader(ptx));
					
					return true;
				}
			}
			else if (type == EditData.T_ScaleRangeInit)
			{
				if (data.getProperty("scaleRangeInit") == null)
				{
					data.addProperty("scaleRangeInit", Float4.ONE.clone());
					
					ptx.material.refreshShader(ParticleShader.getShader(ptx));
					
					return true;
				}
			}
			else if (type == EditData.T_RotateInit)
			{
				if (data.getProperty("rotation") == null)
				{
					data.addProperty("rotation", Float4.BLACK.clone());
					
					ptx.material.refreshShader(ParticleShader.getShader(ptx));
					
					return true;
				}
			}
			else if (type == EditData.T_ScaleAff)
			{
				if (data.getProperty("scaleAdj") == null)
				{
					data.addProperty("scaleAdj", Float4.Z_AXIS.clone());
					
					ptx.material.refreshShader(ParticleShader.getShader(ptx));
					
					return true;
				}
			}
			else if (type == EditData.T_ColorFadeAff)
			{
				if (data.getProperty("colorAdj1") == null)
				{
					data.addProperty("colorAdj1", Float4.ZERO.clone());
					data.addProperty("colorAdj2", Float4.ZERO.clone());
					data.addProperty("timePhase", Float4.BLACK.clone());
					
					ptx.material.refreshShader(ParticleShader.getShader(ptx));
					
					return true;
				}
			}
			
			return false;
		}
		
		static public function getComponents(ptx:ParticleSystem):Vector.<uint>
		{
			var data:DataProvider = ptx.material.getData("ParticleShader");
			var types:Vector.<uint> = new Vector.<uint>();
			
			if (data.getProperty("boxXRange") != null)
				types.push(EditData.T_BoxInit);
			if (data.getProperty("forceAdj") != null)
				types.push(EditData.T_LinearForceAff);
			if (data.getProperty("colorMin") != null)
				types.push(EditData.T_ColorRangeInit);
			if (data.getProperty("scaleRangeInit") != null)
				types.push(EditData.T_ScaleRangeInit);
			if (data.getProperty("rotation") != null)
				types.push(EditData.T_RotateInit);
			if (data.getProperty("scaleAdj") != null)
				types.push(EditData.T_ScaleAff);
			if (data.getProperty("colorAdj1") != null)
				types.push(EditData.T_ColorFadeAff);
			
			return types;
		}
	}
}