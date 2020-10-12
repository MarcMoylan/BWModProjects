//=============================================================================
// M30A2PrimaryFire.
//
// Very automatic, bullet style instant hit. Shots are long ranged, powerful
// and accurate when used carefully. The dissadvantages are severely screwed up
// accuracy after firing a shot or two and the rapid rate of fire means ammo
// dissapeares quick.
//
// Burst code by Az
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class M30A2PrimaryFire extends BallisticInstantFire;

// Burst Mode -----------------------------------------------------------------
var int ShotsFired;         // Number of shots fired in this burst thus far
var bool bRapidMode;        // Weapon fires bursts


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
    	else if (bRapidMode && M30A2AssaultRifle(BW).CamoIndex != 1)
    	{
     		if (ShotsFired > 3)
     		{
      			NextFireTime += 0.5;
      			NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
      			Weapon.StopFire(ThisModeNum);
      			ShotsFired = 0;
     		}
     		else
     		{
      			NextFireTime += 0.06;
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
		NextFireTime = Level.TimeSeconds + 0.5;
	}
}



simulated function SwitchCannonMode (byte NewMode)
{
	if (NewMode == 3)
	{
		FireRate = 0.15;
     		M30A2AssaultRifle(Weapon).RecoilXFactor	= 0.8;
     		M30A2AssaultRifle(Weapon).RecoilYFactor	= 0.6;
	}
	else if (NewMode == 2)
	{
		FireRate = 0.3;
     		M30A2AssaultRifle(Weapon).RecoilXFactor	= 0.3;
     		M30A2AssaultRifle(Weapon).RecoilYFactor	= 0.2;
	}
	else if (NewMode == 1)
	{
		if (M30A2AssaultRifle(Weapon).CamoIndex == 1)
			FireRate = 0.15;
		else
			FireRate = 0.06;
     		M30A2AssaultRifle(Weapon).RecoilXFactor	= 0.2;
     		M30A2AssaultRifle(Weapon).RecoilYFactor	= 0.1;
	}
	else if (NewMode == 0)
	{
//		FireRate = 0.1;
		FireRate = 0.06;
     		M30A2AssaultRifle(Weapon).RecoilXFactor	= 0.3;
     		M30A2AssaultRifle(Weapon).RecoilYFactor	= 0.2;
	}
	else
	{
		FireRate = default.FireRate;
     		M30A2AssaultRifle(Weapon).RecoilXFactor	= 0.3;
     		M30A2AssaultRifle(Weapon).RecoilYFactor	= 0.2;
	}
	if (Weapon.bBerserk)
		FireRate *= 0.50;
	if ( Level.GRI.WeaponBerserk > 1.0 )
	    FireRate /= Level.GRI.WeaponBerserk;

	Load=AmmoPerFire;
}


defaultproperties
{
     TraceRange=(Min=12000.000000,Max=15000.000000)
     WaterRangeFactor=0.800000
     MaxWallSize=48.000000
     MaxWalls=3
     Damage=35
     DamageHead=95
     DamageLimb=20
     WaterRangeAtten=0.800000
     DamageType=Class'BWBP_SKC_Fix.DTM30A1Assault'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTM30A1AssaultHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTM30A1AssaultLimb'
     KickForce=20000
     PenetrateForce=150
     bPenetrate=True
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bCockAfterEmpty=True
     MuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     FlashScaleFactor=0.800000
     BrassClass=Class'BallisticFix.Brass_Rifle'
     BrassBone="tip"
     BrassOffset=(X=-80.000000,Y=1.000000)
//     RecoilPerShot=192.000000
     RecoilPerShot=350.000000
     XInaccuracy=1.500000
     YInaccuracy=1.600000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.M50A2.M32A2-Fire',Volume=1.100000,Slot=SLOT_Interact,bNoOverride=False)
     bPawnRapidFireAnim=True
     FireEndAnim=
     TweenTime=0.000000
//     FireRate=0.060000
//     FireRate=0.100000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_42HVG'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=2.000000
     WarnTargetPct=0.200000
     aimerror=900.000000
}
