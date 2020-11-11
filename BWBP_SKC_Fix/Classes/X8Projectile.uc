//=============================================================================
// X8Projectile.
//
// A launched X8 Knife
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class X8Projectile extends BallisticProjectile;

var   bool			bStuckInWall;
var   bool			bHitPlayer;


simulated function InitProjectile ()
{
	SetTimer(0.1, false);
	super.InitProjectile();
}
simulated event Timer()
{
	super.Timer();
	bFixedRotationDir = True;
	RotationRate.Pitch = -100000;
}
simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	if (Other == None)
		return;

	if (bStuckInWall)
		return;

	else if (Other == Instigator || Other == Owner)
		return;
	if (bHitPlayer)
		return;

	if (Role == ROLE_Authority)
		DoDamage(Other, HitLocation);
	bHitPlayer = true;
	SetLocation(HitLocation);
	Velocity = Normal(HitLocation-Other.Location)*100;
	SetPhysics(PHYS_Falling);
}


simulated event Landed( vector HitNormal )
{
	HitWall( HitNormal, None );
}

simulated singular function HitWall(vector HitNormal, actor Wall)
{
	local int Surf;
	if (bStuckInWall)
		return;
	if (Wall != None && !Wall.bWorldGeometry && !Wall.bStatic)
	{
		if (Role == ROLE_Authority && !bHitPlayer)
			DoDamage(Wall, Location);
		if (Mover(Wall) == None)
		{
			bHitPlayer = true;
			Velocity = HitNormal*100;
			return;
		}
	}
	SetRotation(Rotator(Velocity)/*+rot(32768,0,0)*/);
	OnlyAffectPawns(true);
	SetCollisionSize(40, 40);
	SetPhysics(PHYS_None);
	bFixedRotationDir=false;
	bStuckInWall=true;
	bHardAttach=true;
	CheckSurface(Location, HitNormal, Surf, Wall);
	LifeSpan=20.0;
	if (Wall != None)
		SetBase(Wall);
	if (Level.NetMode != NM_DedicatedServer && ImpactManager != None && /*(!Level.bDropDetail) && (Level.DetailMode != DM_Low) && */EffectIsRelevant(Location,false))
		ImpactManager.static.StartSpawn(Location, HitNormal, Surf, self);
}

defaultproperties
{
     bNetTemporary=False
     bRandomStartRotaion=False
     bUnlit=False
     bUsePositionalDamage=True
     bWarnEnemy=False
     Damage=80.000000
     DamageHead=110
     DamageLimb=60
     DamageTypeHead=Class'BWBP_SKC_Fix.DTX8KnifeRifleLaunchedHead'
     DrawScale=0.150000
     ImpactManager=Class'BallisticFix.IM_KnifeThrown'
     LifeSpan=0.000000
     MyDamageType=Class'BWBP_SKC_Fix.DTX8KnifeRifleLaunched'
     Speed=5000.000000
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.X8.X8Proj'
//     Physics=PHYS_Falling
}
