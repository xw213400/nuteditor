package model.command
{
	import common.command.CommandConst;

	public class Command extends CommandConst
	{
		static public const ModelEditor_OPEN_DAE		:int = 1001;
		static public const ModelEditor_OPEN_MDL		:int = 1002;
		
		static public const ModelLogic_SKELETON_READY	:int = 2001;
		static public const ModelLogic_MODEL_READY		:int = 2002;
		
		static public const DlgMaterial_CHANGE			:int = 4001;
		static public const DlgMaterial_SAVE			:int = 4002;
	}
}