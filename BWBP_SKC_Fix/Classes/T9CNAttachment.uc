//=============================================================================
// T9CNAttachment.
//
// 3rd person weapon attachment for GRS9 Pistol
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class T9CNAttachment extends BallisticCamoHandgunAttachment;


//Do your camo changes here
simulated function PostNetBeginPlay()
{
	if (CamoIndex != default.CamoIndex) 
	{
		if (CamoIndex == 4) //BB
		{
			Skins[0]=CamoWeapon.default.CamoMaterials[2];
			Skins[1]=CamoWeapon.default.CamoMaterials[6];
		}
		else if (CamoIndex == 3) //CA
		{
			Skins[0]=CamoWeapon.default.CamoMaterials[3];
			Skins[1]=CamoWeapon.default.CamoMaterials[5];
		}
		else if (CamoIndex == 2) //DA
		{
			Skins[0]=CamoWeapon.default.CamoMaterials[4];
			Skins[1]=CamoWeapon.default.CamoMaterials[5];
		}
		else if (CamoIndex == 1) //DC
		{
			Skins[0]=CamoWeapon.default.CamoMaterials[4];
			Skins[1]=CamoWeapon.default.CamoMaterials[7];
		}
		else
		{
			Skins[0]=CamoWeapon.default.CamoMaterials[1];
			Skins[1]=CamoWeapon.default.CamoMaterials[5];
		}

	}
}

defaultproperties
{
     SlavePivot=(Pitch=0,Roll=32768)
     RelativeRotation=(Pitch=32768)
     CamoWeapon=Class'BWBP_SKC_Fix.T9CNMachinePistol'
     MuzzleFlashClass=Class'BallisticFix.XK2FlashEmitter'
     ImpactManager=Class'BallisticFix.IM_Bullet'
     BrassClass=Class'BallisticFix.Brass_GRSNine'
     InstantMode=MU_Both
     TracerClass=Class'BallisticFix.TraceEmitter_Pistol'
     TracerChance=0.600000
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     FlyByMode=MU_Primary
     Mesh=SkeletalMesh'BWBP_SKC_Anim.TP_M9'
     DrawScale=0.150000
     Skins[0]=Texture'BWBP_SKC_Tex.T9CN.Ber-Main'
     Skins[1]=Texture'BWBP_SKC_Tex.T9CN.Ber-Slide'
     Skins[2]=Texture'BWBP_SKC_Tex.T9CN.Ber-Mag'

}
