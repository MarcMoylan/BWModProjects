//=============================================================================
// FLASHActorBurner.
//
// Fire attached to players. This is spawned on server to do damage and on
// client for effects.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class FLASHActorBurner extends BallisticEmitter
	placeable;

var   Actor				Victim;			// The guy on fire
var() class<DamageType>	DamageType;		// DamageType done to player
var() int				Damage;			// Damage done every 0.5 seconds
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
	SetTimer(0.5, true);

	if (level.netMode == NM_DedicatedServer)
	{
		Emitters[0].Disabled=true;
		Emitters[1].Disabled=true;
		Emitters[2].Disabled=true;
		Emitters[3].Disabled=true;
	}
	else
	{
		// Attach emitters properly
		Emitters[0].SkeletalMeshActor = Victim;
		Emitters[1].SkeletalMeshActor = Victim;
		Emitters[2].SkeletalMeshActor = Victim;
		Emitters[3].SkeletalMeshActor = Victim;
	}
	SetLocation(Victim.Location - vect(0, 0, 1)*Victim.CollisionHeight);
	SetRotation(Victim.Rotation + rot(0, -16384, 0));
	SetBase(Victim);
}

simulated event Timer()
{
	if (BurnTime == -1)
		return;
	BurnTime-=0.5;
	if (BurnTime <= 2 || Victim.PhysicsVolume.bWaterVolume)
	{
		BurnTime=-1;
		Kill();
		bDynamicLight=false;
	}
	if (Victim != None && Level.NetMode != NM_Client && BurnTime > 1)
	{
		if ( Instigator == None || Instigator.Controller == None )
			Victim.SetDelayedDamageInstigatorController( InstigatorController );
		class'BallisticDamageType'.static.GenericHurt (Victim, Damage, Instigator, Location, vect(0,0,0), DamageType);
//		Victim.TakeDamage(Damage, Instigator, Location, vect(0,0,0), DamageType);
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
		Emitters[0].SkeletalMeshActor = None;
		Emitters[1].SkeletalMeshActor = None;
		Emitters[2].SkeletalMeshActor = None;
		Emitters[3].SkeletalMeshActor = None;
		SetBase(None);
		Kill();
		BurnTime=-1;
	}
}

simulated function PhysicsVolumeChange( PhysicsVolume NewVolume )
{
	if ( NewVolume.bWaterVolume )
	{
		if (level.netMode == NM_DedicatedServer)
			Destroy();
		else
			Kill();
	}
}

defaultproperties
{
     DamageType=Class'BWBP_SKC_Fix.DT_M202Immolation'
     Damage=15
     BurnTime=6.000000

     Emitters(0)=SpriteEmitter'BallisticFix.FP7ActorBurner.SpriteEmitter11'

     Emitters(1)=SpriteEmitter'BallisticFix.FP7ActorBurner.SpriteEmitter12'

     Emitters(2)=SpriteEmitter'BallisticFix.FP7ActorBurner.SpriteEmitter13'

     Emitters(3)=SpriteEmitter'BallisticFix.FP7ActorBurner.SpriteEmitter14'

     AutoDestroy=True
     LightType=LT_Flicker
     LightEffect=LE_QuadraticNonIncidence
     LightHue=25
     LightSaturation=100
     LightBrightness=200.000000
     LightRadius=15.000000
     bNoDelete=False
     bDynamicLight=True
     AmbientSound=Sound'BallisticSounds2.FP7.FP7FireLoop'
     bFullVolume=True
     bHardAttach=True
     SoundVolume=255
     SoundRadius=128.000000
     bNotOnDedServer=False
}
