//=============================================================================
// DTGRSXXLaserHead.
//
// DT for GRSXX laser headshots. Adds red blinding effect and motion blur
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTGRSXXLaserHead extends DT_BWMiscDamage;

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
     FlashV=(X=2000.000000,Y=700.000000,Z=700.000000)
     DeathStrings(0)="%o got brain surgery done by %k's GRSXX beam."
     DeathStrings(1)="%o was permanently blinded by %k's GRSXX laser."
     DeathStrings(2)="%k made an incision in %o's neck with a GRSXX laser."
     BloodManagerName="BallisticFix.BloodMan_GRS9Laser"
     bIgniteFires=True
     MinMotionBlurDamage=20.000000
     MotionBlurDamageRange=40.000000
     MotionBlurFactor=5.000000
     bUseMotionBlur=True
     DamageDescription=",Laser,"
     WeaponClass=Class'BWBP_SKC_Fix.GRSXXPistol'
     DeathString="%o had laser brain surgery done by %k's GRSXX."
     FemaleSuicide="%o gave herself eye surgery with a GRSXX laser."
     MaleSuicide="%o gave himself eye surgery with a GRSXX laser."
     bInstantHit=True
     GibModifier=3.000000
     GibPerterbation=0.200000
     KDamageImpulse=1000.000000
}
