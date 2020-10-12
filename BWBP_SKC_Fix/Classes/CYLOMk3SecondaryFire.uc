//=============================================================================
// CYLOSecondaryFire.
//
// A semi-auto shotgun that uses its own magazine.
//
// by Casey 'Xavious' Johnson and Marc 'Sergeant Kelly'
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class CYLOMk3SecondaryFire extends BallisticShotgunFire;

simulated function bool AllowFire()
{
	if (!CheckReloading())
		return false;		// Is weapon busy reloading
	if (!CheckWeaponMode())
		return false;		// Will weapon mode allow further firing
	if (CYLOMk3MachineGun(Weapon).SGShells < 1)
	{
		if (!bPlayedDryFire && DryFireSound.Sound != None)
		{
			Weapon.PlayOwnedSound(DryFireSound.Sound,DryFireSound.Slot,DryFireSound.Volume,DryFireSound.bNoOverride,DryFireSound.Radius,DryFireSound.Pitch,DryFireSound.bAtten);
			bPlayedDryFire=true;
		}
		if (bDryUncock)
			CYLOMk3MachineGun(BW).bAltNeedCock=true;
		BW.bNeedReload = BW.MayNeedReload(ThisModeNum, 0);
		BW.EmptyFire(ThisModeNum);
		return false;		// Is there ammo in weapon's mag
	}
	else if (CYLOMk3MachineGun(BW).bAltNeedCock)
		return false;
    return true;
}
simulated event ModeDoFire()
{
	if (!AllowFire())
		return;
	Super.ModeDoFire();
    CYLOMk3MachineGun(Weapon).SGShells--;
	if (Weapon.Role == ROLE_Authority && CYLOMk3MachineGun(Weapon).SGShells == 0)
		CYLOMk3MachineGun(BW).bAltNeedCock = true;
}

defaultproperties
{
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
     XInaccuracy=350.000000
     YInaccuracy=350.000000
     FireSpreadMode=FSM_Circle
     JamSound=(Sound=Sound'BallisticSounds3.Misc.ClipEnd-1',Volume=0.900000)
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.CYLO.CYLO-FireSG',Volume=1.300000)
     bWaitForRelease=True
     bModeExclusive=False
     FireAnim="FireSG"
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.700000
	AmmoPerFire=0
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_CYLOSG'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.700000
     WarnTargetPct=0.500000
}
