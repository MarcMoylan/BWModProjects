//=============================================================================
//PUGUP
//class BulldogPickup extends BallisticHandgunPickup
//[8:53:20 PM] Marc Moylan: this has been here forever
//[8:53:37 PM] Marc Moylan: I think it still thinks it is an AH104
//=============================================================================
class PUGPickup extends BallisticWeaponPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx


defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.Bulldog.BulldogPickupLow'
     PickupDrawScale=4.000000
     InventoryType=Class'BWBP_SKC_Fix.PUGAssaultCannon'
     RespawnTime=10.000000
     PickupMessage="You picked up the PUG-M2 Riot Suppression Weapon"
     PickupSound=Sound'BallisticSounds2.M806.M806Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_Static.Bulldog.BulldogPickupHi'
     Physics=PHYS_None
     DrawScale=8.000000
//     PrePivot=(Y=-26.000000)
     CollisionHeight=4.000000
}
