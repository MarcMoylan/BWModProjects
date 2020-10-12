//=============================================================================
// ICISPoisoner.
//
// A short lasting radiation poison. Does 20 damage every 5 seconds. 80 dmg in total
// 15 seconds before effects set in. 20 seconds of damage.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class ICISPoisoner extends BallisticEmitter
	placeable;

var   Actor				Victim;			// The guy on fire
var() class<DamageType>	DamageType;		// DamageType done to player
var() int				Damage;			// Damage done every 2.5 seconds
var() float				BurnTime;		// How to burn for
var Controller	InstigatorController;

function Reset()
{
	Destroy();
}

simulated function Initialize(Actor V)
{
	if (V == None)
		return;

	Victim = V;
	SetTimer(5, true);
	SetLocation(Victim.Location - vect(0, 0, 1)*Victim.CollisionHeight);
	SetRotation(Victim.Rotation + rot(0, -16384, 0));
	SetBase(Victim);
}

simulated event Timer()
{
	if (BurnTime == -1)
		return;
	BurnTime-=1;
	if (BurnTime <= 2)
	{
		BurnTime=-1;
		Kill();
	}
	if (Victim != None && Level.NetMode != NM_Client && BurnTime > 1 && BurnTime < 7)
	{
		if ( Instigator == None || Instigator.Controller == None )
			Victim.SetDelayedDamageInstigatorController( InstigatorController );
		class'BallisticDamageType'.static.GenericHurt (Victim, Damage, Instigator, Location, vect(0,0,0), DamageType);
	}
}

simulated event Tick(float DT)
{
	Super.Tick(DT);
	if (Victim == None || Victim.bDeleteMe)
		Destroy();
	if (level.netMode == NM_DedicatedServer && BurnTime <= 1)
		Destroy();
	if (BurnTime == -1)
		return;
	else if (xPawn(Victim) != None && xPawn(Victim).bDeRes)
	{
		SetBase(None);
		Kill();
		BurnTime=-1;
	}
}

defaultproperties
{
     DamageType=Class'BWBP_SKC_Fix.DT_ICISWithdrawl'
     Damage=20
     BurnTime=10.000000 // 7-3 = 4 burns
     AutoDestroy=True
     bNoDelete=False
     bDynamicLight=True
     bFullVolume=True
     bHardAttach=True
     SoundVolume=255
     SoundRadius=64.000000
     bNotOnDedServer=False
}
