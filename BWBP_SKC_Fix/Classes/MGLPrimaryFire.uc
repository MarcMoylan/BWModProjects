//=============================================================================
// M50SecondaryFire.
//
// A grenade that bonces off walls and detonates a certain time after impact
// Good for scaring enemies out of dark corners and not much else
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class MGLPrimaryFire extends BallisticProjectileFire;
var() sound		ExtraFireSound;


simulated function SwitchCannonMode (byte NewMode)
{
	if (NewMode == 1)
	{
		BallisticFireSound.Sound=ExtraFireSound;
		ProjectileClass=Class'MGLGrenade';
		FireRate=0.700000;
	}
	else if (NewMode == 0)
	{
		BallisticFireSound.Sound=default.BallisticFireSound.Sound;
		ProjectileClass=Class'MGLGrenadeTimed';
		FireRate=default.FireRate;
	}
	else
	{
		BallisticFireSound.Sound=default.BallisticFireSound.Sound;
		ProjectileClass=Class'MGLGrenadeTimed';
		FireRate=default.FireRate;
	}
	if (Weapon.bBerserk)
		FireRate *= 0.50;
	if ( Level.GRI.WeaponBerserk > 1.0 )
	    FireRate /= Level.GRI.WeaponBerserk;

	Load=AmmoPerFire;
}

defaultproperties
{
     SpawnOffset=(X=15.000000,Y=10.000000,Z=-9.000000)
     ExtraFireSound=Sound'BWBP_SKC_SoundsExp.MGL.MGL-FireAlt'
     MuzzleFlashClass=Class'BallisticFix.M50M900FlashEmitter'
     FlashBone="tip"
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.MGL.MGL-Fire',Volume=9.200000)
     bSplashDamage=True
     bRecommendSplashDamage=True
     bTossed=True
     bModeExclusive=False
     FireForce="AssaultRifleAltFire"
     FireRate=0.500000
     AmmoClass=Class'BallisticFix.Ammo_12Gauge'
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'BWBP_SKC_Fix.MGLGrenadeTimed'
     BotRefireRate=0.300000
     WarnTargetPct=0.300000
}
