//=============================================================================
// FLASHPrimaryFire.
//
// A buring rocket that streaks through the air like a flaming man sans clothes
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class FLASHPrimaryFire extends BallisticProjectileFire;

var() class<Actor>	HatchSmokeClass;
var   Actor			HatchSmoke;
var() Sound			SteamSound;





defaultproperties
{
     SpawnOffset=(X=10.000000,Y=10.000000,Z=-3.000000)
     bCockAfterFire=False
     MuzzleFlashClass=Class'BallisticFix.G5FlashEmitter'
     RecoilPerShot=1024.000000
     XInaccuracy=400.000000
     YInaccuracy=400.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.FLASH.M202-Fire',Volume=1.200000,Slot=SLOT_Interact,bNoOverride=False)
     bSplashDamage=True
     bRecommendSplashDamage=True
     bCockAfterEmpty=False
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.700000
     AmmoClass=class'BWBP_SKC_Fix.Ammo_FLASH'
     ShakeRotMag=(X=128.000000,Y=64.000000,Z=16.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.500000
     ShakeOffsetMag=(X=-50.000000)
     ShakeOffsetRate=(X=-2000.000000)
     ShakeOffsetTime=5.000000
     ProjectileClass=Class'BWBP_SKC_Fix.FLASHProjectile'
     BotRefireRate=0.500000
     WarnTargetPct=0.300000
}
