//=============================================================================
// HMCPrimaryFire
//
// Plasma Charge Laser Thing
// Hold to charge. It fires once charged fully. If you let go before full -
// gun wont fire and will go into cooldown.
//
// Again.
//
// Original Code by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
// Modified by Kaboodles, Xavious and then Sergeant Kelly and then Azarael
//=============================================================================
class HMCPrimaryFire extends BallisticInstantFire;

var   float RailPower;
//var   float PowerDown;
var   float ChargeRate;
var   float PowerLevel;
var   int SoundAdjust;
var   float MaxCharge;
var   sound	ChargeSound;
var() sound		LowFireSound;
var() sound		PowerFireSound;
var() sound		RTeamFireSound;

simulated function bool AllowFire()
{
    if (HMCBeamCannon(BW).Heat > 0 || HMCBeamCannon(Weapon).bLaserOn)
        return false;
    return super.AllowFire();
}


simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	
	if (Instigator.Role < Role_Authority) return;

	if ( (Instigator.PlayerReplicationInfo.Team != None) && (Instigator.PlayerReplicationInfo.Team.TeamIndex == 0) || HMCBeamCannon(BW).bRedTeam )
	{
		BallisticFireSound.Sound=RTeamFireSound;
     		MuzzleFlashClass=Class'BWBP_SKC_Fix.A48FlashEmitter';
	}
}

simulated event ModeHoldFire()
{
	Super.ModeHoldFire();
	
	if(HoldTime == 0)
		Instigator.AmbientSound = ChargeSound;
}

function StopFiring()
{
    Instigator.AmbientSound = Instigator.default.AmbientSound;
    HoldTime = 0;
}	

simulated event ModeDoFire()
{
    if (!AllowFire())
        return;

    //MaxCharge = PowerLevel;

    //log("ModeDoFire: RailPower = "$RailPower$", HoldTime = "$HoldTime$" PowerLevel = "$PowerLevel$" bFireOnRelease: "$bFireOnRelease);

    if (RailPower + 0.01 >= PowerLevel && !HMCBeamCannon(BW).bRunOffsetting)
    {
        RecoilPerShot = default.RecoilPerShot/* * 0.2 + default.RecoilPerShot * 0.8*/ * RailPower;
        MaxWallSize = default.MaxWallSize/*  * 0.2 + default.MaxWallSize * 0.8 */ * RailPower;
    	KickForce = default.KickForce/*  * 0.2 + default.KickForce * 0.8*/ * RailPower;
        PenetrateForce = default.PenetrateForce * RailPower;
        VelocityRecoil = default.VelocityRecoil * RailPower;
        BW.RecoilDeclineTime = BW.default.RecoilDeclineTime/* * 0.2 + BW.default.RecoilDeclineTime * 0.8*/ * RailPower;
        //BallisticFireSound=(Sound=Sound'BallisticSounds3.M75.M75Fire',Volume=(0.88+RailPower*0.6),Radius=(350.0+RailPower*350.0));
        BallisticFireSound.Volume=0.7+RailPower*0.8;
        BallisticFireSound.Radius=(280.0+RailPower*350.0);
        super.ModeDoFire();

        //log("Fire Success: RailPower = "$RailPower$", HoldTime = "$HoldTime$" PowerLevel = "$PowerLevel);
        HMCBeamCannon(BW).CoolRate = HMCBeamCannon(BW).default.CoolRate;
    }
    else
    {
        //log("Fire Failure: RailPower = "$RailPower$", HoldTime = "$HoldTime$" PowerLevel = "$PowerLevel);

        HMCBeamCannon(BW).CoolRate = HMCBeamCannon(BW).default.CoolRate * 3;
    }

    HMCBeamCannon(BW).Heat += RailPower;
    RailPower = 0;
}

function float GetDamage (Actor Other, vector HitLocation, vector Dir, out Actor Victim, optional out class<DamageType> DT)
{
	return super.GetDamage (Other, HitLocation, Dir, Victim, DT) * RailPower;
}

simulated function ModeTick(float DT)
{
	Super.ModeTick(DT);

	if (HMCBeamCannon(BW).Heat > 0 || !bIsFiring || HMCBeamCannon(BW).bLaserOn)
		return;

        MaxCharge = RailPower;

	RailPower = FMin(RailPower + ChargeRate*DT, PowerLevel);

    if (RailPower >= PowerLevel)// && PowerLevel > 0.2)
    {
        Weapon.StopFire(ThisModeNum);
    }
}

// Do the trace to find out where bullet really goes
function DoTrace (Vector InitialStart, Rotator Dir)
{
	local int						PenCount, WallCount;
	local Vector					End, X, HitLocation, HitNormal, Start, WaterHitLoc, LastHitLoc, ExitNormal;
	local Material					HitMaterial, ExitMaterial;
	local float						Dist;
	local Actor						Other, LastOther;
	local bool						bHitWall;

	// Work out the range
	Dist = TraceRange.Min + FRand() * (TraceRange.Max - TraceRange.Min);

	Start = InitialStart;
	X = Normal(Vector(Dir));
	End = Start + X * Dist;
	LastHitLoc = End;
	Weapon.bTraceWater=true;

	while (Dist > 0)		// Loop traces in case we need to go through stuff
	{
		// Do the trace
		Other = Trace (HitLocation, HitNormal, End, Start, true, , HitMaterial);
		Weapon.bTraceWater=false;
		Dist -= VSize(HitLocation - Start);
		if (Level.NetMode == NM_Client && (Other.Role != Role_Authority || Other.bWorldGeometry))
			break;
		if (Other != None)
		{
			// Water
			if ( (FluidSurfaceInfo(Other) != None) || ((PhysicsVolume(Other) != None) && PhysicsVolume(Other).bWaterVolume) )
			{
				if (VSize(HitLocation - Start) > 1)
					WaterHitLoc=HitLocation;
				Start = HitLocation;
				Dist *= WaterRangeFactor;
				End = Start + X * Dist;
				Weapon.bTraceWater=false;
				continue;
			}
				LastHitLoc = HitLocation;
			// Got something interesting
			if (!Other.bWorldGeometry && Other != LastOther)
			{
				DoDamage(Other, HitLocation, InitialStart, X, PenCount, WallCount, WaterHitLoc);
				LastOther = Other;
				if (PowerLevel > 0.500000)
					HMCBeamCannon(Weapon).HMCTargetedHurtRadius(60, 128, class'DTHMCBlast', 0, HitLocation, Pawn(Other));
				HMCBeamCannon(Weapon).HMCTargetedHurtRadius(30, 512, class'DTHMCBlast', 0, HitLocation, Pawn(Other));


				if (CanPenetrate(Other, HitLocation, X, PenCount))
				{
					PenCount++;
					Start = HitLocation + (X * Other.CollisionRadius * 2);
					End = Start + X * Dist;
					Weapon.bTraceWater=true;
					if (Vehicle(Other) != None)
						HitVehicleEffect (HitLocation, HitNormal, Other);
					continue;
				}
				else if (Vehicle(Other) != None)
					bHitWall = ImpactEffect (HitLocation, HitNormal, HitMaterial, Other, WaterHitLoc);
				else if (Mover(Other) == None)
					break;
			}
			// Do impact effect
			if (Other.bWorldGeometry || Mover(Other) != None)
			{
				WallCount++;
				if (WallCount <= MaxWalls && MaxWallSize > 0 && GoThroughWall(Other, HitLocation, HitNormal, MaxWallSize * ScaleBySurface(Other, HitMaterial), X, Start, ExitNormal, ExitMaterial))
				{
					WallPenetrateEffect(Other, HitLocation, HitNormal, HitMaterial);
					WallPenetrateEffect(Other, Start, ExitNormal, ExitMaterial, true);
					Weapon.bTraceWater=true;
					continue;
				}
				bHitWall = ImpactEffect (HitLocation, HitNormal, HitMaterial, Other, WaterHitLoc);
				if (PowerLevel > 0.500000)
					Weapon.HurtRadius(60, 128, class'DTHMCBlast', 0, HitLocation);
				Weapon.HurtRadius(30, 512, class'DTHMCBlast', 0, HitLocation);
				break;
			}
			// Still in the same guy
			if (Other == Instigator || Other == LastOther)
			{
				Start = HitLocation + (X * FMax(32, Other.CollisionRadius * 2));
				End = Start + X * Dist;
				Weapon.bTraceWater=true;
				continue;
			}
			break;
		}
		else
		{
			LastHitLoc = End;
			break;
		}
	}
	// Never hit a wall, so just tell the attachment to spawn muzzle flashes and play anims, etc
	if (!bHitWall)
		NoHitEffect(X, InitialStart, LastHitLoc, WaterHitLoc);
}

/*
function DoDamage (Actor Other, vector HitLocation, vector TraceStart, vector Dir, int PenetrateCount, int WallCount, optional vector WaterHitLocation)
{
	super.DoDamage(Other, HitLocation, TraceStart, Dir, PenetrateCount, WallCount, WaterHitLocation);
	if (Mover(Other) != None || Vehicle(Other) != None)
		return;

}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	Weapon.HurtRadius(2, 64, DamageType, 1, HitLocation);
	HMCBeamCannon(Weapon).HMCTargetedHurtRadius(60, 128, class'DTHMCBlast', 0, HitLocation, Pawn(Other));
	HMCBeamCannon(Weapon).HMCTargetedHurtRadius(30, 512, class'DTHMCBlast', 0, HitLocation, Pawn(Other));
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}*/

simulated function SwitchHMCMode (byte NewMode)
{
        if (NewMode == 0)
        {
            	AmmoPerFire=3;
		PowerLevel=0.300000;
		RecoilPerShot=256.000000;
     		VelocityRecoil=100.000000;
      	BallisticFireSound.Sound=LowFireSound;
        }

        else if (NewMode == 1)
        {
            	AmmoPerFire=10;
		PowerLevel=1.000000;
     		RecoilPerShot=768.000000;
     		VelocityRecoil=400.000000;
      		BallisticFireSound.Sound=PowerFireSound;
        }
        else
        {
            	AmmoPerFire=3;
		PowerLevel=0.300000;
		RecoilPerShot=256.000000;
     		VelocityRecoil=100.000000;
    		BallisticFireSound.Sound=LowFireSound;
        }

        Load=AmmoPerFire;
}

defaultproperties
{
     ChargeRate=0.400000
     PowerLevel=1.000000
//     ChargeSound=Sound'BWBP_SKC_Sounds.Glock_Gold.G-Glk-LaserFire'
     ChargeSound=Sound'BWBP_SKC_Sounds.BeamCannon.Beam-Charge'

     LowFireSound=Sound'BWBP_SKC_Sounds.BeamCannon.Beam-FireLow'
     PowerFireSound=Sound'BWBP_SKC_Sounds.BeamCannon.Beam-Fire'
     RTeamFireSound=Sound'BWBP_SKC_Sounds.BeamCannon.RedBeam-Fire'
     TraceRange=(Min=50000.000000,Max=50000.000000)
     WaterRangeFactor=0.600000
     MaxWalls=4
     Damage=240
     DamageHead=280
     DamageLimb=200
     RangeAtten=0.750000
     WaterRangeAtten=0.600000
     DamageType=Class'BWBP_SKC_Fix.DTHMCBlast'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTHMCBlastHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTHMCBlast'
     HookStopFactor=2.500000
     PenetrateForce=400
     bPenetrate=True
     MuzzleFlashClass=Class'BWBP_SKC_Fix.HMCFlashEmitter'
     RecoilPerShot=768.000000
     VelocityRecoil=400.000000
     FireChaos=0.005000
     BallisticFireSound=(Sound=SoundGroup'BWBP_SKC_Sounds.BeamCannon.HMC-Blast',Volume=1.700000,Radius=650.000000,Slot=SLOT_Interact,bNoOverride=False)
     bFireOnRelease=True
     bWaitForRelease=True
     bModeExclusive=False
     FireAnim="FireLoop"
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.080000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_HVPCCells'
     AmmoPerFire=10
     BotRefireRate=0.999000
     WarnTargetPct=0.010000
     aimerror=400.000000
}
