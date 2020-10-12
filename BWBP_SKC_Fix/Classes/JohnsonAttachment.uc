//=============================================================================
// BulldogAttachment.
//
// 3rd person weapon attachment for the Suzuki XL7
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class JohnsonAttachment extends BallisticAttachment;


defaultproperties
{
     MuzzleFlashClass=Class'BWBP_SKC_Fix.AH104FlashEmitter'
     AltMuzzleFlashClass=Class'BWBP_SKC_Fix.AH104FlashEmitter'
     ImpactManager=Class'BWBP_SKC_Fix.IM_ExpBulletLarge'
     AltFlashBone="ejector"
     BrassClass=Class'BWBP_SKC_Fix.Brass_BOLT'
     FlashMode=MU_Both
     BrassMode=MU_Both
     TracerChance=2.000000
     TracerMix=1.000000
     TracerClass=Class'BWBP_SKC_Fix.TraceEmitter_Bulldog'
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     Mesh=SkeletalMesh'BWBP_SKC_Anim.3RD-Bulldog'
     RelativeLocation=(X=-2.000000,Y=0.000000,Z=0.000000)
     RelativeRotation=(Pitch=32768)
     DrawScale=0.300000
}
