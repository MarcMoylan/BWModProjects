//=============================================================================
// DTXM84GrenadeRadius.
//
// Damage type for the XM84 Grenade radius damage
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTXM84GrenadeRadius extends DT_BWExplode;

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
     DeathStrings(0)="%o's fragile brain was fried by %k's XM84."
     DeathStrings(1)="%k's XM84 hemorrhaged %o's fragile brain."
     DeathStrings(2)="%o succumbed to %k's XM84 psionic blast."
     WeaponClass=Class'BWBP_SKC_Fix.XM84Flashbang'
     DeathString="%o was fatally corrupted by %k's tech grenade."
     FemaleSuicide="%o had a tactical error with her tactical grenade."
     MaleSuicide="%o had a tactical error with his tactical grenade."
     bDelayedDamage=True
     VehicleDamageScaling=4.500000
     VehicleMomentumScaling=1.500000
     PawnDamageSounds(0)=Sound'BWBP_SKC_Sounds.Misc.XM84-StunEffect'
     DamageOverlayMaterial=Shader'XGameShaders.PlayerShaders.LightningHit'
     DamageOverlayTime=0.900000
}
