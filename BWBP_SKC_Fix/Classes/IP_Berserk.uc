//=============================================================================
// IP_Berserk.
//
// A super upgrade pack.
//
//=============================================================================
class IP_Berserk extends BallisticWeaponPickup
	placeable;

var() int HealingAmount;
var() bool bSuperHeal;
var() float AdrenalineAmount;


simulated static function UpdateHUD(HUD H)
{
	H.LastPickupTime = H.Level.TimeSeconds;
	H.LastHealthPickupTime = H.LastPickupTime;
}

/* DetourWeight()
value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
*/
function float DetourWeight(Pawn Other,float PathWeight)
{
	local int Heal;

	if ( (PathWeight > 500) && (HealingAmount < 10) )
		return 0;
	Heal = Min(GetHealMax(Other),Other.Health + HealingAmount) - Other.Health;
	if ( AIController(Other.Controller).PriorityObjective() && (Other.Health > 65) )
		return (0.01 * Heal)/PathWeight;
	return (0.02 * Heal)/PathWeight;
}

event float BotDesireability(Pawn Bot)
{
	local float desire;
	local int HealMax;

	HealMax = GetHealMax(Bot);
	desire = Min(HealingAmount, HealMax - Bot.Health);

	if ( (Bot.Weapon != None) && (Bot.Weapon.AIRating > 0.5) )
		desire *= 1.7;
	if ( bSuperHeal || (Bot.Health < 45) )
		return ( FMin(0.03 * desire, 2.2) );
	else
	{
		if ( desire > 6 )
			desire = FMax(desire,25);
		else if ( Bot.Controller.bHuntPlayer )
			return 0;
		return ( FMin(0.017 * desire, 2.0) );
	}
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
	function Touch( actor Other )
	{
        local Pawn P;

		if ( ValidTouch(Other) )
		{
            P = Pawn(Other);
            if ( P.GiveHealth(HealingAmount, GetHealMax(P)) || (bSuperHeal && !Level.Game.bTeamGame) )
            {
				AnnouncePickup(P);
                SetRespawn();
            }
            P.EnableUDamage(20);
    		P.Controller.AwardAdrenaline(AdrenalineAmount);
			AnnouncePickup(P);
            SetRespawn();
		}
	}
}


function AnnouncePickup( Pawn Receiver )
{
	Receiver.HandlePickup(self);
	PlaySound( PickupSound,SLOT_Interact,TransientSoundVolume, ,TransientSoundRadius );
}

defaultproperties
{
     HealingAmount=50
     bSuperHeal=True
     AdrenalineAmount=100.000000
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.BerserkPickup.BerserkPickupA'
     PickupDrawScale=5.000000
     MaxDesireability=2.000000
     InventoryType=Class'BWBP_SKC_Fix.DoomFists'
     RespawnTime=90.000000
     PickupMessage="You got the Berserk Pack U++"
     PickupSound=Sound'BWBP_SKC_Sounds.Berserk.BerserkPickup'
     StaticMesh=StaticMesh'BWBP_SKC_Static.BerserkPickup.BerserkPickupA'
     Physics=PHYS_None
     DrawScale=5.000000
     TransientSoundVolume=0.600000
     TransientSoundRadius=128.000000
     CollisionRadius=16.000000
     CollisionHeight=28.000000
     Mass=10.000000
}
