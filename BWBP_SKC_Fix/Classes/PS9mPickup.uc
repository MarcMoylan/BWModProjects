//=============================================================================
// PS9mPickup.
//[6:25:58 PM] Marc Moylan: hmm
//[6:26:06 PM] Marc Moylan: can you make the other PS9m side face the player?
//[6:26:13 PM] Marc Moylan: we want to show its pretty side
//[6:26:17 PM] Marc Moylan: on the pickup
//=============================================================================
class PS9mPickup extends BallisticCamoHandgunPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_TexExp.utx
#exec OBJ LOAD FILE=BWBP_SKC_StaticExp.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_TexExp.Stealth.Stealth-Main');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_StaticExp.Ps9m.PS9mPickup');
}


defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_StaticExp.Ps9m.PS9mPickup'
     PickupDrawScale=0.190000
     InventoryType=Class'BWBP_SKC_Fix.PS9mPistol'
     RespawnTime=20.000000
     PickupMessage="You picked up the PS-9m Stealth Pistol"
     PickupSound=Sound'BWBP_SKC_SoundsExp.Stealth.Stealth-Pickup'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.Ps9m.PS9mPickup'
     Physics=PHYS_None
     DrawScale=0.150000
     CollisionHeight=4.000000
}
