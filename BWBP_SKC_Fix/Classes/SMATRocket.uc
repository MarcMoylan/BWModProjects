//=============================================================================
// SMATRocket.
//
// Super Fast Rocket for SMAT.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SMATRocket extends G5Rocket;

defaultproperties
{
     ImpactManager=Class'BWBP_SKC_Fix.IM_SMAT'
     AccelSpeed=100000.000000
     TrailClass=Class'BWBP_SKC_Fix.SMATRocketTrail'
     MyRadiusDamageType=Class'BWBP_SKC_Fix.DTSMATRadius'
     MotionBlurRadius=1536.000000
     Speed=200.000000
     MaxSpeed=1000000.000000
     Damage=600.000000
     DamageRadius=160.000000
     MomentumTransfer=400000.000000
     MyDamageType=Class'BWBP_SKC_Fix.DTSMAT'
     Skins(0)=Texture'BWBP_SKC_Tex.SMAA.SMAARocket'
}
