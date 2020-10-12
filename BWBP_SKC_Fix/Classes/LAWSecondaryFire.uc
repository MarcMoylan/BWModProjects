//=============================================================================
// LAWSecondaryFire.
//
// An unignited missile that will do area damage over time.
// Will deonate after 5 shockwaves.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class LAWSecondaryFire extends BallisticProjectileFire;


defaultproperties
{
     SpawnOffset=(X=15.000000,Y=10.000000,Z=-9.000000)
     bUseWeaponMag=True
     MuzzleFlashClass=Class'BallisticFix.M50M900FlashEmitter'
     RecoilPerShot=3096.000000
     XInaccuracy=256.000000
     YInaccuracy=256.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.LAW.LAW-Fire',Volume=4.200000,Slot=SLOT_Interact,bNoOverride=False)
     bSplashDamage=True
     bRecommendSplashDamage=True
     bTossed=True
     FireAnim="Fire"
     FireForce="AssaultRifleAltFire"
     FireRate=0.600000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_LAW'
     bModeExclusive=True
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'BWBP_SKC_Fix.LAWGrenade'
     BotRefireRate=0.300000
     WarnTargetPct=0.300000
}
