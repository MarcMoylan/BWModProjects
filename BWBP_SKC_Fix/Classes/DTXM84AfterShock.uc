//=============================================================================
// DTMRS138Tazer.
//?/ a/sf/ a/s/ Headache grenades!
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class DTXM84AfterShock extends DT_BWMiscDamage;

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
     FlashF=-0.250000
     FlashV=(X=1600.000000,Y=1600.000000,Z=4000.000000)
     DeathStrings(0)="%o's brain was reduced to goo by %k's XM84."
     DeathStrings(1)="%k's XM84 slowly liquidized %o's fragile brain."
     DeathStrings(2)="%o painfully succumbed to %k's XM84 aftershock."
     bDetonatesBombs=False
     DamageDescription=",Gas,GearSafe,Hazard,"
     MinMotionBlurDamage=1.000000
     MotionBlurDamageRange=20.000000
     MotionBlurFactor=3.000000
     bUseMotionBlur=True
     WeaponClass=Class'BWBP_SKC_Fix.XM84Flashbang'
     DeathString="%o's brain was reduced to goo by %k's XM84."
     FemaleSuicide="%o succumbed to her own tech grenade."
     MaleSuicide="%o succumbed to his own tech grenade."
     bInstantHit=True
     bCausesBlood=False
     bDelayedDamage=True
     bNeverSevers=True
     bArmorStops=False
     DamageOverlayMaterial=Shader'XGameShaders.PlayerShaders.LightningHit'
//     PawnDamageSounds(0)=Sound'BWBP_SKC_Sounds.Misc.XM84-Aftershock'
     DamageOverlayTime=0.900000
     GibPerterbation=0.001000
     KDamageImpulse=90000.000000
     VehicleDamageScaling=10.000000
     VehicleMomentumScaling=0.001000
}
