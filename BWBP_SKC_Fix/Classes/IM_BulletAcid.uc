//=============================================================================
// IM_BulletAcid.
//
// ImpactManager subclass for acid bullets
//
// by Sarge
// Copyright© 2011 RuneStorm. All Rights Reserved.
//=============================================================================
class IM_BulletAcid extends BCImpactManager;

defaultproperties
{
     HitEffects(0)=Class'BallisticFix.IE_A500BlastImpact'
     HitDecals(0)=Class'BWBP_SKC_Fix.AD_BulletAcid'
     HitSounds(0)=Sound'BallisticSounds_25.Reptile.Rep_Impact01'
     HitSounds(1)=Sound'BallisticSounds_25.Reptile.Rep_PlayerImpact'
     HitSoundVolume=0.750000
}
