//=============================================================================
// DT_MRLRadius.
//
// DamageType for the JL-21 PeaceMaker radius
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_LS14RocketRadius extends DT_BWExplode;

defaultproperties
{
     DeathStrings(0)="%k's LS14 rocket turned %o into a crawler."
     DeathStrings(1)="%o's upper torso was turned into ashes by %k's LS-14"
     DeathStrings(2)="%k blew off %o's toes with a wild rocket."
     DeathStrings(3)="%o's head was turned into a Rorschach mark by %k's LS-14 rocket."
     DeathStrings(4)="%k made %o's brains ignite with a deadly passion."
     FemaleSuicides(0)="%o had her heart set aflame by a LS-14 rocket."
     FemaleSuicides(1)="%o's eyes were turned into goo by a whizzing rocket."
     MaleSuicides(0)="%o had his heart set aflame by a LS-14 rocket."
     MaleSuicides(1)="%o's eyes were turned into goo by a whizzing rocket."
     WeaponClass=Class'BWBP_SKC_Fix.LS14Carbine'
     DeathString="%k made %o crawl for %vh life by the LS-14."
     FemaleSuicide="%o had her heart set aflame by a LS-14 rocket."
     MaleSuicide="%o had his heart set aflame by a LS-14 rocket."
     bDelayedDamage=True
     VehicleDamageScaling=0.250000
     VehicleMomentumScaling=0.500000
}
