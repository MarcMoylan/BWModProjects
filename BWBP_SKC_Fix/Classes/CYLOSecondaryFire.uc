//=============================================================================
// CYLOSecondaryFire.
//
// A semi-auto shotgun that uses its own magazine.
//
// by Casey 'Xavious' Johnson and Marc 'Sergeant Kelly'
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class CYLOSecondaryFire extends BallisticShotgunFire;

// Wishlist (*) and To do list (+):
// + Check balance. This is probably pretty much the M763 Primary fire for numbers.
// + Get reloading to work.

var   bool		bLoaded;
var   bool		bWorking; //Layman's fix for reload tapping.
var   bool		bStillWorking; //Layman's fix for reload tapping. (Cocking)


simulated function bool CheckShotgun()
{
	local int channel;
	local name seq;
	local float frame, rate;
	if (!bLoaded)
	{
		log("Notify: Not loaded");
		weapon.GetAnimParams(channel, seq, frame, rate);
		if (seq == CYLOUAW(Weapon).ShotgunLoadAnim)
			return false;
		CYLOUAW(Weapon).LoadShotgun();
		bIsFiring=false;
		return false;
	}
	return true;
}
simulated function bool CheckCockState()
{
	local int channel;
	local name seq;
	local float frame, rate;

	if (CYLOUAW(Weapon).bSGNeedCock)
	{
		weapon.GetAnimParams(channel, seq, frame, rate);
		if (seq == CYLOUAW(Weapon).CockSGAnim)
			return false;
		CYLOUAW(Weapon).CockShotgun();
		bIsFiring=false;
		return false;
	}
	return true;
}

simulated function bool AllowFire()
{
//	if ((CYLOUAW(Weapon).SGShells == 0) || !super.AllowFire())
//		return false;
//	return true;
//	if (CYLOUAW(Weapon).bSGNeedCock)
//		return false;			// Is SG cocked
// I'm lazy so this unlocks the melee.
	CYLOUAW(Weapon).bMeleeing=false;
// Check if there is ammo in clip if we use weapon's mag or is there some in inventory if we don't

	if (!CheckReloading())
		return false;		// Is weapon busy reloading
	if (!CheckWeaponMode())
		return false;		// Will weapon mode allow further firing
	if (!bUseWeaponMag || BW.bNoMag)
	{
		if(!Super.AllowFire())
		{
			if (DryFireSound.Sound != None)
				Weapon.PlayOwnedSound(DryFireSound.Sound,DryFireSound.Slot,DryFireSound.Volume,DryFireSound.bNoOverride,DryFireSound.Radius,DryFireSound.Pitch,DryFireSound.bAtten);
			return false;	// Does not use ammo from weapon mag. Is there ammo in inventory
		}
	}
	else if (CYLOUAW(Weapon).SGShells < 1)
	{
		if (!bPlayedDryFire && DryFireSound.Sound != None)
		{
			Weapon.PlayOwnedSound(DryFireSound.Sound,DryFireSound.Slot,DryFireSound.Volume,DryFireSound.bNoOverride,DryFireSound.Radius,DryFireSound.Pitch,DryFireSound.bAtten);
			bPlayedDryFire=true;
		}
		if (bDryUncock)
			BW.bNeedCock=true;
		BW.bNeedReload = BW.MayNeedReload(ThisModeNum, 0);

		BW.EmptyFire(ThisModeNum);
		return false;		// Is there ammo in weapon's mag
	}
	else if (BW.bNeedReload)
		return false;
	else if (BW.bNeedCock)
		return false;		// Is gun cocked
//	else if (CYLOUAW(Weapon).bSGNeedCock)
//		return false;		// Is SG cocked
    return true;

}

simulated event ModeDoFire()
{
	if (CYLOUAW(Weapon).SGShells == 0)
	{
		CYLOUAW(Weapon).MainLoadShotgun();
		log("STOP 1");
		return;
	}
	if (!AllowFire())
	{
		log("STOP 2");
		return;
	}
	if (!CheckShotgun())
	{
		log("STOP 3");
		return;
	}
	if (!CheckCockState())
	{
		log("STOP 4");
		return;
	}
	Super.ModeDoFire();
    	CYLOUAW(Weapon).SGShells -= 1;
	if (CYLOUAW(Weapon).SGShells == 0)
        bLoaded = false;
}

defaultproperties
{
     bLoaded=True
     TraceCount=9
     TracerClass=Class'BallisticFix.TraceEmitter_Shotgun'
     ImpactManager=Class'BallisticFix.IM_Shell'
     TraceRange=(Min=1250.000000,Max=1700.000000)
     Damage=15
     DamageHead=20
     DamageLimb=7
     RangeAtten=0.300000
     DamageType=Class'BWBP_SKC_Fix.DTCYLOShotgun'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTCYLOShotgunHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTCYLOShotgun'
     KickForce=10000
     PenetrateForce=100
     bPenetrate=True
     bUseWeaponMag=False
     MuzzleFlashClass=Class'BallisticFix.MRT6FlashEmitter'
     FlashBone="Muzzle2"
     BrassClass=Class'BallisticFix.Brass_Shotgun'
     bBrassOnCock=True
     BrassOffset=(X=-30.000000,Y=-5.000000,Z=5.000000)
     RecoilPerShot=768.000000
     VelocityRecoil=200.000000
     XInaccuracy=1400.000000
     YInaccuracy=1100.000000
     FireSpreadMode=FSM_Circle
     JamSound=(Sound=Sound'BallisticSounds3.Misc.ClipEnd-1',Volume=0.900000)
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.CYLO.CYLO-FireSG',Volume=1.300000)
     bWaitForRelease=True
     bModeExclusive=False
     FireAnim="FireSG"
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.400000
	AmmoPerFire=0
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_CYLOSG'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
