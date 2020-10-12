//  =============================================================================
//   AH104PrimaryFire.
//  
//   Very powerful, long range bullet attack.
//  
//   You'll be attacked with bullets.
//   Hello whoever is reading this.
//  =============================================================================
class BulldogPrimaryFire extends BallisticInstantFire;
var() class<actor>			AltBrassClass1;			//Alternate Fire's brass
var() class<actor>			AltBrassClass2;			//Alternate Fire's brass (whole FRAG-12)

simulated event ModeDoFire()
{
	if (BulldogAssaultCannon(Weapon).bReady)
	{
		BulldogAssaultCannon(Weapon).UnPrepAltFire();
		return;
	}
	if (BulldogAssaultCannon(Weapon).ReloadState == RS_Shovel)	
	{
		BulldogAssaultCannon(Weapon).bWantsToShoot=true;
		return;
	}
	if (!AllowFire())
		return;
		
	super.ModeDoFire();
    

}


function DoDamage (Actor Other, vector HitLocation, vector TraceStart, vector Dir, int PenetrateCount, int WallCount, optional vector WaterHitLocation)
{
	super.DoDamage(Other, HitLocation, TraceStart, Dir, PenetrateCount, WallCount, WaterHitLocation);
	if (Mover(Other) != None || Vehicle(Other) != None)
		return;
	TargetedHurtRadius(30, 96, class'DTBulldog', 500, HitLocation, Other);
}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	TargetedHurtRadius(30, 96, class'DTBulldog', 500, HitLocation, Other);
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}

simulated function TargetedHurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation, Optional actor Victim )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( Weapon.bHurtEntry )
		return;

	Weapon.bHurtEntry = true;
	foreach Weapon.VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Victims.Role == ROLE_Authority) && UnrealPawn(Victim)==None && (!Victims.IsA('FluidSurfaceInfo')) && Victims != Victim)
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			class'BallisticDamageType'.static.GenericHurt
			(
				Victims,
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
		}
	}
	Weapon.bHurtEntry = false;
}

//Spawn shell casing for first person
function EjectFRAGBrass()
{
	local vector Start, X, Y, Z;
	local Coords C;

	if (Level.NetMode == NM_DedicatedServer)
		return;
	if (!class'BallisticMod'.default.bEjectBrass || Level.DetailMode < DM_High)
		return;
	if (BrassClass == None)
		return;
	if (!Instigator.IsFirstPerson() || PlayerController(Instigator.Controller).ViewTarget != Instigator)
		return;
	if (AIController(Instigator.Controller) != None)
		return;
	C = Weapon.GetBoneCoords(BrassBone);
//	Start = C.Origin + C.XAxis * BrassOffset.X + C.YAxis * BrassOffset.Y + C.ZAxis * BrassOffset.Z;
    Weapon.GetViewAxes(X,Y,Z);
	Start = C.Origin + X * BrassOffset.X + Y * BrassOffset.Y + Z * BrassOffset.Z;
	Spawn(AltBrassClass2, weapon,, Start, Rotator(C.XAxis));
}

defaultproperties
{
     TraceRange=(Min=5500.000000,Max=7000.000000)
     WaterRangeFactor=0.300000
     MaxWallSize=4.000000
     MaxWalls=1
     Damage=105
     DamageHead=145
     DamageLimb=77
     RangeAtten=0.400000
     WaterRangeAtten=0.600000
     DamageType=Class'BWBP_SKC_Fix.DTBulldog'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTBulldogHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTBulldog'
     KickForce=35000
     PenetrateForce=250
     bPenetrate=True
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bDryUncock=True
     MuzzleFlashClass=Class'BallisticFix.M925FlashEmitter'
     FlashScaleFactor=1.100000
     BrassClass=Class'BWBP_SKC_Fix.Brass_BOLT'
     AltBrassClass1=Class'BWBP_SKC_Fix.Brass_FRAGSpent'
     AltBrassClass2=Class'BWBP_SKC_Fix.Brass_FRAG'
     BrassBone="ejector"
     BrassOffset=(X=-30.000000,Y=1.000000)
     RecoilPerShot=2048.000000
     VelocityRecoil=200.000000
//     FireChaos=10.000000
     FireRate=0.500000
     FireAnimRate=1.5
     XInaccuracy=16.500000
     YInaccuracy=9.500000
     BallisticFireSound=(Sound=SoundGroup'BWBP_SKC_Sounds.Bulldog.Bulldog-Fire',Volume=7.500000)
     FireEndAnim=
     TweenTime=0.000000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_75BOLT'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
