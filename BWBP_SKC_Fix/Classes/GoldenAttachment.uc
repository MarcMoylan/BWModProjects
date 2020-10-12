//=============================================================================
// GoldenAttachment.
//
// 3rd person weapon attachment for the golden gun.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class GoldenAttachment extends BallisticAttachment;

defaultproperties
{
     MuzzleFlashClass=Class'BallisticFix.D49FlashEmitter'
     ImpactManager=Class'BWBP_SKC_Fix.IM_ExpBullet'
     FlashScale=0.350000
     BrassClass=Class'BallisticFix.Brass_Pistol'
     TracerClass=Class'BallisticFix.TraceEmitter_Pistol'
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     Mesh=SkeletalMesh'BWBP_SKC_Anim.DesertEagle_3rd'
     RelativeLocation=(X=0.000000,Z=6.000000)
     DrawScale=0.540000
     Skins(0)=Shader'BWBP_SKC_Tex.GoldEagle.GoldEagle-Shine'
}
