//=============================================================================
//:GHORNWAttachment.
//
// 3rd person weapon attachment for Longhorn Carbine
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class LonghornAttachment extends BallisticAttachment;



defaultproperties
{
     MuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     AltMuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     ImpactManager=Class'BallisticFix.IM_Bullet'
     AltFlashBone="tip"
     BrassClass=Class'BWBP_SKC_Fix.Brass_Longhorn'
     InstantMode=MU_Both
     FlashMode=MU_Both
     LightMode=MU_Both
     TracerClass=Class'BallisticFix.TraceEmitter_Default'
     TracerMix=-3
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     bRapidFire=True
     bAltRapidFire=True
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.TP_Longhorn'
     DrawScale=0.300000
     RelativeRotation=(Pitch=32768)
}
