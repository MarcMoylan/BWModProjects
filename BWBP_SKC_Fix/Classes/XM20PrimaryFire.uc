//=============================================================================
// XM20PrimaryFire.
//
// Automatic laser fire. Low recoil, easy to control. Pew pew.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class XM20PrimaryFire extends BallisticInstantFire;

simulated function bool AllowFire()
{
    if (super.AllowFire())
	{ 
		if (XM20Carbine(BW).bIsCharging)
			return false;
		else
			return true;
	}
    return super.AllowFire();
}

defaultproperties
{
     TraceRange=(Min=5000.000000,Max=7500.000000)
     WaterRangeFactor=0.900000
     Damage=20
     DamageHead=35
     DamageLimb=15
     RangeAtten=0.900000
     WaterRangeAtten=0.700000
     DamageType=Class'BWBP_SKC_Fix.DT_XM20Body'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_XM20Head'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_XM20Body'
     KickForce=27500
     PenetrateForce=600
     bPenetrate=False
     FlashScaleFactor=0.300000
     MuzzleFlashClass=Class'BWBP_SKC_Fix.A48FlashEmitter'
     RecoilPerShot=32.000000
     XInaccuracy=16.000000
     YInaccuracy=16.000000
     BallisticFireSound=(Sound=SoundGroup'BWBP_SKC_Sounds.XM20.XM20-PulseFire',Volume=1.200000,Slot=SLOT_Interact,bNoOverride=False)
     FireEndAnim=None
     TweenTime=0.000000
     FireRate=0.150000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_Laser'
     ShakeRotMag=(X=200.000000,Y=8.000000)
     ShakeRotRate=(X=5000.000000,Y=5000.000000,Z=5000.000000)
     ShakeRotTime=0.500000
     ShakeOffsetMag=(X=-3.000000)
     ShakeOffsetRate=(X=-500.000000)
     ShakeOffsetTime=1.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
     aimerror=800.000000
}
