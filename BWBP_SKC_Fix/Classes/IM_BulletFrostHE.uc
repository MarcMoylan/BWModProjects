//=============================================================================
// IM_BulletFrostHE.
// 
// ImpactManager subclass for explosive ice bullets
// 
// by Sarge
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class IM_BulletFrostHE extends BCImpactManager;

defaultproperties
{
     HitEffects(0)=Class'BWBP_SKC_Fix.IE_BulletFrostHE'
     HitDecals(0)=Class'BallisticFix.AD_BulletIce'
     HitSounds(0)=Sound'BWBP_SKC_SoundsExp.SX45.SX45-FrostImpact'
}
