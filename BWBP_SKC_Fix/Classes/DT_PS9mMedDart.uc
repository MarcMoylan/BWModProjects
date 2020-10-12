//=============================================================================
// DT_PS9mMedDart.
//
// DamageType for the PS9m Medical dart secondary fire
// Deus Ex for the win
//
// by Logan "BlackEagle" Richert.
// uses code by Nolan "Dark Carnivour" Richert.
// Copyright© 2011 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_PS9mMedDart extends DT_BWBlunt;

static function Hurt (Actor Victim, float Damage, Pawn Instigator, vector HitLocation, vector Momentum, class<DamageType> DT)
{
	Super.Hurt(Victim, Damage, Instigator, HitLocation, Momentum, DT);

	DoDartEffect(Victim, Instigator);
}

static function DoDartEffect(Actor Victim, Pawn Instigator)
{
	local PS9mDartHeal HP;

	if(Pawn(Victim) == None || Vehicle(Victim) != None || Pawn(Victim).Health <= 0)
		Return;


	HP = Victim.Level.Spawn(class'PS9mDartHeal', Pawn(Victim).Owner);

	HP.Instigator = Instigator;

    if(Victim.Role == ROLE_Authority && Instigator != None && Instigator.Controller != None)
		HP.InstigatorController = Instigator.Controller;

	HP.Initialize(Victim);
}

defaultproperties
{
     WeaponClass=Class'BWBP_SKC_Fix.PS9mPistol'
     DeathString="%o was ironically killed by %k's health dart."
     FemaleSuicide="%o horrifyingly killed herself with a medical dart."
     MaleSuicide="%o horrifyingly killed himself with a medical dart."
     bFastInstantHit=True
     GibPerterbation=0.100000
     KDamageImpulse=3000.000000
     VehicleDamageScaling=0.050000
}
