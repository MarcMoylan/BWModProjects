//=============================================================================
// DTXM84Held.
//
// Damage type for unreleased XM84
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTXM84Held extends DT_BWExplode;

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
     FlashF=-0.600000
     FlashV=(X=2500.000000,Y=2500.000000,Z=2500.000000)
     bArmorStops=False
     bCauseConvulsions=True
     bNeverSevers=True
     MinMotionBlurDamage=1.000000
     MotionBlurDamageRange=20.000000
     MotionBlurFactor=9.000000
     bUseMotionBlur=True
     DeathStrings(0)="%k blew off %kh hand and parts of %o."
     DeathStrings(1)="%o joined %k in %kh tactical suicide."
     DeathStrings(2)="%k decided to share his XM84 with %o."
     FemaleSuicides(0)="%o didn't realize her XM84 was on."
     FemaleSuicides(1)="%o threw the pin and not the grenade."
     MaleSuicides(0)="%o didn't realize his XM84 was on."
     MaleSuicides(1)="%o threw the pin and not the grenade."
     WeaponClass=Class'BWBP_SKC_Fix.XM84Flashbang'
     DeathString="%k blew off %kh hand and parts of %o."
     FemaleSuicide="%o held her XM84 to the bitter end."
     MaleSuicide="%o refused to drop his XM84."
     GibModifier=0.500000
     GibPerterbation=0.900000
     VehicleDamageScaling=2.500000
     VehicleMomentumScaling=1.000000
}
