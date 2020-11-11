//=============================================================================
// RX22AFireControl.
//
// Passive control actor used to list and control interactions between fires
// and fuel deposits
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class Supercharger_ChargeControl extends Info;

var  array<struct SingeVictim {var Pawn Vic; var int Burns; var float NextReduceTime;}> SingeVictims;

struct FlameHit				// Info about a shot fired
{
	var Pawn			Instigator;
	var vector			HitLoc;	// Where it hits
	var vector			HitNorm;// Normal for hit
	var float			HitTime;// When it will hit
	var actor			HitActor;
};
var   array<FlameHit>		FlameHits;		// Shots fired, used to time impacts

struct SingeSpot			// Info for a spot/area that was hit with fire
{
	var vector	Loc;			// The spot
	var int		Hits;			// How many hits so far
	var RX22ASurfaceFire Fire;	// The fire actor if there is one
};
var   array<SingeSpot> SingeSpots;		// Places that have been flamed


// Purpose: Cause sprayed flame interaction
// Actions: Spawn a projectile and register the delayed hit
// Sources: Flamer primary fire with traced hit info
simulated function FireShot(vector Start, Vector End, float Dist, bool bHit, vector HitNorm, Pawn InstigatedBy, actor HitActor)
{
	local Supercharger_ZapProjectile Proj;
	local int i;

	Proj = Spawn (class'Supercharger_ZapProjectile',InstigatedBy,, Start, Rotator(End-Start));
	if (Proj != None)
	{
		Proj.Instigator = InstigatedBy;
		Proj.ChargeControl = self;
		Proj.InitFlame(End);
	}
	if (bHit)
	{
		i = FlameHits.length;
		FlameHits.length = i + 1;
		FlameHits[i].Instigator = InstigatedBy;
		FlameHits[i].HitLoc = End;
		FlameHits[i].HitNorm = HitNorm;
		FlameHits[i].HitTime = level.TimeSeconds + Dist / 3600;
		FlameHits[i].HitActor = HitActor;
	}
}

// Purpose: Facilitate and limit conditions for igniting players
// Actions: Increment singe count for the specified enemy, possibly start an ActorBurner
// Sources: Flame projectiles and radius damagers or fires that can ignite a player
function FireSinge(Pawn P, Pawn InstigatedBy)
{
	local int i;


		for (i=0;i<SingeVictims.length;i++)
			if (SingeVictims[i].Vic == P)
			{
				SingeVictims[i].NextReduceTime = level.TimeSeconds + 2.0;
				SingeVictims[i].Burns++;
				if (SingeVictims[i].Burns == 25)
					MakeNewExploder(P, InstigatedBy);
				if (SingeVictims[i].Burns == 15)
					MakeNewBurner(P, InstigatedBy);
				return;
			}
		SingeVictims.length = i+1;
		SingeVictims[i].NextReduceTime = level.TimeSeconds + 2.0;
		SingeVictims[i].Vic = P;
		SingeVictims[i].Burns = 1;
}

// Purpose: Facilitate and limit conditions for causing wall fires, flame wall hit interaction
// Actions: Radius damage/singe, increment singe count for hit location, start wall fire, addfuel to existing fire
// Sources: Flame firemode hit detection or preordered hits
simulated function DoFlameHit(FlameHit Hit)
{
	local int i;

	BurnRadius(2, 128, class'DTRX22ABurned', 0, Hit.HitLoc, Hit.Instigator);

		for(i=0;i<SingeSpots.length;i++)
			if (VSize(SingeSpots[i].Loc-Hit.HitLoc) < 128)
			{
				SingeSpots[i].Hits++;
				if (SingeSpots[i].Hits > 20)
				{
					class'IM_XMBurst'.static.StartSpawn(Hit.HitLoc + Hit.HitNorm * 32, Hit.HitNorm, 0, self);
					BurnRadius(50, 300, class'DT_BFGExplode', 500, Hit.HitLoc, Hit.Instigator);
					SingeSpots.Remove(i, 1);
					return;
				}
				break;
			}

		if (i>=SingeSpots.length)
		{
			i = SingeSpots.length;
			SingeSpots.length = i + 1;
			SingeSpots[i].Loc = Hit.HitLoc;
			SingeSpots[i].Hits = 1;
			class'IM_LS14Impacted'.static.StartSpawn(Hit.HitLoc, Hit.HitNorm, 0, self);
		}

}


// Internal functions

event Tick(float DT)
{
	local int i;

	super.Tick(DT);

	for (i=0;i<FlameHits.length;i++)
		if (level.TimeSeconds >= FlameHits[i].HitTime)
		{
			DoFlameHit(FlameHits[i]);
			FlameHits.Remove(i,1);
			i--;
		}

	for (i=0;i<SingeVictims.length;i++)
		if (level.TimeSeconds >= SingeVictims[i].NextReduceTime)
		{
			SingeVictims[i].Burns--;
			if (SingeVictims[i].Burns < 1)
			{
				SingeVictims.Remove(i,1);
				i--;
			}
			else
				SingeVictims[i].NextReduceTime = level.TimeSeconds + 0.25;
		}
}

simulated function BurnRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation, Pawn InstigatedBy, Optional actor Victim)
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( (Victims != self) && (Victims.Role == ROLE_Authority) && (!Victims.IsA('FluidSurfaceInfo')) && Victims != Victim)
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			if (Pawn(Victims) != None && FRand()-0.4 < damageScale)
				FireSinge(Pawn(Victims), InstigatedBy);
//			if ( Instigator == None || Instigator.Controller == None )
//				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			class'BallisticDamageType'.static.GenericHurt
			(
				Victims,
				damageScale * DamageAmount,
				InstigatedBy,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
		}
	}
	bHurtEntry = false;
}

// Utility functions
/*
	NearPool
	NearCloud
	HasSoak
	NearFire
	HasBurner
	SpawnFire
	SpawnPool
	SpawnCloud
	SpawnSoak
	SpawnBurner
	GetNodeIndex
*/
function MakeNewBurner (Actor Other, Pawn InstigatedBy)
{
	local Supercharger_ActorFire PF;

	PF = Spawn(class'Supercharger_ActorFire',InstigatedBy,,Other.Location, Other.Rotation);
	PF.SetFuel(5);
//	class'IM_XM84Grenade'.static.StartSpawn(Location, vect(0,0,1), 0, self);
//	HurtRadius(200, 300, class'DT_BFGExplode', 1000, location);
	PF.Initialize(Other);

}

function MakeNewExploder (Actor Other, Pawn InstigatedBy)
{

	local Supercharger_Detonator Proj;

	Proj = Spawn (class'Supercharger_Detonator',InstigatedBy,,Other.Location, Other.Rotation);

	if (Proj != None)
	{
		Proj.Instigator = InstigatedBy;
		Proj.ChargeControl = self;
	}
}


defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     bNetNotify=True
}
