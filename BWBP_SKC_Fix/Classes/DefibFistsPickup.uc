//=============================================================================
// BrawlingPickup- FIXME
//from the bottom of my heart
//      while (cs != NULL)
//
//     {
//      printf("%s\n",cs);
//       cs = strtok(NULL," ");
//     }//Now everything should be split up. Let's fork!
// pid = fork();
//[8:47:44 PM] Captain Xavious: ?!
//[8:47:50 PM] Captain Xavious: YES
//[8:47:51 PM] Captain Xavious: AWESOME
//[8:47:58 PM] Captain Xavious: THIS IS EXACTLY WHAT I WANTED
//[8:48:01 PM] Marc Moylan: OORA YEAH
//[8:48:03 PM] Captain Xavious: THANK YOU
//[8:48:05 PM] Marc Moylan: ITS FORK() TIME
//[8:48:09 PM] Marc Moylan: YOURE WELCOME
//[8:48:11 PM] Marc Moylan: RAAAAAAAAAAA
//[8:48:19 PM] Captain Xavious: lets fork this shit up
//=============================================================================
class DefibFistsPickup extends BallisticWeaponPickup
	placeable;

var() int HealingAmount;
var() bool bSuperHeal;
var() float AdrenalineAmount;

#exec OBJ LOAD FILE=BallisticWeapons2.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BallisticWeapons2.A909.WristBladeSkin');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.A73BladeCut');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.A73BladeCutWood');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.A909.A909Hi');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.A909.A909Lo');
}

simulated static function UpdateHUD(HUD H)
{
	H.LastPickupTime = H.Level.TimeSeconds;
	H.LastHealthPickupTime = H.LastPickupTime;
	H.LastWeaponPickupTime = H.LastPickupTime;
}

static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.PickupMessage$Default.HealingAmount;
}

function int GetHealMax(Pawn P)
{
	if (bSuperHeal)
		return P.SuperHealthMax;

	return P.HealthMax;
}

auto state Pickup
{

	function BeginState()
	{
		if (!bDropped && class<BallisticWeapon>(InventoryType) != None)
			MagAmmo = class<BallisticWeapon>(InventoryType).default.MagAmmo;
		Super.BeginState();
	}

	function Touch( actor Other )
	{
		local Pawn P;
		local xPawn x;
		x = xPawn(Other);

		if ( ValidTouch(Other) )
		{
			P = Pawn(Other);
			P.GiveWeapon("BWBP_SKC_Fix.DefibFists");
			P.GiveWeapon("BWBP_SKC_Fix.DoomFists");
			x.DoComboName("ComboBerserk");
            if ( P.GiveHealth(HealingAmount, GetHealMax(P)) || (bSuperHeal && !Level.Game.bTeamGame) )
            {
				AnnouncePickup(P);
                SetRespawn();
            }
		}
	}
	function bool ValidTouch( actor Other )
	{
		// make sure its a live player
		if ( (Pawn(Other) == None) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).DrivenVehicle == None && Pawn(Other).Controller == None) )
			return false;

		// make sure not touching through wall
		if ( !FastTrace(Other.Location, Location) )
			return false;

		// make sure game will let player pick me up
		if( Level.Game.PickupQuery(Pawn(Other), self) )
		{
			LastPickedUpBy = Pawn(Other);
			TriggerEvent(Event, self, Pawn(Other));
			return true;
		}
		return false;
	}

}

defaultproperties
{
     HealingAmount=50
     bSuperHeal=True
     AdrenalineAmount=100.000000
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.BerserkPickup.BerserkPickupB'
     PickupDrawScale=5.000000
     InventoryType=Class'BWBP_SKC_Fix.DefibFists'
     RespawnTime=70.000000
     PickupMessage="You got the Combat Defibrillators."
     PickupSound=Sound'BWBP_SKC_Sounds.Berserk.BerserkPickup'
     StaticMesh=StaticMesh'BWBP_SKC_Static.BerserkPickup.BerserkPickupB'
     Physics=PHYS_None
     DrawScale=5.000000
     TransientSoundVolume=0.600000
     TransientSoundRadius=128.000000
     CollisionRadius=16.000000
     CollisionHeight=28.000000
     Mass=10.000000
}
