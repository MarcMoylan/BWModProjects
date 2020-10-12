//=========================================================
// Ballistic Camo Weapon.
// Supports various states depending on server's camouflage settings.
//
// by Azarael
//=========================================================

class BallisticCamoWeapon extends BallisticWeapon
    HideDropDown
	CacheExempt;

var() array<Material> CamoMaterials;
var(BallisticCamoWeapon)	int				CamoIndex;
var	int				PickupTextureIndex;


var() globalconfig bool		bAllowCamo;		// Use the camo system
var() globalconfig bool		bAllowCamoEffects;	// Camo can change properties
var() config int		ForcedCamo;		// Force a camo


replication
{
	reliable if (Role == ROLE_Authority)
		ClientAdjustCamoProperties;
}

//Adjust camo props here
simulated function AdjustCamoProperties(int Index)
{
	Skins[0] = CamoMaterials[Index];
}

simulated function ClientAdjustCamoProperties(int Index)
{
 	if (Level.NetMode == NM_Client)
		AdjustCamoProperties(Index);
}

function DropFrom(vector StartLocation)
{
	local int m;
		local Pickup Pickup;

	if (!bCanThrow)
        	return;

	if (AmbientSound != None)
		AmbientSound = None;

    	ClientWeaponThrown();

    	for (m = 0; m < NUM_FIRE_MODES; m++)
    	{
        	if (FireMode[m] != None && FireMode[m].bIsFiring)
           		StopFire(m);
    	}

	if ( Instigator != None )
		DetachFromPawn(Instigator);

	Pickup = Spawn(PickupClass,self,, StartLocation);
	if ( Pickup != None )
	{
        	if (Instigator.Health > 0)
        	    WeaponPickup(Pickup).bThrown = true;
    		Pickup.InitDroppedPickupFor(self);
		Pickup.Velocity = Velocity;
		BallisticCamoPickup(Pickup).CamoIndex = CamoIndex;
  		BallisticCamoPickup(Pickup).Skins[PickupTextureIndex] = CamoMaterials[CamoIndex];
    	}
    Destroy();
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	Super.GiveTo(Other,Pickup);
	if (!bAllowCamo)
		CamoIndex = 0;
//	else if (ForcedCamo != -1)
//		CamoIndex = ForcedCamo;
	else if (BallisticCamoPickup(Pickup) != None && BallisticCamoPickup(Pickup).CamoIndex != -1)
		CamoIndex = BallisticCamoPickup(Pickup).CamoIndex;
		
//	else CamoIndex = Rand(CamoMaterials.Length);
	
	AdjustCamoProperties(CamoIndex);
	ClientAdjustCamoProperties(CamoIndex);
}

defaultproperties
{
	bAllowCamo=true
	bAllowCamoEffects=true
	CamoIndex=-1
	ForcedCamo=-1
	PickupTextureIndex=0
}

		