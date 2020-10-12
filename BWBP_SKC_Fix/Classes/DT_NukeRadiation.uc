//=============================================================================
// DT_NukeRadiation.
//
// Damage type for pretty much anyone who even looks at a nuke. Haha you're all
// gonna die!
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_NukeRadiation extends DT_BWFire;
var float	FlashF;
var vector	FlashV;

static function class<Effects> GetPawnDamageEffect( vector HitLocation, float Damage, vector Momentum, Pawn Victim, bool bLowDetail )
{
	if (PlayerController(Victim.Controller) != None)
		PlayerController(Victim.Controller).ClientFlash(default.FlashF, default.FlashV);
	return super.GetPawnDamageEffect(HitLocation, Damage, Momentum, Victim, bLowDetail);
}

defaultproperties
{
     FlashF=0.200000
     FlashV=(X=1500.000000,Y=1500.000000)
     DeathStrings(0)="%o perished in %k's radioactive contamination."
     DeathStrings(1)="%o got a new super power from %k's radiation! It's death!"
     DeathStrings(2)="%o missed the fireworks but stuck around to enjoy %k's nuclear winter."
     DeathStrings(3)="%o blissfully ignored %vh Geiger counter in %k's hotzone."
     bDetonatesBombs=False
     DamageDescription=",Gas,GearSafe,Hazard,"
     MinMotionBlurDamage=1.000000
     MotionBlurDamageRange=20.000000
     MotionBlurFactor=3.000000
     bUseMotionBlur=True
     WeaponClass=Class'BWBP_SKC_Fix.NukeLauncher'
     DeathString="%o perished in %k's radioactive contamination."
     FemaleSuicide="%o succumbed to radiation poisoning!"
     MaleSuicide="%o succumbed to radiation poisoning!"
     bInstantHit=True
     bCausesBlood=False
     bDelayedDamage=True
     bNeverSevers=True
     bArmorStops=False
     GibPerterbation=0.100000
     KDamageImpulse=200.000000
}
