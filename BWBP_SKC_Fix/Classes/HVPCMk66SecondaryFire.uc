//=============================================================================
// BFG Secondary fire.
//
// Rapid fire projectiles. Generate enough heat to det gun under 50 charges.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class HVPCMk66SecondaryFire extends BallisticProjectileFire;

simulated function bool AllowFire()
{
	if ((HVPCMk66PlasmaCannon(Weapon).HeatLevel >= 10.50) || HVPCMk66PlasmaCannon(Weapon).bIsVenting || !super.AllowFire())
		return false;
	return true;
}

function PlayFiring()
{
	HVPCmk66PlasmaCannon(BW).AddHeat(0.50);
	if (Instigator == None || Weapon == None || Instigator.Health < 1)
		return;
	Super.PlayFiring();
}

function DoFireEffect()
{
	if (level.Netmode == NM_DedicatedServer)
		HVPCMk66PlasmaCannon(BW).AddHeat(0.50);
	if (Instigator == None || Weapon == None || Instigator.Health < 1)
		return;
	Super.DoFireEffect();
}

defaultproperties
{
     SpawnOffset=(X=10.000000,Y=10.000000,Z=-9.000000)
     MuzzleFlashClass=Class'BallisticFix.RSNovaFastMuzzleFlash'
     RecoilPerShot=100.000000
     FireChaos=0.050000
     XInaccuracy=2.000000
     YInaccuracy=2.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.BFG.BFG-SmallFire',Volume=2.000000,Slot=SLOT_Interact,bNoOverride=False)
     FireAnim="Fire2"
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.110000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_HVPCCells'
     AmmoPerFire=2
     ShakeRotMag=(X=16.000000,Y=4.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=1.500000
     ShakeOffsetMag=(X=-4.000000)
     ShakeOffsetRate=(X=-1200.000000)
     ShakeOffsetTime=1.500000
     ProjectileClass=Class'BWBP_SKC_Fix.HVPCMk66ProjectileSmall'
     WarnTargetPct=0.200000
}
