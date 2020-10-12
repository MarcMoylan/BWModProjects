//=============================================================================
// FLASHFireControl.
//
// This is spawned when a fire grenade explodes. It lights up players, plays
// sounds and effects and spawns all other sub fire stuff...
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class NukeRadiationControlONS extends Actor;

var() float				DamageRadius;			// Radius in which to immolate players
var   Vector			GroundFireSpots[50];	// Vectors sent to client to tell it where to spawn fires
var() class<BCImpactManager>	ImpactManager;	// Impact manager to spawn on final hit

replication
{
	unreliable if (Role == ROLE_Authority)
		GroundFireSpots;
}

function Reset()
{
	Destroy();
}

simulated function PostNetBeginPlay()
{
	if (Role < ROLE_Authority)
		Initialize();
}

simulated function Initialize()
{
//	local Pawn A;
	local Actor A;

	// Spawn effects, sounds, etc
/*    if (ImpactManager != None)
	{
		if (Instigator == None)
			ImpactManager.static.StartSpawn(Location, vect(0,0,1), 0, Level.GetLocalPlayerController()/*.Pawn*/);
		else
			ImpactManager.static.StartSpawn(Location, vect(0,0,1), 0, Instigator);
	}*/
	// Immolate nearby players
//	foreach VisibleCollidingActors( class 'Pawn', A, DamageRadius, Location )
	foreach RadiusActors( class 'Actor', A, DamageRadius, Location )
	{
		if (xPawn(A)!=None && A.bCanBeDamaged)
		{
			IgniteActor(A);
		}

	}
	if (level.NetMode == NM_Client)
		return;

}

simulated function PostNetReceive()
{
	local int i;
	local NukeGroundFire F;
	if (level.NetMode != NM_Client)
		return;
	for (i=0;i<ArrayCount(GroundFireSpots);i++)
	{
		if (GroundFireSpots[i] != vect(0,0,0))
		{
			F = Spawn(class'NukeGroundFire',self,,GroundFireSpots[i], rot(0,0,0));
			if (F != None)
			{
				F.Velocity = GroundFireSpots[i] - Location;
				GroundFireSpots[i] = vect(0,0,0);
			}
		}
	}
}

simulated function IgniteActor(Actor A)
{
	local NukeActorBurner PF;

	PF = Spawn(class'NukeActorBurner',self, ,A.Location);
	PF.Instigator = Instigator;

    	if ( Role == ROLE_Authority && Instigator != None && Instigator.Controller != None )
		PF.InstigatorController = Instigator.Controller;
//	if (A.Controller != None && Instigator.Controller != None && A.Controller.SameTeamAs(Instigator.Controller))
//		return;
	if (Instigator.Controller != None && Pawn(A).Controller != Instigator.Controller && Instigator.Controller.SameTeamAs(Pawn(A).Controller))
		return;
	PF.Initialize(A);
}

defaultproperties
{
     DamageRadius=20000.000000
     ImpactManager=Class'BWBP_SKC_Fix.IM_FlareExplode'
     LightType=LT_Flicker
     LightEffect=LE_QuadraticNonIncidence
     LightHue=25
     LightSaturation=100
     LightBrightness=200.000000
     LightRadius=15.000000
     bHidden=True
     bDynamicLight=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     AmbientSound=Sound'BallisticSounds2.FP7.FP7FireLoop'
     LifeSpan=10.000000
     bFullVolume=True
     SoundVolume=255
     SoundRadius=192.000000
     bNetNotify=True
}
