//=============================================================================
// M781Attachment.
//
// 3rd person weapon attachment for M781 Shotgun
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SRACAttachment extends BallisticCamoAttachment;

defaultproperties
{
     CamoWeapon=Class'BWBP_SKC_Fix.SRACGrenadeLauncher'
     MuzzleFlashClass=Class'BallisticFix.MRT6FlashEmitter'
     FlashScale=1.800000
     BrassMode=MU_Primary
     InstantMode=MU_None
     FlashMode=MU_Primary
     LightMode=MU_Primary
     BrassClass=Class'BWBP_SKC_Fix.Brass_FRAGSpent'
     Mesh=SkeletalMesh'BWBP_SKC_Anim.3RD-SKAS'
     DrawScale=0.130000
     RelativeLocation=(X=-2.000000,Z=7.000000)
     RelativeRotation=(Pitch=32768)
     Skins(0)=Texture'BWBP_SKC_Tex.SKAS.SKASShotgun'
     Skins(1)=Texture'BWBP_SKC_Tex.SKAS.SKASShotgun'
}
