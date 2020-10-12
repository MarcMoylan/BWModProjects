//=============================================================================
// A42Attachment.
//
// 3rd person weapon attachment for A42 Skrith Pistol
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class A49Attachment extends HandgunAttachment;

defaultproperties
{
     SlaveOffset=(X=14.000000,Y=-7.000000,Z=-7.000000)
     SlavePivot=(Pitch=0,Roll=32768)
     MuzzleFlashClass=Class'BallisticFix.A42FlashEmitter'
     AltMuzzleFlashClass=Class'BallisticFix.A42FlashEmitter'
     ImpactManager=Class'BWBP_SKC_Fix.IM_GRSXXLaser'
     BrassMode=MU_None
     TracerMode=MU_Secondary
     InstantMode=MU_Secondary
     FlashMode=MU_Both
     LightMode=MU_Both
     bRapidFire=True
     Mesh=SkeletalMesh'BWBP_SKC_Anim.3RD-A49'
     DrawScale=0.250000
     RelativeRotation=(Pitch=32768)
     RelativeLocation=(X=-5.000000,Y=-3.000000,Z=10.000000)
}
