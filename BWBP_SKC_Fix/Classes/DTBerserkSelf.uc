//=============================================================================
// DTBerserk.
//
// Damagetype for BERSERK FISTS OF PUNCHING. AAAAAAAAAAH.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTBerserkSelf extends DT_BWBlunt;

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
     DeathStrings(0)="%k ripped %o to shreds!"
     DeathStrings(1)="%k pulverized %o in a berserk rage!"
     DeathStrings(2)="%k crushed %o to a bloody mess!"
     DeathStrings(3)="%o's spine was ripped out by %k."
     MinMotionBlurDamage=20.000000
     MotionBlurDamageRange=40.000000
     MotionBlurFactor=5.000000
     bUseMotionBlur=True
     WeaponClass=Class'BWBP_SKC_Fix.DoomFists'
     DeathString="%k ripped %o to shreds!"
     FemaleSuicide="%o EXPLODED IN ANGER."
     MaleSuicide="%o EXPLODED IN ANGER."
     bAlwaysGibs=True
     bLocationalHit=False
     bAlwaysSevers=True
     PawnDamageSounds(0)=Sound'BWBP_SKC_Sounds.Berserk.Berserk-Squish'
     GibPerterbation=4.000000
     KDamageImpulse=1000.000000
     VehicleDamageScaling=0.100000
     VehicleMomentumScaling=1.300000
}
