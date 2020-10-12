//=============================================================================
// IM_Bullet.
//
// ImpactManager subclass for ordinary bullets
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class IM_ExpBullet extends IM_Bullet;

defaultproperties
{
     HitEffects(0)=Class'BWBP_SKC_Fix.IE_BulletExpConcrete'
     HitEffects(1)=Class'BWBP_SKC_Fix.IE_BulletExpConcrete'
     HitEffects(2)=Class'BWBP_SKC_Fix.IE_BulletExpDirt'
     HitEffects(3)=Class'BWBP_SKC_Fix.IE_BulletExpMetal'
     HitEffects(4)=Class'BWBP_SKC_Fix.IE_BulletExpWood'
     HitEffects(5)=Class'BWBP_SKC_Fix.IE_BulletExpGrass'
     HitEffects(7)=Class'BWBP_SKC_Fix.IE_BulletExpIce'
     HitEffects(8)=Class'BWBP_SKC_Fix.IE_BulletExpSnow'
     HitDecals(0)=Class'BallisticFix.AD_BigBulletConcrete'
     HitDecals(1)=Class'BallisticFix.AD_BigBulletConcrete'
     HitDecals(3)=Class'BallisticFix.AD_BigBulletMetal'
     HitDecals(4)=Class'BallisticFix.AD_BigBulletWood'
     HitDecals(5)=Class'BallisticFix.AD_BigBulletConcrete'
     HitDecals(6)=Class'BallisticFix.AD_BigBulletConcrete'
     HitDecals(7)=Class'BallisticFix.AD_BigBulletConcrete'
     HitDecals(10)=Class'BallisticFix.AD_BigBulletConcrete'
     HitSoundVolume=0.900000
     HitSoundRadius=124.000000
}
