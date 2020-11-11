//=============================================================================
// SRACRocket.
//
// FRAG-12 explosive charge
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SRACRocket extends LS14Rocket;


defaultproperties
{
     ImpactManager=Class'BWBP_SKC_Fix.IM_BulldogFRAG'
     AccelSpeed=50000.000000
     TrailClass=Class'BWBP_SKC_Fix.TraceEmitter_Incendiary'
     MyRadiusDamageType=Class'BWBP_SKC_Fix.DTSRACFRAGRadius'
     MotionBlurRadius=130.000000
     Speed=200.000000
     MaxSpeed=100000.000000
     Damage=110.000000
     DamageRadius=180.000000
     MomentumTransfer=30000.000000
     MyDamageType=Class'BWBP_SKC_Fix.DTSRACFRAG'
     StaticMesh=StaticMesh'BWBP_SKC_Static.Bulldog.BulldogFRAG'
     Skins(0)=Texture'BWBP_SKC_Tex.SMAA.SMAARocket'
}
