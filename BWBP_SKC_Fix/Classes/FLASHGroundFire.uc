//=============================================================================
// AT40 ground fires.
//
// FP7 multihit fix.
// by Azarael based on RuneStorm code
//=============================================================================
class FLASHGroundFire extends BallisticEmitter
	placeable;

var   float				BurnTime;		// How long its been burning
var   AvoidMarker		Fear;			// Da phear spauwt...
var Controller	InstigatorController;
var FLASHFireControl	FireControl;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	BurnTime -= 4*FRand();
	if (level.netMode == NM_DedicatedServer)
	{
		Emitters[0].Disabled=true;
		Emitters[1].Disabled=true;
		Emitters[2].Disabled=true;
	}
}

function Reset()
{
	Destroy();
}

simulated function Terminate(float Delay)
{
	SetTimer(Delay, false);
}

simulated function Timer()
{
	if (level.netMode == NM_DedicatedServer)
		GotoState('DSDying');
	else
		Kill();
}

state DSDying
{
Begin:
	Sleep(3.0);
	Destroy();
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
	SetCollisionSize( 70, 100 );
	Fear = Spawn(class'AvoidMarker');
	Fear.SetCollisionSize(120, 120);
    Fear.StartleBots();
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
     BurnTime=10.000000
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
