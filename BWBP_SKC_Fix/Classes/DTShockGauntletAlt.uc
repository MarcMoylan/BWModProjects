//=============================================================================
// DTMRS138Tazer.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class DTShockGauntletAlt extends DT_BWMiscDamage;

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
     DeathStrings(0)="%k's meaty uppercut knocked %o the hell out."
     DeathStrings(1)="%k's thunderous strike drove %o's jaw into his skull."
     DeathStrings(2)="%k fed %o RAW, CHUNKY VOLTS to the FACE."
     DeathStrings(3)="%k's hellish blow shot %o into the skybox."
     DeathStrings(4)="%k struck down %o with the fist of Thor."
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
