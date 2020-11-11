//=============================================================================
// X8PrimaryFire.
//
// Rapid swinging of the knife. Effective in an insane melee.
//
// by Logan "BlackEagle" Richert.
// uses code by Nolan "Dark Carnivour" Richert.
// Copyright© 2011 RuneStorm. All Rights Reserved.
//=============================================================================
class X8PrimaryFire extends BallisticMeleeFire;

var() Array<name> SliceAnims;
var int SliceAnim;

simulated event ModeDoFire()
{
	FireAnim = SliceAnims[SliceAnim];
	SliceAnim++;
	if (SliceAnim >= SliceAnims.Length)
		SliceAnim = 0;

	Super.ModeDoFire();
}

simulated function bool HasAmmo()
{
	return true;
}

defaultproperties
{
     SliceAnims(0)="Slash1"
     SliceAnims(1)="Slash2"
     SliceAnims(2)="Slash3"
     SwipePoints(0)=(offset=(Pitch=2000,Yaw=4000))
     SwipePoints(1)=(offset=(Pitch=1000,Yaw=2000))
     SwipePoints(2)=(offset=(Pitch=0,Yaw=0))
     SwipePoints(3)=(Weight=4,offset=(Pitch=1000,Yaw=-2000))
     SwipePoints(4)=(Weight=2,offset=(Pitch=2000,Yaw=-4000))
     SwipePoints(5)=(Weight=-1,offset=(Pitch=0,Yaw=0))
     SwipePoints(6)=(Weight=-1,offset=(Pitch=0,Yaw=0))
     WallHitPoint=2
     TraceRange=(Min=96.000000,Max=96.000000)
     Damage=30
     DamageHead=80
     DamageLimb=15
     DamageType=Class'BWBP_SKC_Fix.DTX8Knife'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTX8Knife'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTX8Knife'
     KickForce=100
     HookStopFactor=1.300000
     HookPullForce=100.000000
     BallisticFireSound=(Sound=SoundGroup'BallisticSounds_25.X4.X4_Melee',Radius=32.000000,bAtten=True)
     bAISilent=True
     FireAnim="Slash1"
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_X8Knife'
     AmmoPerFire=0
     ShakeRotMag=(X=64.000000,Y=128.000000)
     ShakeRotRate=(X=2500.000000,Y=2500.000000,Z=2500.000000)
     ShakeRotTime=2.500000
     BotRefireRate=0.800000
     WarnTargetPct=0.100000
}
