//=============================================================================
// DragonsToothPrimaryFire.
//
// Horizontalish swipe attack for the EKS43. Uses melee swpie system to do
// horizontal swipes. When the swipe traces find a player, the trace closest to
// the aim will be used to do the damage.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DragonsToothPrimaryFire extends BallisticMeleeFire;

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
     SliceAnims(0)="Swing1"
     SliceAnims(1)="Swing2"
     SliceAnims(2)="Swing3"
     Damage=125
     DamageHead=250
     DamageLimb=75
     DamageType=Class'BWBP_SKC_Fix.DT_DTSChest'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_DTSHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_DTSLimb'
     KickForce=100
     HookStopFactor=1.200000
     HookPullForce=80.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.DTS.DragonsTooth-Swipe',Volume=4.100000,Radius=32.000000,bAtten=True)
     bAISilent=True
     FireAnim="Slash1"
     FireAnimRate=0.850000
     FireRate=1.100000
     AmmoClass=Class'BallisticFix.Ammo_Knife'
     AmmoPerFire=0
     ShakeRotMag=(X=64.000000,Y=256.000000)
     ShakeRotRate=(X=3000.000000,Y=3000.000000,Z=3000.000000)
     ShakeRotTime=2.000000
     BotRefireRate=0.800000
     WarnTargetPct=0.100000
}
