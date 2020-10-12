//=============================================================================
// EKS43SecondaryFire.
//
// Vertical/Diagonal held swipe for the EKS43. Uses swipe system and is prone
// to headshots because the highest trace that hits an enemy will be used to do
// the damage and check hit area.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class NEXSecondaryFire extends BallisticMeleeFire;

var() Sound	ChargeSound;

var   float	ChargePower;

// To do:
// Make it stop the animation immediately after releasing fire.
// Make it drain ammo properly.

simulated function PlayPreFire()
{
	BW.SafeLoopAnim('Charge', 1.0, TweenTime, ,"IDLE");
}

function PlayFiring()
{
	BW.SafePlayAnim(FireAnim, FireAnimRate, TweenTime, ,"FIRE");
    ClientPlayForceFeedback(FireForce);  // jdf
    FireCount++;
	if (!NEXPlasEdge(Weapon).bPoweredDown && NEXPlasEdge(Weapon).HeatLevel >= 6.0 && NEXPlasEdge(Weapon).HeatLevel < 9.5)
		NEXPlasEdge(Weapon).PlaySound(NEXPlasEdge(Weapon).HighHeatSound,,1.0,,32);

	if (BallisticFireSound.Sound != None)
		Weapon.PlayOwnedSound(BallisticFireSound.Sound,BallisticFireSound.Slot,BallisticFireSound.Volume,BallisticFireSound.bNoOverride,BallisticFireSound.Radius,BallisticFireSound.Pitch,BallisticFireSound.bAtten);
}

simulated function bool AllowFire()
{
	if ((NEXPlasEdge(Weapon).HeatLevel >= 9.5) || NEXPlasEdge(Weapon).bPoweredDown || !super.AllowFire())
		return false;
	return true;
}

simulated event ModeTick(float DT)
{
	super.ModeTick(DT);
	if (!bIsFiring)
		return;
	if (Instigator.PhysicsVolume.bWaterVolume)
		NEXPlasEdge(Weapon).AddHeat(DT*3);
	else if (NEXPlasEdge(Weapon).HeatLevel >= 11.50)
		return;
	else
		NEXPlasEdge(Weapon).AddHeat(DT*(3.50+FRand()));

	if (NEXPlasEdge(Weapon).HeatLevel >= 10)
	{
		NEXPlasEdge(Weapon).HeatLevel = 10;
		Weapon.StopFire(ThisModeNum);
	}
}

simulated function ModeHoldFire()
{
	Instigator.AmbientSound = ChargeSound;
	Instigator.SoundVolume = 255;
	Instigator.SoundPitch = 56;
	GotoState('Charging');
	Super.ModeHoldFire();
}

simulated state Charging
{
	function BeginState()
	{
		SetTimer(0.1,true);
		Timer();
	}
	event Timer()
	{
	}
	function EndState()
	{
		SetTimer(0.0,false);
	}
}

defaultproperties
{
     SwipePoints(0)=(offset=(Pitch=0,Yaw=3000))
     SwipePoints(1)=(offset=(Pitch=0,Yaw=1500))
     SwipePoints(2)=(offset=(Pitch=0,Yaw=0))
     SwipePoints(3)=(Weight=4,offset=(Yaw=-1500))
     SwipePoints(4)=(Weight=2,offset=(Pitch=0,Yaw=3000))
     WallHitPoint=1
     NumSwipePoints=5
     Damage=50
     DamageHead=85
     DamageLimb=40
     DamageType=Class'BWBP_SKC_Fix.DTNEXSlash'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTNEXSlashHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTNEXSlashLimb'
     KickForce=100
     HookStopFactor=1.700000
     HookPullForce=100.000000
     bReleaseFireOnDie=False
     bAISilent=True
     bFireOnRelease=True
     PreFireAnim="PrepCharge"
     FireAnim="Slash"
     FireAnimRate=0.8
     FireRate=1.800000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_NEXCells'
     AmmoPerFire=0
     ShakeRotMag=(X=64.000000,Y=512.000000)
     ShakeRotRate=(X=3000.000000,Y=3000.000000,Z=3000.000000)
     ShakeRotTime=2.500000
     BotRefireRate=0.800000
     WarnTargetPct=0.050000
}
