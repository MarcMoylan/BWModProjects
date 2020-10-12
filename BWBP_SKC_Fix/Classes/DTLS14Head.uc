//=============================================================================
// DTLS14Head.
//
// DT for LS14 headshots. Adds blue blinding effect and motion blur.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTLS14Head extends DT_BWMiscDamage;

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
     FlashV=(X=700.000000,Y=700.000000,Z=2000.000000)
     DeathStrings(0)="%o was lasered right between the eyes by %k's carbine."
     DeathStrings(1)="%k's LS-14 decapitated %o and cauterized the stump."
     DeathStrings(2)="%k accurately melted %o's retinas with a blue LS-14 laser."
     DeathStrings(3)="%o's teeth were precisely disintegrated by %k's LS-14."
     BloodManagerName="BWBP_SKC_Fix.BloodMan_HMCLaser"
     ShieldDamage=5
     bIgniteFires=True
     MinMotionBlurDamage=5.000000
     MotionBlurDamageRange=20.000000
     bUseMotionBlur=True
     DamageDescription=",Laser,"
     WeaponClass=Class'BWBP_SKC_Fix.LS14Carbine'
     DeathString="%o was lasered right between the eyes by %k's carbine."
     FemaleSuicide="%o blasted her eyes out."
     MaleSuicide="%o blasted himself in the eye."
     bInstantHit=True
     bAlwaysSevers=True
     GibModifier=2.000000
     GibPerterbation=0.200000
     KDamageImpulse=1000.000000
}
