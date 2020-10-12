//=============================================================================
// PS9mPrimaryFire.
//
// Automatic tranq fire. Rapid fire and hard to control.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class PS9mPrimaryFire extends BallisticInstantFire;

simulated event ModeDoFire()
{
	if (PS9mPistol(Weapon).bLoaded)
	{
		return;
	}
	if (!AllowFire())
		return;
		
	super.ModeDoFire();
    

}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	if (PS9mPistol(Weapon).CamoIndex == 4)
		Weapon.HurtRadius(5, 96, DamageType, 1, HitLocation);
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}

function bool DoTazerBlurEffect(Actor Victim)
{
	local int i;
	local MRS138ViewMesser VM;

	if (Pawn(Victim) == None || Pawn(Victim).Health < 1 || Pawn(Victim).LastPainTime != Victim.level.TimeSeconds)
		return false;
	if (PlayerController(Pawn(Victim).Controller) != None)
	{
		for (i=0;i<Pawn(Victim).Controller.Attached.length;i++)
			if (MRS138ViewMesser(Pawn(Victim).Controller.Attached[i]) != None)
			{
				MRS138ViewMesser(Pawn(Victim).Controller.Attached[i]).AddImpulse();
				i=-1;
				break;
			}
		if (i != -1)
		{
			VM = Spawn(class'MRS138ViewMesser',Pawn(Victim).Controller);
			VM.SetBase(Pawn(Victim).Controller);
			VM.AddImpulse();
		}
	}
	else if (AIController(Pawn(Victim).Controller) != None)
	{
		AIController(Pawn(Victim).Controller).Startle(Weapon.Instigator);
		class'BC_BotStoopidizer'.static.DoBotStun(AIController(Pawn(Victim).Controller), 2, 5);
	}
	return false;
}

function DoDamage (Actor Other, vector HitLocation, vector TraceStart, vector Dir, int PenetrateCount, int WallCount, optional vector WaterHitLocation)
{
	super.DoDamage (Other, HitLocation, TraceStart, Dir, PenetrateCount, WallCount);
	if ( Other.bCanBeDamaged && PS9mPistol(Weapon).CamoIndex != 4)
	{
		DoTazerBlurEffect(Other);
	}
}

defaultproperties
{
     aimerror=900.000000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_TranqP'
     bAISilent=True
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.Stealth.Stealth-Fire',Volume=1.100000,Slot=SLOT_Interact,bNoOverride=False)
     bCockAfterEmpty=False
     bDryUncock=False
     bPenetrate=False
     BrassBone="ejector"
     BrassClass=Class'BWBP_SKC_Fix.Brass_Tranq'
     BrassOffset=(X=-20.000000,Y=1.000000)
     Damage=15
     DamageHead=60
     DamageLimb=12
     DamageType=Class'BWBP_SKC_Fix.DT_PS9MDart'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_PS9MDart'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_PS9MDartHead'
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     FireEndAnim=
     FireRate=0.100000
     FlashScaleFactor=0.800000
     KickForce=20000
     MaxWalls=1
     MaxWallSize=1.000000
     MuzzleFlashClass=Class'BWBP_SKC_Fix.VSKSilencedFlash'
     PenetrateForce=150
     RecoilPerShot=172.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     TraceRange=(Min=3000.000000,Max=5000.000000)
     TweenTime=0.000000
     WarnTargetPct=0.200000
     XInaccuracy=24.50000
     YInaccuracy=24.50000
}
