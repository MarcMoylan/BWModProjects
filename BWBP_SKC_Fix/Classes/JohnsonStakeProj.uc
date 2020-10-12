//=============================================================================
// JohnsonStakeProj.
//
// Rapid spike that deals impact damage and causes bleed.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class JohnsonStakeProj extends BallisticProjectile;


simulated event Landed( vector HitNormal )
{
	HitWall( HitNormal, Level );
}

defaultproperties
{
     ImpactManager=Class'BallisticFix.IM_XMK5Dart'
     TrailClass=Class'BallisticFix.PineappleTrail'
     bRandomStartRotaion=False
     AccelSpeed=1000.000000
     TrailOffset=(X=-4.000000)
     MyRadiusDamageType=Class'BWBP_SKC_Fix.DT_LS14RocketRadius'
     SplashManager=Class'BallisticFix.IM_ProjWater'
     Speed=10000.000000
     MaxSpeed=10000.000000
     Damage=85.000000
     DamageRadius=192.000000
     MomentumTransfer=20000.000000
     MyDamageType=Class'BWBP_SKC_Fix.DT_LS14Rocket'
     StaticMesh=StaticMesh'BWBP4-Hardware.MRL.MRLRocket'
     AmbientSound=Sound'BWBP4-Sounds.MRL.MRL-RocketFly'
     SoundVolume=64
     Physics=PHYS_Falling
     bFixedRotationDir=True
     RotationRate=(Roll=32768)
}
