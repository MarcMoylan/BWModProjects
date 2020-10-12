//=============================================================================
// FLASHGroundFire.
//
// A small patch of fire. This is an emitter, but it also does the server side
// damage stuff. These will fall to the ground and stay wherever they land.
// This is spaawned on server for damage and on clients for effects.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class NukeGroundFire extends BallisticEmitter
	placeable;

var   float				BurnTime;		// How long its been burning
var() float				Damage;			// Damage per 0.5 seconds
var() class<DamageType>	DamageType;		// Damage type for touching damage
var   AvoidMarker		Fear;			// Da phear spauwt...
var Controller	InstigatorController;

function Reset()
{
	Destroy();
}


simulated function Tick(float DT)
{
	super.Tick(DT);
	if (BurnTime == 666)
		return;
	BurnTime-=DT;
	if (BurnTime <= 0)
	{
		Kill();
		BurnTime=666;
	}
}

function Landed(vector HitNormal)
{
	HitWall(HitNormal, none);
}
function HitWall (vector HitNormal, actor Wall)
{
	SetPhysics(PHYS_None);
	if (level.NetMode == NM_Client)
		return;
	bCollideWorld=false;
	SetCollision(true, false, false);
	SetCollisionSize( 70, 70 );
	Fear = Spawn(class'AvoidMarker');
	Fear.SetCollisionSize(120, 120);
    Fear.StartleBots();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (level.NetMode != NM_Client)
		SetTimer(0.5, true);
	BurnTime -= 4*FRand();
	if (level.netMode == NM_DedicatedServer)
	{
		Emitters[0].Disabled=true;
		Emitters[1].Disabled=true;
		Emitters[2].Disabled=true;
	}
}

function Timer()
{
	local int i;

	if (level.netMode == NM_DedicatedServer && BurnTime == 666)
		Destroy();

	if (PhysicsVolume.bWaterVolume)
		return;

	for (i=0;i<Touching.length;i++)
	{
		if ( Instigator == None || Instigator.Controller == None )
			Touching[i].SetDelayedDamageInstigatorController( InstigatorController );
		class'BallisticDamageType'.static.GenericHurt (Touching[i], Damage, Instigator, Touching[i].Location, vect(0,0,0), DamageType);
//		Touching[i].TakeDamage(Damage, Instigator, Touching[i].Location, vect(0,0,0), DamageType);
	}
}

simulated function Destroyed()
{
	if (Fear!=None)
		Fear.Destroy();
	super.Destroyed();
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
     BurnTime=30.000000
     Damage=2.000000
     DamageType=Class'BWBP_SKC_Fix.DT_NukeRadius'
     Emitters(0)=SpriteEmitter'BallisticFix.FP7GroundFire.SpriteEmitter1'

     Emitters(1)=SpriteEmitter'BallisticFix.FP7GroundFire.SpriteEmitter9'

     Emitters(2)=SpriteEmitter'BallisticFix.FP7GroundFire.SpriteEmitter10'

     AutoDestroy=True
     bNoDelete=False
     Physics=PHYS_Falling
     CollisionRadius=2.000000
     CollisionHeight=2.000000
     bCollideWorld=True
     bUseCylinderCollision=True
     Mass=30.000000
     bNotOnDedServer=False
}
