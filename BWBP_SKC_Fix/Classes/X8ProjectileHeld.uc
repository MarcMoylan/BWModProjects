//=============================================================================
// X8Projectile.
//
// A launched X8 Knife
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class X8ProjectileHeld extends X8Projectile;


defaultproperties
{
     ImpactManager=Class'BallisticFix.IM_KnifeThrown'
     bRandomStartRotaion=False
     bUsePositionalDamage=True
     Damage=80
     DamageHead=110
     DamageLimb=60
     DamageTypeHead=Class'BWBP_SKC_Fix.DTX8KnifeLaunchedHead'
     bWarnEnemy=False
     Speed=5000.000000
     MyDamageType=Class'BWBP_SKC_Fix.DTX8KnifeLaunched'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.X8.X8Proj'
     bNetTemporary=False
//     Physics=PHYS_Falling
     LifeSpan=0.000000
     DrawScale=0.150000
     bUnlit=False
}
