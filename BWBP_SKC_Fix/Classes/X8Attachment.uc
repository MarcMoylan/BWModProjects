//=============================================================================
// X8Attachment.
//
// 3rd person weapon attachment for the X8 Knife
//
// by Logan "BlackEagle" Richert.
// uses code by Nolan "Dark Carnivour" Richert.
// Copyright© 2011 RuneStorm. All Rights Reserved.
//=============================================================================
class X8Attachment extends BallisticAttachment;

defaultproperties
{
     ImpactManager=Class'BallisticFix.IM_Knife'
     BrassMode=MU_None
     InstantMode=MU_Both
     FlashMode=MU_None
     LightMode=MU_None
     TrackAnimMode=MU_Primary
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     bRapidFire=True
     RelativeRotation=(Pitch=32768)
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.TP_BalKnife'
     DrawScale=0.500000
}
