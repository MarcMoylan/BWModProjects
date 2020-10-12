//=============================================================================
// LS440PrimaryFire.
//
// Full auto lasers.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class LS440PrimaryFire extends BallisticInstantFire;


var() Actor						MuzzleFlash2;		// The muzzleflash actor
var   bool			bSecondBarrel;

function InitEffects()
{
	super.InitEffects();
    if ((MuzzleFlashClass != None) && ((MuzzleFlash2 == None) || MuzzleFlash2.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlash2, MuzzleFlashClass, Weapon.DrawScale*FlashScaleFactor, weapon, 'tip2');
}

event ModeDoFire()
{

	if (AllowFire())
	{
			if (!bSecondBarrel)
			{
				bSecondBarrel=true;
				LS440Instagib(Weapon).bBarrelsOnline=true;
			}
			else
			{
				bSecondBarrel=false;
				LS440Instagib(Weapon).bBarrelsOnline=false;
			}
		super.ModeDoFire();	
	}

}




//Trigger muzzleflash emitter
function FlashMuzzleFlash()
{
	local Coords C;
	local vector Start, X, Y, Z;

    	if ((Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
	if (!Instigator.IsFirstPerson() || PlayerController(Instigator.Controller).ViewTarget != Instigator)
		return;

    	if (bSecondBarrel && MuzzleFlash2 != None) //Checks to alternate
    	{
		C = Weapon.GetBoneCoords('tip2');
        	MuzzleFlash2.Trigger(Weapon, Instigator);
    	}
    	else if (MuzzleFlash != None)
    	{
		C = Weapon.GetBoneCoords('tip');
        	MuzzleFlash.Trigger(Weapon, Instigator);
    	}

    	if (!class'BallisticMod'.default.bMuzzleSmoke)
    		return;
    	Weapon.GetViewAxes(X,Y,Z);
	Start = C.Origin + X * -180 + Y * 3;
}


function DoDamage (Actor Other, vector HitLocation, vector TraceStart, vector Dir, int PenetrateCount, int WallCount, optional vector WaterHitLocation)
{
	super.DoDamage(Other, HitLocation, TraceStart, Dir, PenetrateCount, WallCount, WaterHitLocation);
	if (Mover(Other) != None || Vehicle(Other) != None)
		return;
	LS440Instagib(BW).TargetedHurtRadius(10, 32, class'DTLS440Body', 0, HitLocation, Pawn(Other));
}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	Weapon.HurtRadius(10, 32, DamageType, 0, HitLocation);
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}



defaultproperties
{
     TraceRange=(Min=1500000.000000,Max=1500000.000000)
     MaxWallSize=64.000000
     MaxWalls=3
     Damage=45
     DamageHead=100
     DamageLimb=35
     DamageType=Class'BWBP_SKC_Fix.DTLS440Body'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTLS440Head'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTLS440Body'
     KickForce=25000
     PenetrateForce=500
     bPenetrate=True
     ClipFinishSound=(Sound=Sound'BWBP_SKC_Sounds.LS14.Gauss-LastShot',Volume=1.000000,Radius=48.000000,bAtten=True)
     MuzzleFlashClass=Class'BWBP_SKC_Fix.A48FlashEmitter'
//     MuzzleFlashClass=Class'BWBP_SKC_Fix.GRSXXLaserFlashEmitter'
//     MuzzleFlashClass=Class'BWBP_SKC_Fix.VSKSilencedFlash'
     FlashScaleFactor=0.400000
     RecoilPerShot=20.000000
     BallisticFireSound=(Sound=SoundGroup'BWBP_SKC_Sounds.LS14.Gauss-Fire',Volume=0.900000)
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.150000
	AmmoPerFire=2
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_HVPCCells'
     ShakeRotMag=(X=200.000000,Y=16.000000)
     ShakeRotRate=(X=5000.000000,Y=5000.000000,Z=5000.000000)
     ShakeRotTime=1.000000
     ShakeOffsetMag=(X=-2.500000)
     ShakeOffsetRate=(X=-500.000000)
     ShakeOffsetTime=1.000000
     BotRefireRate=1.050000
     WarnTargetPct=0.050000
     aimerror=800.000000
}
