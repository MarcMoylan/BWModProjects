//=========================================================
// Ballistic Camo Weapon.
// Supports various states depending on server's camouflage settings.
//
// by Azarael
//=========================================================

class BallisticCamoHandgun extends BallisticHandgun
    HideDropDown
	CacheExempt;

var() array<Material> CamoMaterials;
var	int				CamoIndex;
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

	if (IsMaster())
	{
		OtherGun.DropFrom(StartLocation);
		if (Instigator.Health > 0)
			return;
	}

    	if (!bCanThrow)
        	return;

	if (AmbientSound != None)
		AmbientSound = None;

    	ClientWeaponThrown();

	if (OtherGun != None)
	{
		OtherGun.bIsMaster = false;
		OtherGun.SetDualMode(false);
		OtherGun.OtherGun = None;
		bIsMaster = false;
		SetDualMode(false);
		OtherGun = None;
	}

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
		BallisticCamoHandgunPickup(Pickup).CamoIndex = CamoIndex;
  		BallisticCamoHandgunPickup(Pickup).Skins[PickupTextureIndex] = CamoMaterials[CamoIndex];
    	}
    Destroy();
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	Super.GiveTo(Other,Pickup);
	if (!bAllowCamo)
		CamoIndex = 0;
	else if (BallisticCamoHandgunPickup(Pickup) != None && BallisticCamoHandgunPickup(Pickup).CamoIndex != -1)
		CamoIndex = BallisticCamoHandgunPickup(Pickup).CamoIndex;
		
//	else CamoIndex = Rand(CamoMaterials.Length);
	
	AdjustCamoProperties(CamoIndex);
	ClientAdjustCamoProperties(CamoIndex);
}

defaultproperties
{
	bAllowCamo=true
	CamoIndex=-1
	PickupTextureIndex=0
}

		