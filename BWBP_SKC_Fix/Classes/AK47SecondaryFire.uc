//=============================================================================
// AK47SecondaryFire.
//
// Melee attack for the AK-490.
// Will do a bayonet stab if one is equipped.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class AK47SecondaryFire extends BallisticMeleeFire;

simulated function SwitchBladeMode (bool bLoaded)
{
	if (bLoaded == true)
	{
			BallisticFireSound.Sound=Sound'BallisticSounds3.A73.A73Stab';
     			DamageType=Class'BWBP_SKC_Fix.DT_AK47Slash';
     			DamageTypeHead=Class'BWBP_SKC_Fix.DT_AK47SlashHead';
     			DamageTypeArm=Class'BWBP_SKC_Fix.DT_AK47Slash';
     			PreFireAnim='PrepPokies';
     			FireAnim='Pokies';
     			FireAnimRate=0.900000;
     			Damage=85;
			DamageLimb=45;
	}
	else if (bLoaded == false)
	{
		     	BallisticFireSound.Sound=default.BallisticFireSound.sound;
     			DamageType=Class'BWBP_SKC_Fix.DT_AK47Hit';
     			DamageTypeHead=Class'BWBP_SKC_Fix.DT_AK47HitHead';
     			DamageTypeArm=Class'BWBP_SKC_Fix.DT_AK47Hit';
     			PreFireAnim='PrepBash';
     			FireAnim='Bash';
     			FireAnimRate=default.FireAnimRate;
     			Damage=default.Damage;
			DamageLimb=default.DamageLimb;
	}
	else
	{
		     	BallisticFireSound.Sound=default.BallisticFireSound.sound;
     			DamageType=Class'BWBP_SKC_Fix.DT_AK47Hit';
     			DamageTypeHead=Class'BWBP_SKC_Fix.DT_AK47HitHead';
     			DamageTypeArm=Class'BWBP_SKC_Fix.DT_AK47Hit';
     			PreFireAnim='PrepBash';
     			FireAnim='Bash';
     			FireAnimRate=default.FireAnimRate;
     			Damage=default.Damage;
			DamageLimb=default.DamageLimb;
	}
	if (Weapon.bBerserk)
		FireRate *= 0.75;
	if ( Level.GRI.WeaponBerserk > 1.0 )
	    FireRate /= Level.GRI.WeaponBerserk;

}


// Check if there is ammo in clip if we use weapon's mag or is there some in inventory if we don't
simulated function bool AllowFire()
{
	if (!CheckReloading())
		return false;		// Is weapon busy reloading
	if (!CheckWeaponMode())
		return false;		// Will weapon mode allow further firing
	if (bUseWeaponMag || BW.bNoMag)
	{
		if(!Super(WeaponFire).AllowFire())
		{
			if (DryFireSound.Sound != None)
				Weapon.PlayOwnedSound(DryFireSound.Sound,DryFireSound.Slot,DryFireSound.Volume,DryFireSound.bNoOverride,DryFireSound.Radius,DryFireSound.Pitch,DryFireSound.bAtten);
			return false;	// Does not use ammo from weapon mag. Is there ammo in inventory
		}
	}
    return true;
}


simulated function bool HasAmmo()
{
	return true;
}


simulated event ModeHoldFire()
{
	super.ModeHoldFire();
	BW.GunLength=1;
}
//Check Sounds and damage types.

defaultproperties
{
     SwipePoints(0)=(Weight=6,offset=(Pitch=6000,Yaw=4000))
     SwipePoints(1)=(Weight=5,offset=(Pitch=4500,Yaw=3000))
     SwipePoints(2)=(Weight=4,offset=(Pitch=3000))
     SwipePoints(3)=(Weight=3,offset=(Pitch=1500,Yaw=1000))
     SwipePoints(4)=(Weight=2,offset=(Pitch=0,Yaw=0))
     SwipePoints(5)=(Weight=1,offset=(Pitch=-1500,Yaw=-1500))
     SwipePoints(6)=(offset=(Yaw=-3000))
     WallHitPoint=4
     Damage=75
     DamageHead=115
     DamageLimb=35
     DamageType=Class'BWBP_SKC_Fix.DT_AK47Hit'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_AK47HitHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_AK47Hit'
     KickForce=2000
//     bUseWeaponMag=False
     bUseWeaponMag=True
     bReleaseFireOnDie=False
     bIgnoreReload=True
     ScopeDownOn=SDO_PreFire
     BallisticFireSound=(Sound=Sound'BWBP4-Sounds.Marlin.Mar-Melee',Radius=32.000000,bAtten=True)
     bAISilent=True
     bFireOnRelease=True
     PreFireAnim="PrepBash"
     FireAnim="Bash"
     PreFireAnimRate=2.000000
     FireAnimRate=1.100000
     TweenTime=0.000000
     FireRate=0.900000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_X8Knife'
     AmmoPerFire=0
     ShakeRotTime=1.000000
     ShakeOffsetMag=(X=5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=1.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.050000
}
