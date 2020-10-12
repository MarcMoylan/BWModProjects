//=============================================================================
// A909PrimaryFire.
//
// Rapid, two handed jabs with reasonable range. Everything is timed by notifys
// from the anims
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DoomFistsPrimaryFire extends BallisticMeleeFire;

simulated function bool HasAmmo()
{
	return true;
}

function StartBerserk()
{
    	FireRate = 0.4;
		Damage = 135;
		DamageHead = 275;
		DamageLimb = 70;
	      DamageType=Class'BWBP_SKC_Fix.DTBERSERK';
    	      DamageTypeHead=Class'BWBP_SKC_Fix.DTBERSERK';
    		DamageTypeArm=Class'BWBP_SKC_Fix.DTBERSERK';
    		FireAnimRate = 2;
}

function StopBerserk()
{
      FireRate = default.FireRate;
		Damage = default.damage;
		DamageHead = default.damagehead;
		DamageLimb = default.damagelimb;
     DamageType=Class'BWBP_SKC_Fix.DTBrawling';
     DamageTypeHead=Class'BWBP_SKC_Fix.DTBrawlingHead';
     DamageTypeArm=Class'BWBP_SKC_Fix.DTBrawlingLimb';
    FireAnimRate = default.FireAnimRate;
}

defaultproperties
{
     SwipePoints(0)=(offset=(Pitch=0))
     SwipePoints(1)=(offset=(Pitch=0))
     SwipePoints(2)=(offset=(Pitch=0))
     SwipePoints(4)=(offset=(Pitch=0))
     SwipePoints(5)=(offset=(Pitch=0))
     SwipePoints(6)=(offset=(Pitch=0))
     TraceRange=(Min=80.000000,Max=80.000000)
     Damage=20
     DamageHead=60
     DamageLimb=10
     DamageType=Class'BWBP_SKC_Fix.DTBrawling'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTBrawlingHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTBrawlingLimb'
     KickForce=30000
     BallisticFireSound=(Sound=Sound'BallisticSounds3.M763.M763Swing',Radius=32.000000,bAtten=True)
     bAISilent=True
     FireAnim="Punch"
     FireAnimRate=1.300000
     FireRate=0.550000
     AmmoClass=Class'BallisticFix.Ammo_Knife'
     AmmoPerFire=0
     ShakeRotMag=(X=64.000000,Y=384.000000)
     ShakeRotRate=(X=3500.000000,Y=3500.000000,Z=3500.000000)
     ShakeRotTime=2.000000
     BotRefireRate=0.800000
     WarnTargetPct=0.050000
}
