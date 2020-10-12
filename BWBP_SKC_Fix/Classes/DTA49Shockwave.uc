//=============================================================================
// DTA49Shockwave.
//
// Damage type for the A49 alt fire
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTA49Shockwave extends DT_BWShell;
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
     FlashF=0.300000
     FlashV=(X=800.000000,Y=800.000000,Z=2000.000000)
     DeathStrings(0)="%k sent a shockwave through %o with %kh A49."
     DeathStrings(1)="%o was blown away by %k's A49 shockwave."
     DeathStrings(2)="%o went flying from %k's A49."
     DeathStrings(3)="%k ruptured %o's insides with an A49 shockwave."
     DeathStrings(4)="%o was pulsed by %k"
     WeaponClass=Class'BWBP_SKC_Fix.A49SkrithBlaster'
     DeathString="%k sent a shockwave through %o with %kh A49."
     FemaleSuicide="%o shockwaved her face off."
     MaleSuicide="%o shockwaved his face off."
     GibPerterbation=0.400000
     MinMotionBlurDamage=1.000000
     MotionBlurDamageRange=19.000000
     MotionBlurFactor=1.000000
     bUseMotionBlur=True
     KDamageImpulse=15000.000000
     VehicleDamageScaling=0.800000
     VehicleMomentumScaling=0.600000
}
