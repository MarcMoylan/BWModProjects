//=============================================================================
// SRACLightRocket.
//
// FRAG-12 explosive charge. Weakened for auto fire.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SRACLightRocket extends LS14Rocket;

defaultproperties
{
     ImpactManager=Class'BWBP_SKC_Fix.IM_BulldogFRAG'
     PenetrateManager=Class'BWBP_SKC_Fix.IM_HVPCProjectile'
     AccelSpeed=25000.000000
     TrailClass=Class'BallisticFix.MRLTrailEmitter'
     SplashManager=Class'BallisticFix.IM_ProjWater'
     MyRadiusDamageType=Class'BWBP_SKC_Fix.DTSRACFRAGRadius'
     MotionBlurRadius=50.000000
     bPenetrate=False
     bUsePositionalDamage=False
     bRandomStartRotaion=False
     Speed=150.000000
     MaxSpeed=50000.000000
     Damage=105.000000
     DamageRadius=130.000000
     MomentumTransfer=30000.000000
     MyDamageType=Class'BWBP_SKC_Fix.DTSRACFRAG'
     StaticMesh=StaticMesh'BWBP_SKC_Static.Bulldog.BulldogFRAG'
     bFixedRotationDir=True
     RotationRate=(Roll=12384)
}
