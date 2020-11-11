//=============================================================================
// T10PrimaryFire.
//
// T10 Grenade thrown overhand
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class X8SecondaryFire extends BallisticProjectileFire;

defaultproperties
{
     bAISilent=True
     bWaitForRelease=True
     bReleaseFireOnDie=True
     bFireOnRelease=True
     FireRate=1.700000
     SpawnOffset=(X=15.000000,Y=10.000000,Z=-9.000000)
     FlashBone="tip"
     MuzzleFlashClass=Class'BWBP_SKC_Fix.VSKSilencedFlash'
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.AK47.AK47-KnifeFire',Radius=32.000000,bAtten=True)
     PreFireAnim="PrepShoot"
     FireAnim="Shoot"
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_X8Knife'
     ShakeRotMag=(X=32.000000,Y=8.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=1.500000
     ShakeOffsetMag=(X=-3.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=1.500000
     ProjectileClass=Class'BWBP_SKC_Fix.X8ProjectileHeld'
}
