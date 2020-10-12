//=============================================================================
// R78Attachment.
//
// 3rd person weapon attachment for R78 Sniper Rifle
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class R78NSAttachment extends BallisticCamoAttachment;

defaultproperties
{
     CamoWeapon=Class'BWBP_SKC_Fix.R78NSRifle'
     MuzzleFlashClass=Class'BallisticFix.R78FlashEmitter'
     ImpactManager=Class'BallisticFix.IM_BigBullet'
     BrassClass=Class'BallisticFix.Brass_Rifle'
     TracerClass=Class'BallisticFix.TraceEmitter_Default'
     TracerChance=0.600000
     WaterTracerClass=Class'BallisticFix.TraceEmitter_WaterBullet'
     WaterTracerMode=MU_Both
     FlyBySound=(Sound=SoundGroup'BallisticSounds2.FlyBys.Bullet-Whizz',Volume=0.700000)
     Mesh=SkeletalMesh'BallisticAnims2.Rifle-3rd'
     DrawScale=0.200000
     Skins(1)=Texture'ONSstructureTextures.CoreGroup.Invisible'
}
