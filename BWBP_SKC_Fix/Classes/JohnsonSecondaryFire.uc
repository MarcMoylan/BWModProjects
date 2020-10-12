//=============================================================================
// RSDarkMeleeFire.
//
// Continuous chainsaw attack of the darkstar
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================

class JohnsonSecondaryFire extends BallisticMeleeFire;

var() Pawn		HookedVictim;
var() float		HookTime;

var() sound		SawFreeLoop;
var() sound		SawHackLoop;
var() sound		SawStop;

//	SawStart		Normal to held
//	SawIdle			Saw Held
//	SawAttack		Saw Held and hitting
//	SawAttackEnd	Saw Held releasng target going to saw held
//	SawEnd			Saw Release

//	BWBP4-Sounds.DarkStar.Dark-
//	Saw			held, idle
//	SawOpen		Start saw mode
//	SawClose	Leaving saw mode
//	SawPitch	Attacking enemy with saw
//	SawHits		Looping impact sounds
//


//Do the spread on the client side
function PlayFiring()
{
	if (ScopeDownOn == SDO_Fire)
		BW.TemporaryScopeDown(0.5, 0.0);

	if (JohnsonRifle(Weapon).bLatchedOn)
		Weapon.AmbientSound = SawHackLoop;
	else
		Weapon.AmbientSound = SawFreeLoop;

    if (FireCount == 0)
    {
		Weapon.PlayOwnedSound(BallisticFireSound.Sound,BallisticFireSound.Slot,BallisticFireSound.Volume,BallisticFireSound.bNoOverride,BallisticFireSound.Radius,BallisticFireSound.Pitch,BallisticFireSound.bAtten);
		BW.SafePlayAnim('SawStart', FireAnimRate, TweenTime, ,"FIRE");
	}
    else if (FireCount > 4)
    {
		if (JohnsonRifle(Weapon).bLatchedOn)
    		BW.SafeLoopAnim('SawAttack', FireAnimRate, TweenTime, ,"FIRE");
		else
    		BW.SafeLoopAnim('SawIdle', FireAnimRate, TweenTime, ,"FIRE");
    }
    ClientPlayForceFeedback(FireForce);  // jdf
    FireCount++;
}

function ServerPlayFiring()
{
    if (FireCount == 0)
    {
		Weapon.PlayOwnedSound(BallisticFireSound.Sound,BallisticFireSound.Slot,BallisticFireSound.Volume,BallisticFireSound.bNoOverride,BallisticFireSound.Radius,BallisticFireSound.Pitch,BallisticFireSound.bAtten);
		BW.SafePlayAnim('SawStart', FireAnimRate, TweenTime, ,"FIRE");
	}
    else if (FireCount > 4)
    {
		if (JohnsonRifle(Weapon).bLatchedOn)
    		BW.SafeLoopAnim('SawAttack', FireAnimRate, TweenTime, ,"FIRE");
		else
    		BW.SafeLoopAnim('SawIdle', FireAnimRate, TweenTime, ,"FIRE");
    }
}


simulated function bool HasAmmo()
{
	return true;
}

simulated event ModeDoFire()
{
	BW.GunLength = 1;
	super.ModeDoFire();
}

simulated function StopFiring()
{
	Weapon.PlayOwnedSound(SawStop,BallisticFireSound.Slot,BallisticFireSound.Volume,BallisticFireSound.bNoOverride,BallisticFireSound.Radius, 0.75 + JohnsonRifle(Weapon).ChainSpeed * 0.375 ,BallisticFireSound.bAtten);
	BW.GunLength = BW.default.GunLength;
}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	local vector X, Y, Z;

	if (Weapon != None && Weapon.Role == ROLE_Authority)
		JohnsonRifle(Weapon).bLatchedOn = true;

	GetAxes(rotator(HitLocation-Instigator.Location), X, Y, Z);
	Instigator.AddVelocity(Normal(X*vect(1,1,0))*100 + Y*(2*FRand()-1)*25);

	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}

function NoHitEffect (Vector Dir, optional vector Start, optional vector HitLocation, optional vector WaterHitLoc)
{
	if (Weapon != None && Weapon.Role == ROLE_Authority)
		JohnsonRifle(Weapon).bLatchedOn = false;

	super.NoHitEffect (Dir, Start, HitLocation, WaterHitLoc);
}

simulated event ModeTick(float DT)
{
	local Vector ForceDir;
	super.ModeTick(DT);

	if (!IsFiring())
	{
		JohnsonRifle(Weapon).bLatchedOn = false;
		Weapon.AmbientSound = None;
	}

	if (Weapon.Role == ROLE_Authority && HookedVictim != None && vector(Instigator.GetViewRotation()) Dot Normal(HookedVictim.Location - Instigator.Location) > 0.8)
	{
		ForceDir = (Instigator.Location + vector(Instigator.GetViewRotation()) * 192) - HookedVictim.Location;
		if (Instigator.Physics == PHYS_Falling)
			ForceDir.Z = 0;

		ForceDir *= 400;
		HookedVictim.AddVelocity(HookedVictim.Velocity*-0.7 + (ForceDir/HookedVictim.Mass) * DT);
//		HookedVictim.AddVelocity(Normal(ForceDir) * DT * FMin(600, VSize(ForceDir) * 25));
		if (level.TimeSeconds - HookTime > 0.5)
			HookedVictim = None;
	}

}

function DoDamage (Actor Other, vector HitLocation, vector TraceStart, vector Dir, int PenetrateCount, int WallCount, optional vector WaterHitLocation)
{
	local float				Dmg;
	local class<DamageType>	HitDT;
	local Actor				Victim;
	local Vector			RelativeVelocity, ForceDir, X, Y, Z;
	local bool				bWasAlive;
	local int				OldHealth;

	Dmg = GetDamage(Other, HitLocation, Dir, Victim, HitDT);
	// bUseRunningDamage
	RelativeVelocity = Instigator.Velocity - Other.Velocity;
	Dmg += Dmg * (VSize(RelativeVelocity) / RunningSpeedThresh) * (Normal(RelativeVelocity) Dot Normal(Other.Location-Instigator.Location));

	if (Pawn(Victim) != None)
	{
		ForceDir = Normal(Other.Location-TraceStart);
		ForceDir.Z *= 0.3;

		Pawn(Victim).AddVelocity( Normal(Victim.Acceleration) * HookStopFactor * -FMin(Pawn(Victim).GroundSpeed, VSize(Victim.Velocity)) - ForceDir * HookPullForce );

		if (Pawn(Victim).Health > 0)
		{
									   
														   
	   
									

			OldHealth = Pawn(Victim).Health;
		}
	
									  
														 
		
																											  
	
	 
		if (xPawn(Victim) != None && Pawn(Victim).health > 0)
			bWasAlive=true;
		else if (Vehicle(Victim) != None && Vehicle(Victim).Driver!=None && Vehicle(Victim).Driver.Health > 0)
			bWasAlive = true;
	}

								   
			 

	class'BallisticDamageType'.static.GenericHurt (Victim, Dmg, Instigator, HitLocation, KickForce * Dir, HitDT);
			   
  
															  
   
									 
														
	   
																											 
   
							   
																					 
  
											 
																					  

	if (Pawn(Other) != None && Pawn(Other).Health > 0)
	{
		HookedVictim = Pawn(Other);
		HookTime = level.TimeSeconds;
	}
	JohnsonRifle(Weapon).bLatchedOn=true;

	GetAxes(rotator(Other.Location-TraceStart), X, Y, Z);
	Instigator.AddVelocity(X*100 + Y*(2*FRand()-1)*80 + Z*150*FRand());
}


defaultproperties
{
     bModeExclusive=True
     SawFreeLoop=Sound'BWBP4-Sounds.DarkStar.Dark-Saw'
     SawHackLoop=Sound'BWBP4-Sounds.DarkStar.Dark-SawPitched'
     SawStop=Sound'BWBP4-Sounds.DarkStar.Dark-SawClose'
     SwipePoints(0)=(offset=(Pitch=1000,Yaw=3000))
     SwipePoints(1)=(offset=(Pitch=500,Yaw=2000))
     SwipePoints(2)=(offset=(Pitch=-500,Yaw=1000))
     SwipePoints(3)=(Weight=7)
     SwipePoints(4)=(offset=(Pitch=-500,Yaw=-1000))
     SwipePoints(5)=(offset=(Pitch=500,Yaw=-2000))
     SwipePoints(6)=(offset=(Pitch=1000,Yaw=-3000))
     WallHitPoint=2
     TraceRange=(Min=200.000000,Max=200.000000)
     Damage=(Min=5.000000,Max=18.000000)
     DamageHead=(Min=15.000000,Max=38.000000)
     DamageLimb=(Min=3.000000,Max=12.000000)
     DamageType=Class'BWBP_SKC_Fix.DTBulldog'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTBulldogHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTBulldog'
     KickForce=100
     HookStopFactor=1.250000
     HookPullForce=100.000000
     bUseWeaponMag=False
     bIgnoreReload=True
     ScopeDownOn=SDO_Fire
     BallisticFireSound=(Sound=Sound'BWBP4-Sounds.DarkStar.Dark-SawOpen',Volume=0.750000,Radius=32.000000)
				   
     PreFireAnim=
     FireAnim="SawAttack"
     FireEndAnim="SawAttackEnd"
     FireRate=0.100000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_75BOLT'
     AmmoPerFire=0
     ShakeRotMag=(X=64.000000,Y=16.000000)
     ShakeRotRate=(X=1024.000000,Y=1024.000000,Z=512.000000)
     ShakeRotTime=1.000000
     WarnTargetPct=0.050000
}

