//=============================================================================
// NukePrimaryFire.
//
// Fires a giant freaking nuclear rocket. Needs to be authorized first.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class NukePrimaryFire extends BallisticProjectileFire;

var() class<Actor>	HatchSmokeClass;
var   Actor			HatchSmoke;
var() Sound			SteamSound;
var   float RailPower;

var() float 	ChargeRate;
var   float ChargeTime;
var() Sound	ChargeSound;
var() Sound		ReadySound;		//
var bool	bIsCharging;
var bool	bHalfPower;
var bool	bFullPower;
var bool	bARMED;

simulated event ModeDoFire()
{
    if (!AllowFire())
	  return;

    if (bARMED)
    {
        	super.ModeDoFire();
		bARMED=false;
		NukeLauncher(Weapon).UnAuth();
		NukeLauncher(Weapon).WeaponModes[1].ModeName="Authorizing...";
    }
    else
    {
	if (!bIsCharging)
		NukeLauncher(Weapon).BeginAuth();
	  bIsCharging=True;
    }

}


simulated function ModeTick(float DT)
{
	Super.ModeTick(DT);
        if (bIsCharging)
        {

//            	Instigator.AmbientSound = ChargeSound;
            	RailPower = FMin(RailPower + ChargeRate*DT, 1);
        }
        else
        {
//            Instigator.AmbientSound = BW.UsedAmbientSound;
        }
   
	if (RailPower + 0.05 >= 0.5 && !bHalfPower)
	{
		NukeLauncher(Weapon).HalfAuth();
		bHalfPower=True;
	}


    if (RailPower + 0.05 >= 1)
    {
//		NukeLauncher(Weapon).FinishAuth();
//        	ModeDoFire();
		NukeLauncher(Weapon).PlaySound(ReadySound, SLOT_Misc, 2.5, ,512);
//		NukeLauncher(Weapon).WeaponModes[0].bUnavailable=true;
//		NukeLauncher(Weapon).WeaponModes[1].bUnavailable=true;
//		NukeLauncher(Weapon).WeaponModes[2].bUnavailable=false;
//		NukeLauncher(Weapon).CurrentWeaponMode=2;
		NukeLauncher(Weapon).WeaponModes[1].ModeName="Nuke ARMED";
		bARMED=true;
		bHalfPower=False;
		bFullPower=False;
		bIsCharging=False;
	  	RailPower=0;
    }

    if (!bIsFiring)
        return;

}

defaultproperties
{
     bARMED=False
     bHalfPower=False
     bIsCharging=False
     ChargeRate=0.078000
     ChargeTime=5.000000
     ChargeSound=Sound'BWBP_SKC_Sounds.Misc.LAW-NukeAlarm'
     ReadySound=Sound'BWBP_SKC_SoundsExp.Nuke.Nuke-Authorized'
     SpawnOffset=(X=10.000000,Y=10.000000,Z=-3.000000)
     bCockAfterFire=True
     MuzzleFlashClass=Class'BallisticFix.G5FlashEmitter'
     RecoilPerShot=1024.000000
     XInaccuracy=5.000000
     YInaccuracy=5.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.Misc.LAW-NukeShot',Volume=8.200000,Slot=SLOT_Interact,bNoOverride=False)
     bSplashDamage=True
     bRecommendSplashDamage=True
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.050000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_SMAT'
     ShakeRotMag=(X=128.000000,Y=64.000000,Z=16.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.500000
     ShakeOffsetMag=(X=-50.000000)
     ShakeOffsetRate=(X=-2000.000000)
     ShakeOffsetTime=5.000000
     ProjectileClass=Class'BWBP_SKC_Fix.NukeRocket'
     BotRefireRate=0.500000
     WarnTargetPct=0.300000
}
