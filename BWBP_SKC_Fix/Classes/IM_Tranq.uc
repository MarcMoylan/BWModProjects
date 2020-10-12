//=============================================================================
// IM_Tranq.
//
// ImpactManager subclass for tranq darts
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class IM_Tranq extends BCImpactManager;

defaultproperties
{
     HitEffects(0)=Class'BallisticFix.IE_BulletConcrete'
     HitEffects(1)=Class'BallisticFix.IE_BulletConcrete'
     HitEffects(2)=Class'BallisticFix.IE_BulletDirt'
     HitEffects(3)=Class'BallisticFix.IE_BulletMetal'
     HitEffects(4)=Class'BallisticFix.IE_BulletWood'
     HitEffects(5)=Class'BallisticFix.IE_BulletGrass'
     HitEffects(6)=Class'XEffects.pclredsmoke'
     HitEffects(7)=Class'BallisticFix.IE_BulletIce'
     HitEffects(8)=Class'BallisticFix.IE_BulletSnow'
     HitEffects(9)=Class'BallisticFix.IE_BulletWater'
     HitEffects(10)=Class'BallisticFix.IE_BulletGlass'
     HitDecals(0)=Class'BallisticFix.AD_BulletConcrete'
     HitDecals(1)=Class'BallisticFix.AD_BulletConcrete'
     HitDecals(2)=Class'BallisticFix.AD_BulletDirt'
     HitDecals(3)=Class'BallisticFix.AD_BulletMetal'
     HitDecals(4)=Class'BallisticFix.AD_BulletWood'
     HitDecals(5)=Class'BallisticFix.AD_BulletConcrete'
     HitDecals(6)=Class'BallisticFix.AD_BulletConcrete'
     HitDecals(7)=Class'BallisticFix.AD_BulletIce'
     HitDecals(8)=Class'BallisticFix.AD_BulletDirt'
     HitDecals(10)=Class'BallisticFix.AD_BulletConcrete'
     HitSounds(0)=Sound'BWBP_SKC_SoundsExp.VSK.VSK-Impact'
     HitSounds(1)=Sound'BWBP_SKC_SoundsExp.VSK.VSK-Impact'
     HitSounds(2)=Sound'BWBP_SKC_SoundsExp.VSK.VSK-Impact'
     HitSounds(3)=Sound'BWBP_SKC_SoundsExp.VSK.VSK-Impact'
     HitSounds(4)=Sound'BWBP_SKC_SoundsExp.VSK.VSK-Impact'
     HitSounds(5)=Sound'BWBP_SKC_SoundsExp.VSK.VSK-Impact'
     HitSounds(6)=Sound'BWBP_SKC_SoundsExp.VSK.VSK-Impact'
     HitSounds(7)=Sound'BWBP_SKC_SoundsExp.VSK.VSK-Impact'
     HitSounds(8)=Sound'BWBP_SKC_SoundsExp.VSK.VSK-Impact'
     HitSounds(9)=SoundGroup'BallisticSounds2.BulletImpacts.BulletWater'
     HitSounds(10)=Sound'BWBP_SKC_SoundsExp.VSK.VSK-Impact'
     HitSoundVolume=0.700000
     HitSoundRadius=128.000000
     HitDelay=0.100000
}
