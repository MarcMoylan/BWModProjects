//=============================================================================
// G28Thrown.
//
// Gas grenade projectile. Spawns cloud control actor, makes little noises...
// Gas is healing gas
// Is flammable
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class G28Thrown extends BallisticPineapple;

#exec OBJ LOAD FILE=BallisticSounds2.uax

var() class<damageType>	ShotDamageType;	// Damagetype to use when detonated by damage
var   Emitter PATrail;
var   bool				bDetonate;		// Flaged for detonation next tick. Sent to net clients when detonated on server
var   bool				bDetonated;		// Blown up, no more blowing up.
var() bool				bDamaged;		// Has been damaged and is about to blow
var() int				Health;			// Distance from death

replication
{
	reliable if (Role == ROLE_Authority)
		bDetonate;
}

simulated function InitEffects ()
{
	if (Level.NetMode != NM_DedicatedServer && Speed > 400 && PATrail==None && level.DetailMode == DM_SuperHigh)
	{
		PATrail = Spawn(class'PineappleTrail', self,, Location);
		if (PATrail != None)
			class'BallisticEmitter'.static.ScaleEmitter(PATrail, DrawScale);
		if (PATrail != None)
			PATrail.SetBase (self);
	}
}


event TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> Damagetype)
{

	if (bDamaged || class<BallisticDamageType>(DamageType)!=None && !class<BallisticDamageType>(DamageType).default.bIgniteFires)
		return;

	Health-=Damage;
	if (Health > 0)
		return;
	bDamaged = true;
	if (InstigatedBy != None)
	{
		Instigator = InstigatedBy;
		InstigatorController = InstigatedBy.Controller;
		MyRadiusDamageType = ShotDamageType;
	}
	SetTimer(0.01+0.3*FRand(), false);
	ExplodeFire(Location, vector(Rotation));
}

simulated function DestroyEffects()
{
	super.DestroyEffects();
	if (PATrail != None)
		PATrail.Kill();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local G28CloudControl C;
	local vector X,Y,Z;

	if (bExploded)
		return;
	if ( Role == ROLE_Authority )
	{
		C = Spawn(class'G28CloudControl',self,,HitLocation-HitNormal*2);
		if (C!=None)
		{
			C.Instigator = Instigator;
		}
	}
	if (Level.NetMode != NM_DedicatedServer && TrailClass != None && Trail == None)
	{
		GetAxes(rot(16384,0,0),X,Y,Z);
		X = X >> Rotation;
		Y = Y >> Rotation;
		Z = Z >> Rotation;
		Trail = Spawn( TrailClass, self,, Location + class'BUtil'.static.AlignedOffset(Rotation,TrailOffset), OrthoRotation(X,Y,Z) );
		if (Trail != None)
			Trail.SetBase (self);
		PlaySound(sound'BallisticSounds3.T10.T10-Ignite',, 0.7,, 128, 1.0, true);
		AmbientSound = Sound'BallisticSounds2.T10.T10-toxinLoop';
	}
	bExploded=true;
	LifeSpan = 12;
	SetTimer(10.5,false);
}

simulated function ExplodeFire(vector HitLocation, vector HitNormal)
{
	if(bDetonated)
		return;

	bDetonated = true;
	if (ShakeRadius > 0)
		ShakeView(HitLocation);
	BlowUp(HitLocation);
    	if (ImpactManager != None)
	{
		if (Instigator == None)
			ImpactManager.static.StartSpawn(HitLocation, HitNormal, 0, Level.GetLocalPlayerController()/*.Pawn*/);
		else
			ImpactManager.static.StartSpawn(HitLocation, HitNormal, 0, Instigator);
	}
	Destroy();
}

simulated function BlowUp(vector HitLocation)
{
	local vector Start;
    	local rotator Dir;
    	local int i;

	Start = Location/* + 10 * HitNormal*/;
	if (FlakCount > 0 && FlakClass != None)
	{
		for (i=0;i<FlakCount;i++)
		{
			Dir.Yaw += FRand()*40000-20000;
			Dir.Pitch += FRand()*40000-20000;
			Spawn( FlakClass,, '', Start, Dir);
		}
	}
	TargetedHurtRadius(Damage, DamageRadius, MyRadiusDamageType, MomentumTransfer, HitLocation, HitActor);
	if ( Role == ROLE_Authority )
		MakeNoise(1.0);
}

simulated function Timer()
{
	super.Timer();

	// Was damaged or detonated, now it can blow
	if (bDetonate)
		ExplodeFire(Location, vect(0,0,1));
	else if (bDamaged)
		Detonate();

	if (LifeSpan < 3 && Trail != None)
	{
		AmbientSound = None;
		Emitter(Trail).Kill();
		Trail = None;
	}
}

// Call this to make it go BOOM...
simulated function Detonate()
{
	bDetonate = true;
	SetTimer(0.01+0.1*FRand(), false);
}

simulated function Tick(float DT)
{
	super.Tick(DT);

	// It's time to blow
	if (bDetonate && Level.NetMode == NM_Client)
		Explode(Location, vect(0,0,1));
}



function InitPineapple(float PSpeed, float PDelay)
{
	Speed = PSpeed;
	DetonateDelay = PDelay;
	NewSpeed = Speed;
	NewDetonateDelay = DetonateDelay;

	if (DetonateDelay <= 0)
		DetonateDelay = 0.05;
	if (DetonateDelay <= StartDelay)
		StartDelay = DetonateDelay / 2;
}

defaultproperties
{
     DetonateDelay=2.000000
     ImpactDamage=10
     Health=20
     ImpactDamageType=Class'BWBP_SKC_Fix.DTG28Grenade'
     ShotDamageType=Class'BWBP_SKC_Fix.DTG28Explode'
     ImpactManager=Class'BWBP_SKC_Fix.IM_G28Explode'
     TrailClass=Class'BWBP_SKC_Fix.G28Spray'
     TrailOffset=(Z=8.000000)
     MyRadiusDamageType=Class'BWBP_SKC_Fix.DTG28Gas'
     SplashManager=Class'BallisticFix.IM_ProjWater'
     Damage=120.000000
     DamageRadius=300.000000
     MyDamageType=Class'BWBP_SKC_Fix.DTG28Grenade'
     ImpactSound=SoundGroup'BallisticSounds2.NRP57.NRP57-Concrete'
     StaticMesh=StaticMesh'BWBP_SKC_Static.G28.G28Proj'
     DrawScale=0.200000
     SoundVolume=192
     SoundRadius=128.000000
}
