//=============================================================================
// DTMRS138Tazer.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class DTShockGauntlet extends DT_BWMiscDamage;

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
     FlashF=-0.100000
     FlashV=(X=400.000000,Y=400.000000,Z=1000.000000)
     DeathStrings(0)="%k gave %o shock therapy with his fists of retribution."
     DeathStrings(1)="%k administered a healthy dose of ass-whuppin' to %o."
     DeathStrings(2)="%k prescribed a dose of electro-gauntlet fury for %o."
     DeathStrings(3)="%k operated %o's face off with %vh fists of vengeance."
     DeathStrings(4)="%k surgically removed %o's life with the Combat Defibrillator!"
     bCanBeBlocked=True
     ShieldDamage=15
     DamageDescription=",Blunt,Electro"
     ImpactManager=Class'BallisticFix.IM_MRS138TazerHit'
     WeaponClass=Class'BWBP_SKC_Fix.DefibFists'
     DeathString="%k administered a healthy dose of ass-whuppin' to %o."
     FemaleSuicide="%o zapped herself."
     MaleSuicide="%o zapped himself."
     bArmorStops=False
     bInstantHit=True
     bCauseConvulsions=True
     bNeverSevers=True
     PawnDamageSounds(0)=SoundGroup'BWAddPack-RS-Sounds.MRS38.RSS-ElectroFlesh'
     DamageOverlayMaterial=Shader'XGameShaders.PlayerShaders.LightningHit'
     DamageOverlayTime=0.900000
     GibPerterbation=0.250000
     VehicleDamageScaling=0.250000
     VehicleMomentumScaling=0.050000
}
