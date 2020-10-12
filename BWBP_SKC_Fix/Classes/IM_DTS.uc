//=============================================================================
// IM_DTS.
//
// ImpactManager subclass for nanosword
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class IM_DTS extends BCImpactManager;

defaultproperties
{
     HitEffects(0)=Class'BallisticFix.IE_KnifeConcrete'
     HitEffects(1)=Class'BallisticFix.IE_KnifeConcrete'
     HitEffects(2)=Class'BallisticFix.IE_BulletDirt'
     HitEffects(3)=Class'BallisticFix.IE_KnifeMetal'
     HitEffects(4)=Class'BallisticFix.IE_BulletWood'
     HitEffects(5)=Class'BallisticFix.IE_BulletGrass'
     HitEffects(6)=Class'BallisticFix.IE_BulletDirt'
     HitEffects(7)=Class'BallisticFix.IE_BulletIce'
     HitEffects(8)=Class'BallisticFix.IE_BulletIce'
     HitEffects(9)=Class'BallisticFix.IE_ProjWater'
     HitEffects(10)=Class'BallisticFix.IE_BulletGlass'
     HitDecals(0)=Class'BallisticFix.AD_Knife'
     HitDecals(1)=Class'BallisticFix.AD_Knife'
     HitDecals(2)=Class'BallisticFix.AD_Knife'
     HitDecals(3)=Class'BallisticFix.AD_Knife'
     HitDecals(4)=Class'BallisticFix.AD_KnifeWood'
     HitDecals(5)=Class'BallisticFix.AD_KnifeWood'
     HitDecals(6)=Class'BallisticFix.AD_Knife'
     HitDecals(7)=Class'BallisticFix.AD_Knife'
     HitDecals(8)=Class'BallisticFix.AD_Knife'
     HitDecals(10)=Class'BallisticFix.AD_Knife'
     HitSounds(0)=Sound'BWBP_SKC_Sounds.DTS.NanoSwordHitHard'
     HitSounds(1)=Sound'BWBP_SKC_Sounds.DTS.NanoSwordHitHard'
     HitSounds(2)=Sound'BWBP_SKC_Sounds.DTS.NanoSwordHitSoft'
     HitSounds(3)=Sound'BWBP_SKC_Sounds.DTS.NanoSwordHitHard'
     HitSounds(4)=Sound'BWBP_SKC_Sounds.DTS.NanoSwordHitSoft'
     HitSounds(5)=Sound'BWBP_SKC_Sounds.DTS.NanoSwordHitSoft'
     HitSounds(6)=Sound'BWBP_SKC_Sounds.DTS.NanoSwordHitHard'
     HitSounds(7)=Sound'BWBP_SKC_Sounds.DTS.NanoSwordHitHard'
     HitSounds(8)=Sound'BWBP_SKC_Sounds.DTS.NanoSwordHitSoft'
     HitSounds(9)=SoundGroup'BallisticSounds2.NRP57.NRP57-Water'
     HitSounds(10)=Sound'BWBP_SKC_Sounds.DTS.NanoSwordHitHard'
     HitSoundVolume=3.700000
     HitSoundRadius=128.000000
     HitDelay=0.300000
}
