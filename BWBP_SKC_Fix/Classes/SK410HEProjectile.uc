//=============================================================================
// SK410HEProjectile.
//
// An explosive slug
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SK410HEProjectile extends BallisticGrenade;


defaultproperties
{
     DetonateOn=DT_Impact
     bNoInitialSpin=True
     bAlignToVelocity=True
     DetonateDelay=1.000000
     ImpactDamage=65
     ImpactDamageType=Class'BWBP_SKC_Fix.DT_SK410Slug'
     ImpactManager=Class'BWBP_SKC_Fix.IM_SlugHE'
     TrailClass=Class'BWBP_SKC_Fix.SK410FireTrail'
     TrailOffset=(X=-8.000000)
     MyRadiusDamageType=Class'BWBP_SKC_Fix.DT_SK410SlugRadius'
     SplashManager=Class'BallisticFix.IM_ProjWater'
     ShakeRadius=512.000000
     MotionBlurRadius=128.000000
     Speed=6300.000000
     Damage=50.000000
     DamageRadius=200.000000
     MomentumTransfer=10000.000000
     MyDamageType=Class'BWBP_SKC_Fix.DT_SK410Slug'
     StaticMesh=StaticMesh'BWBP_SKC_Static.Bulldog.Frag12Proj'
     DrawScale=2.000000
     LifeSpan=16.000000
     LightHue=180
     LightSaturation=100
     LightBrightness=160.000000
     LightRadius=8.000000
}
