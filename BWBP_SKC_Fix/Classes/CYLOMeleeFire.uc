//=============================================================================
// CYLOMeleeFire.
//
// Bayonette melee attack for the CYLO. In place in hopes that if dual wielding
// can be figured out, this will be swapped for with the shotgun if dual wielded.
// Um... would like to make this alternate swings like the Fifty9 alt fire when
// dual wieled as well.
//
// by Casey 'Xavious' Johnson and Marc 'Sergeant Kelly'
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class CYLOMeleeFire extends BallisticInstantFire;

// Wishlist (*) and To do list (+):
// * Have this swap out with shotgun when dual wielded
// * Have this alternate with left CYLO like the FIfty9 when used in tandem
// * Chainsaw bayonet
// * More melee animations. I would really like to have something like a three
//   > hit combo going on, stab, smash with butt, wide bayo swing. Dunno when
//   > this will happen though. Also would rather a whole combo system be applied,
//   > with a quick bayo stab still in place for special fire and the more
//   > complex fighting reserved to a new firemode.
// + Check values. These were mostly ripped from the A73 bayo. Dunno anything
//   > about balance.

simulated event ModeDoFire()
{
	super.ModeDoFire();
	BW.GunLength = BW.default.GunLength;
}
simulated event ModeHoldFire()
{
	super.ModeHoldFire();
	BW.GunLength=1;
}

defaultproperties
{
     TraceRange=(Min=110.000000,Max=110.000000)
     Damage=65
     DamageHead=100
     DamageLimb=30
     DamageType=Class'BWBP_SKC_Fix.DTCYLOStab'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTCYLOStabHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTCYLOStabLimb'
     KickForce=100
     HookStopFactor=1.700000
     HookPullForce=100.000000
     bUseRunningDamage=True
     RunningSpeedThresh=1000.000000
     bUseWeaponMag=False
     bReleaseFireOnDie=False
     bIgnoreReload=True
     BallisticFireSound=(Sound=Sound'BallisticSounds3.A73.A73Stab',Radius=32.000000,bAtten=True)
     bAISilent=True
     PreFireAnim="PrepMelee"
     FireAnim="Melee"
     TweenTime=0.000000
     FireRate=0.300000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_CYLO'
     AmmoPerFire=0
     ShakeRotTime=1.000000
     ShakeOffsetMag=(X=5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=1.000000
     BotRefireRate=0.700000
     WarnTargetPct=0.050000
}
