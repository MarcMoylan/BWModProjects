//=============================================================================
// FLAKGrenadeCluster.
//
// Very powerful cluster explosives spawned by FLAK grenade air detonations
//
// by The Lord Fluthulu
// Copyright(c) 2012 Sergeant Kelly. All Rights Reserved.
//=============================================================================
class FLAKGrenadeCluster extends BallisticGrenade;


defaultproperties
{
     bAlignToVelocity=True
     bDynamicLight=True
     bNoInitialSpin=False
     Damage=100.000000
     DamageRadius=512.000000
     DetonateDelay=0.500000
     DetonateOn=DT_Timed
     DrawScale=0.500000
     ImpactDamage=9
     ImpactDamageType=Class'BWBP_SKC_Fix.DT_LonghornShotDirect'
     ImpactManager=Class'BWBP_SKC_Fix.IM_FLAKGrenadeCluster'
     LifeSpan=20
     LightBrightness=32.000000
     LightEffect=LE_QuadraticNonIncidence
     LightHue=25
     LightRadius=4.000000
     LightSaturation=192
     LightType=LT_Steady
     MomentumTransfer=15000.000000
     MotionBlurFactor=3.000000
     MotionBlurRadius=384.000000
     MotionBlurTime=1.000000
     MyDamageType=Class'BWBP_SKC_Fix.DT_LonghornShotRadius'
     MyRadiusDamageType=Class'BWBP_SKC_Fix.DT_LonghornShotRadius'
     RotationRate=(Roll=32768)
     ShakeRadius=512.000000
     Speed=900.000000
     SplashManager=Class'BallisticFix.IM_ProjWater'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.Longhorn.ClusterProj'
     TrailClass=Class'BWBP_SKC_Fix.LonghornGrenadeTrail'
}
