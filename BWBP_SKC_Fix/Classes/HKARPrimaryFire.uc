//=============================================================================
// MJ51PrimaryFire.
//
// 3-Round burst. Shots are powerful and easy to follow up.
// Not very accurate at range, and hindered by burst fire up close.
// Excels at mid range combat.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class HKARPrimaryFire extends BallisticInstantFire;

var int ShotsFired;         // Number of shots fired in this burst thus far
var() bool bRapidMode;        // Weapon fires bursts
var() float BurstDelay;

// ModeDoFire from WeaponFire.uc, but with a few changes
simulated event ModeDoFire()
{
	if (!AllowFire())
		return;
	if (bIsJammed)
	{
		if (BW.FireCount == 0)
		{
			bIsJammed=false;
			if (bJamWastesAmmo && Weapon.Role == ROLE_Authority)
			{
				ConsumedLoad += Load;
				Timer();
			}
			if (UnjamMethod == UJM_FireNextRound)
			{
				NextFireTime += FireRate;
				NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
				BW.FireCount++;
				return;
			}
			if (!AllowFire())
				return;
     		}
		else
		{
			NextFireTime += FireRate;
			NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
			return;
		}
	}

	if (BW != None)
	{
		BW.bPreventReload=true;
		BW.FireCount++;

		if (BW.ReloadState != RS_None)
		{
			if (weapon.Role == ROLE_Authority)
			BW.bServerReloading=false;
			BW.ReloadState = RS_None;
		}
	}

	if (MaxHoldTime > 0.0)
		HoldTime = FMin(HoldTime, MaxHoldTime);

	ConsumedLoad += Load;
	SetTimer(FMin(0.1, FireRate/2), false);
	// server
	if (Weapon.Role == ROLE_Authority)
	{
		DoFireEffect();
 		if ( (Instigator == None) || (Instigator.Controller == None) )
			return;
		if ( AIController(Instigator.Controller) != None )
			AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);
 		Instigator.DeactivateSpawnProtection();
	}
	else if (!BW.bScopeView && !BW.bUseNetAim)
		FireRecoil();
 
	BW.LastFireTime = Level.TimeSeconds;


	// client
	if (Instigator.IsLocallyControlled())
	{
		ShakeView();
		PlayFiring();
        	FlashMuzzleFlash();
        	StartMuzzleSmoke();
	}
	else // server
	{
        	ServerPlayFiring();
	}

	// set the next firing time. must be careful here so client and server do not get out of sync
	if (bFireOnRelease)
	{
        	if (bIsFiring)
			NextFireTime += MaxHoldTime + FireRate;
        	else
            		NextFireTime = Level.TimeSeconds + FireRate;
    	}
    	else if (bRapidMode)
    	{
     		if (ShotsFired > 4)
     		{
      			NextFireTime += BurstDelay;
      			NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
      			Weapon.StopFire(ThisModeNum);
      			ShotsFired = 0;
     		}
     		else
     		{
      			NextFireTime += FireRate;
     			NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
    		}
    	}
    	else
    	{
        	NextFireTime += FireRate;
        	NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
    	}

    	Load = AmmoPerFire;
    	HoldTime = 0;

    	if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
    	{
        	bIsFiring = false;
        	Weapon.PutDown();
    	}

 	if (BW != None)
 	{
  		BW.bNeedReload = BW.MayNeedReload(ThisModeNum, ConsumedLoad);
  		if (bCockAfterFire || (bCockAfterEmpty && BW.MagAmmo - ConsumedLoad < 1))
   			BW.bNeedCock=true;
	}
}

function StopFiring()
{
	Super.StopFiring();
	if (bRapidMode)
	{
		ShotsFired = 0;
		NextFireTime = Level.TimeSeconds + BurstDelay;
	}
}




simulated function SwitchCannonMode (byte NewMode)
{
	if (NewMode == 2)
	{
//		FireRate = 0.082500;
		FireRate = 0.092500;
     		RecoilPerShot=128.000000;
     		HKARCarbine(Weapon).RecoilYFactor = 0.2;
     		HKARCarbine(Weapon).RecoilXFactor = 0.2;
     		HKARCarbine(Weapon).RecoilPitchFactor = 1.6;
     		HKARCarbine(Weapon).RecoilYawFactor = 1.0;
		HKARCarbine(Weapon).RecoilDeclineTime = 2.0;
		HKARCarbine(Weapon).CrouchAimFactor = 0.6;
		HKARCarbine(Weapon).RecoilYCurve.Points[1].OutVal = 0.4;
	}
	else
	{
		FireRate = default.FireRate;
		RecoilPerShot = default.RecoilPerShot;
     		HKARCarbine(Weapon).RecoilXFactor	= HKARCarbine(Weapon).default.RecoilXFactor;
     		HKARCarbine(Weapon).RecoilYFactor	= HKARCarbine(Weapon).default.RecoilYFactor;
     		HKARCarbine(Weapon).RecoilPitchFactor = HKARCarbine(Weapon).default.RecoilPitchFactor;
		HKARCarbine(Weapon).RecoilDeclineTime = HKARCarbine(Weapon).default.RecoilDeclineTime;
		HKARCarbine(Weapon).CrouchAimFactor = HKARCarbine(Weapon).default.CrouchAimFactor;
		HKARCarbine(Weapon).RecoilYCurve.Points[1].OutVal = 0.1;
		FireRate=0.066600;
	}
	if (Weapon.bBerserk)
		FireRate *= 0.50;
	if ( Level.GRI.WeaponBerserk > 1.0 )
	    FireRate /= Level.GRI.WeaponBerserk;

	Load=AmmoPerFire;
}


defaultproperties
{
     TraceRange=(Min=12000.000000,Max=14000.000000)
     WaterRangeFactor=0.800000
     MaxWallSize=32.000000
     MaxWalls=2
     Damage=24
     DamageHead=75
     DamageLimb=15
     WaterRangeAtten=0.700000
//     RangeAtten=0.900000
     DamageType=Class'BWBP_SKC_Fix.DTMJ51Assault'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTMJ51AssaultHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTMJ51AssaultLimb'
     KickForce=18000
     PenetrateForce=150
     bPenetrate=True
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bCockAfterEmpty=False
     MuzzleFlashClass=Class'BWBP_SKC_Fix.MJ51FlashEmitter'
     FlashScaleFactor=1.000000
     BrassClass=Class'BallisticFix.Brass_Rifle'
     BrassBone="ejector"
     BrassOffset=(X=-20.000000,Y=1.000000)
     RecoilPerShot=96.000000
     XInaccuracy=2.000000
     YInaccuracy=2.000000
//     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ55-Fire',Volume=1.300000)
 BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.SKAR.SKAR-Fire3',Volume=1.500000)
     bPawnRapidFireAnim=True
     FireEndAnim=
     TweenTime=0.000000
//     FireRate=0.082500
//     FireRate=0.075000
//     FireRate=0.070000
     FireRate=0.066000
     BurstDelay=0.15
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_556mmSTANAG'
     ShakeRotMag=(X=64.000000,Y=32.000000)
     ShakeRotRate=(X=5000.000000,Y=5000.000000,Z=5000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-10.000000)
     ShakeOffsetRate=(X=-500.000000)
     ShakeOffsetTime=1.000000
     WarnTargetPct=0.200000
     aimerror=900.000000
}
