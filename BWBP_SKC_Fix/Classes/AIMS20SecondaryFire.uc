//=============================================================================
// M50SecondaryFire.
//
// A grenade that bonces off walls and detonates a certain time after impact
// Good for scaring enemies out of dark corners and not much else
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AIMS20SecondaryFire extends BallisticProjectileFire;



defaultproperties
{
     SpawnOffset=(X=15.000000,Y=10.000000,Z=-9.000000)
     bUseWeaponMag=False
     MuzzleFlashClass=Class'BallisticFix.M50M900FlashEmitter'
     FlashBone="tip2"
     RecoilPerShot=16.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.Misc.AIMS-Fire2',Volume=2.100000)
     bSplashDamage=True
     bRecommendSplashDamage=True
     bModeExclusive=True
     FireForce="AssaultRifleAltFire"
     FireRate=0.20000
     FlashScaleFactor=2.600000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_LS14Rocket'
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'BWBP_SKC_Fix.AIMS20Rocket'
     BotRefireRate=0.300000
     WarnTargetPct=0.300000
     SpreadStyle=SS_Random
}
