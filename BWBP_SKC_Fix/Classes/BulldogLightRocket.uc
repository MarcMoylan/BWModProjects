//=============================================================================
// BulldogLightRocket.
//
// FRAG-12 explosive charge. Weakened for online play
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class BulldogLightRocket extends G5Rocket;

delegate OnDie(Actor Cam);

simulated function Explode(vector HitLocation, vector HitNormal)
{
	OnDie(self);
	Super.Explode(HitLocation, HitNormal);
}

defaultproperties
{
     ImpactManager=Class'BWBP_SKC_Fix.IM_BulldogFRAG'
     AccelSpeed=25000.000000
     TrailClass=Class'BallisticFix.MRLTrailEmitter'
     MyRadiusDamageType=Class'BWBP_SKC_Fix.DTBulldogFRAGRadius'
     MotionBlurRadius=50.000000
     Speed=150.000000
     MaxSpeed=50000.000000
     Damage=105.000000
     DamageRadius=170.000000
     MomentumTransfer=30000.000000
     MyDamageType=Class'BWBP_SKC_Fix.DTBulldogFRAG'
     StaticMesh=StaticMesh'BWBP_SKC_Static.Bulldog.BulldogFRAG'
     Skins(0)=Texture'BWBP_SKC_Tex.SMAA.SMAARocket'
}
