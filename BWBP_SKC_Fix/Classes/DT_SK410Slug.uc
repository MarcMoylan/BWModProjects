//=============================================================================
// DT_SK410Slug.
//
// DamageType for the SK410 slug direct hits
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_SK410Slug extends DT_BWExplode;

defaultproperties
{
     DeathStrings(0)="%k's SK-410 slug sniped %o like a fleeing Cossack."
     DeathStrings(1)="%k's SK-410 did its best Oprichniki impression on %o."
     DeathStrings(2)="%k purged %o with some socialist slugs."
     WeaponClass=Class'BWBP_SKC_Fix.SK410Shotgun'
     DeathString="%k's SK-410 slug sniped %o like a fleeing Cossack."
     FemaleSuicide="%o won the explosive eating competition."
     MaleSuicide="%o won the explosive eating competition."
     bDelayedDamage=True
     VehicleDamageScaling=0.400000
}
