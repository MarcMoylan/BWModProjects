//=============================================================================
// CYLOPrimaryFire.
//
// For some really odd reason my UDE isn't liking the class names, so I have to
// change the names for UDE to recognize them every once in a while...
//
// by Casey 'Xavious' Johnson and Marc 'Sergeant Kelly'
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class CYLOPriFire extends BallisticInstantFire;

// Wishlist (*) and To do list (+):
// * Make Semi-Auto fire more than one bullet at times.
// * Make full auto mode fire off a few after letting go of fire every now and
//   > then. Maybe.
// * Maybe some slam fires here and there? Maybe.
// * Change jam sound. This is supposed to represent a bullet not making it out
//   > the barrel and getting lodged in there. Seems to not be unheard of with
//   > caseless ammo (according to Sgt. Smash) and the 'recomended' fix? Fire
//   > the gun again.
// + Check values. These were mostly ripped from the SRS900 due to it using
//   > similarly sized rounds. Dunno anything about balance.

var() sound		RifleFireSound;
var() sound		MeleeFireSound;
var   float		StopFireTime;
//var   bool      bFullAutoOn;    // Ugly little thing to easily determine if its on Semi-Auto or not.

/*simulated function SwitchWeaponMode (byte NewMode)
{
	if (NewMode == 1)
	   bFullAutoOn=False;
    else
        bFullAutoOn=True;
}*/


simulated function bool AllowFire()
{
	if (level.TimeSeconds - StopFireTime < 0.3 && CYLOUAW(Weapon).bMeleeing == true || !super.AllowFire())
	{
		return false;
	}
	return true;
}

function StopFiring()
{
	StopFireTime = level.TimeSeconds;
}

simulated event ModeDoFire()
{
//	local float f;
		if (level.Netmode == NM_Standalone)
		{
			FireRate = default.FireRate + (FRand() * 0.15);
		}
		else
		{
			FireRate = 0.12;
		}
	Super.ModeDoFire();
	
    // Experimental code to make the primary fire randomly fire off more than
    // one shot in Semi-Auto mode, which was turned to really be Burst Fire mode
    // in hopes that I could make this work like I wanted...
    // Evidentally, burst fire still considers holding the button in after the
    // burst value is met as still firing, which explains this interesting
    // phenomena. I guess.
/*	f = FRand();
	if ((f > 0.950) && (bFullAutoOn==False) && (BW.WeaponModes[1].Value==1))
	{
        BW.WeaponModes[1].Value = 1+Rand(5);
        FireRate = 0.025500 + (FRand() * 0.05);
        JamChance=0.000000;
    }
    else
    {
        BW.WeaponModes[1].Value = 1;
        FireRate = default.FireRate + (FRand() * 0.15);
        JamChance= default.JamChance;
    }   */
}

defaultproperties
{
     RifleFireSound=Sound'BWBP_SKC_Sounds.CYLO.CYLO-Fire'
     MeleeFireSound=Sound'BallisticSounds3.A73.A73Stab'
     TraceRange=(Min=8000.000000,Max=12000.000000)
     WaterRangeFactor=0.800000
     MaxWallSize=32.000000
     MaxWalls=2
     Damage=35
     DamageHead=82
     DamageLimb=20
     RangeAtten=0.650000
     WaterRangeAtten=0.800000
     DamageType=Class'BWBP_SKC_Fix.DTCYLORifle'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTCYLORifleHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTCYLORifle'
     KickForce=20000
     PenetrateForce=180
     bPenetrate=True
     RunningSpeedThresh=1000.000000
     ClipFinishSound=(Sound=Sound'BallisticSounds3.Misc.ClipEnd-1',Volume=0.800000,Radius=48.000000,bAtten=True)
     DryFireSound=(Sound=Sound'BallisticSounds3.Misc.DryRifle',Volume=0.700000)
     bCockAfterEmpty=True
     MuzzleFlashClass=Class'BallisticFix.XK2FlashEmitter'
     FlashBone="Muzzle"
     FlashScaleFactor=0.500000
     RecoilPerShot=130.000000
     FireChaos=0.010000
     XInaccuracy=96.000000
     YInaccuracy=96.000000
     UnjamMethod=UJM_Fire
     JamChance=0.008000
     WaterJamChance=0.850000
     JamSound=(Sound=Sound'BallisticSounds3.Misc.DryRifle',Volume=0.900000)
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.CYLO.CYLO-Fire',Volume=1.600000,Slot=SLOT_Interact,bNoOverride=False)
     bPawnRapidFireAnim=True
     PreFireAnim=
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.085500
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_CYLO'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     WarnTargetPct=0.200000
     aimerror=900.000000
}
