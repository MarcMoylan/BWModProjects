//=============================================================================
// MRDRsecondaryFire.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class MRDRsecondaryFire extends BallisticMeleeFire;

var() Array<name> SliceAnims;
var int SliceAnim;

function ServerPlayFiring()
{
	BW.SafePlayAnim(FireAnim, FireAnimRate, TweenTime, ,"FIRE");
}

//Do the spread on the client side
function PlayFiring()
{
	if (ScopeDownOn == SDO_Fire)
		BW.TemporaryScopeDown(0.5, 0.9);
	// Slightly modified Code from original PlayFiring()
/*    if (FireCount > 0)
    {
        if (Weapon.HasAnim(FireLoopAnim))
            BW.SafePlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0, ,"FIRE");
        else
            BW.SafePlayAnim(FireAnim, FireAnimRate, TweenTime, ,"FIRE");
    }
    else
*/        BW.SafePlayAnim(FireAnim, FireAnimRate, TweenTime, ,"FIRE");
    ClientPlayForceFeedback(FireForce);  // jdf
    FireCount++;
	// End code from normal PlayFiring()
}

function NotifiedDoFireEffect()
{
	Super.DoFireEffect();
}

function DoFireEffect()
{
}

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
     SliceAnims(0)="Melee1"
     SliceAnims(1)="Melee2"
     SwipePoints(0)=(offset=(Pitch=2000,Yaw=4000))
     SwipePoints(1)=(offset=(Pitch=1000,Yaw=2000))
     SwipePoints(2)=(offset=(Pitch=0,Yaw=0))
     SwipePoints(3)=(Weight=4,offset=(Pitch=1000,Yaw=-2000))
     SwipePoints(4)=(Weight=2,offset=(Pitch=2000,Yaw=-4000))
     SwipePoints(5)=(Weight=-1,offset=(Pitch=0,Yaw=0))
     SwipePoints(6)=(Weight=-1,offset=(Pitch=0,Yaw=0))
     WallHitPoint=1
     TraceRange=(Min=96.000000,Max=96.000000)
     Damage=35
     DamageHead=85
     DamageLimb=25
     DamageType=Class'BWBP_SKC_Fix.DT_MRDR88Spike'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_MRDR88SpikeHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_MRDR88Spike'
     HookStopFactor=1.700000
     HookPullForce=100.000000
     bUseWeaponMag=False
     bIgnoreReload=True
     BallisticFireSound=(Sound=Sound'BallisticSounds3.M763.M763Swing',Radius=32.000000,bAtten=True)
     bAISilent=True
     FireAnim="Melee1"
     AmmoClass=Class'BallisticFix.Ammo_9mm'
     AmmoPerFire=0
     ShakeRotMag=(X=64.000000,Y=128.000000)
     ShakeRotRate=(X=2500.000000,Y=2500.000000,Z=2500.000000)
     ShakeRotTime=2.500000
     BotRefireRate=0.800000
     WarnTargetPct=0.100000
}
