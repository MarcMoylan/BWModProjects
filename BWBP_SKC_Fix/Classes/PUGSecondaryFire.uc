//=============================================================================
// PUGSecondaryFire.
//
// A nightmare of notifies and conditional code.
// Absolutely massive 20mm tear gas shell. Great for accidentally killing rioters
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class PUGSecondaryFire extends BallisticProjectileFire;

var   bool		bLoaded; //Do we even have grenades?
var   bool		bIsCharging; //Are we charging?
var   float RailPower;
var   float ChargeRate;
var   float PowerLevel;
var   float MaxCharge;

var       float		HUDRefreshTime;		// Used to keep the damn thing pretty


simulated function bool AllowFire()
{
	if (!super.AllowFire())
		return false;
	if (PUGAssaultCannon(Weapon).Grenades < 1)
	{
		if (!bPlayedDryFire && DryFireSound.Sound != None)
		{
			Weapon.PlayOwnedSound(DryFireSound.Sound,DryFireSound.Slot,DryFireSound.Volume,DryFireSound.bNoOverride,DryFireSound.Radius,DryFireSound.Pitch,DryFireSound.bAtten);
			bPlayedDryFire=true;
		}
		BW.bNeedReload = BW.MayNeedReload(ThisModeNum, 0);

		PUGAssaultCannon(Weapon).EmptyAltFire(1);
		return false;		// Is there ammo in weapon's mag
	}
	return true;
}

simulated event ModeDoFire()
{

	if (!AllowFire())
		return;

	if (level.Netmode == NM_Standalone) //Replication hates this bit here
	{
		if (!PUGAssaultCannon(Weapon).bReady)
		{
			PUGAssaultCannon(Weapon).PrepAltFire();
			return;
		}
    		else
    		{
			super.ModeDoFire();
    			PUGAssaultCannon(Weapon).Grenades -= 1;
			PUGAssaultCannon(Weapon).bReady = false;
			PUGAssaultCannon(Weapon).PrepPriFire();
    		}
	}
	else //Online users cock after fire, NOT before
	{
        	super.ModeDoFire();
    		PUGAssaultCannon(Weapon).Grenades -= 1;
	}

}


defaultproperties
{
     ChargeRate=0.700000
     PowerLevel=1.000000
     bLoaded=True
     SpawnOffset=(X=15.000000,Y=10.000000,Z=-9.000000)
     bUseWeaponMag=False
     MuzzleFlashClass=Class'BallisticFix.M50M900FlashEmitter'
     FlashBone="tip"
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.PUG.PUG-FireSlug',Volume=7.500000)
     bSplashDamage=True
     bRecommendSplashDamage=True
     bTossed=True
     RecoilPerShot=1048.000000
     VelocityRecoil=100.000000
//     bFireOnRelease=True
//     bWaitForRelease=True
     bModeExclusive=False
//     PreFireAnim="SGPrep"
     BrassClass=Class'BWBP_SKC_Fix.Brass_FRAGSpent'
     BrassBone="ejector"
     BrassOffset=(X=-30.000000,Y=1.000000)
     FireAnim="SGFire"
     FireForce="AssaultRifleAltFire"
     FireRate=0.500000
	AmmoPerFire=0
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_20mmGrenade'
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'BWBP_SKC_Fix.PUGRocket'
     BotRefireRate=0.300000
     WarnTargetPct=0.300000
}
