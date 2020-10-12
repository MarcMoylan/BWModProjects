//=============================================================================
// DTFistsHead.
//
// Damagetype for Fists to the head, it momentarily blinds people when hit
// upside the head.
// Armour doesn't stop it either, to make the fists have some sort of use.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTBrawlingHead extends DTBrawling;

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
     FlashF=-0.350000
     FlashV=(X=500.000000,Y=500.000000,Z=500.000000)
     DeathStrings(0)="%o got KOed by %k."
     DeathStrings(1)="%o's face got rearranged by %k's fist."
     DeathStrings(2)="%k beat %o's face to a bloody pulp."
     DeathStrings(3)="%k tweaked %o's face."
     DeathStrings(4)="%k punched %o's nose into %vh brain."
     DeathStrings(5)="%k's fists did a number on %o's head."
     ShieldDamage=5
     DeathString="%o got KOed by %k."
     bArmorStops=False
     bSpecial=True
     GibPerterbation=0.250000
}
