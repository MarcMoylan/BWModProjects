//=============================================================================
// Elite Skrith Rifle
//
// Handed to the best of the best.
// 
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class A73BSkrithRifle extends BallisticWeapon;

var Actor GlowFX;
var float		lastModeChangeTime;



replication
{
	reliable if (Role == ROLE_Authority)
		ClientSwitchCannonMode;

}

static function class<Pickup> RecommendAmmoPickup(int Mode)
{
	return class'AP_A73BClip';
}

exec simulated function CockGun(optional byte Type);
function ServerCockGun(optional byte Type);

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);
	SoundPitch = 45;

	GunLength = default.GunLength;

    if (Instigator.IsLocallyControlled() && level.DetailMode == DM_SuperHigh && class'BallisticMod'.default.EffectsDetailMode >= 2 && (GlowFX == None || GlowFX.bDeleteMe))
		class'BUtil'.static.InitMuzzleFlash (GlowFX, class'A73BGlowFX', DrawScale, self, 'tip');
}

simulated event Timer()
{
	if (Clientstate == WS_PutDown)
		class'BUtil'.static.KillEmitterEffect (GlowFX);
	super.Timer();
}

simulated event Destroyed()
{
	if (GlowFX != None)
		GlowFX.Destroy();
	super.Destroyed();
}

// Animation notify for when the clip is stuck in
simulated function Notify_ClipIn()
{
	local int AmmoNeeded;

	ReloadState = RS_PostClipIn;
	PlayOwnedSound(ClipInSound.Sound,ClipInSound.Slot,ClipInSound.Volume,ClipInSound.bNoOverride,ClipInSound.Radius,ClipInSound.Pitch,ClipInSound.bAtten);
	if (Level.NetMode != NM_Client)
	{
		AmmoNeeded = default.MagAmmo+(-0 + Rand(0)) - MagAmmo;
		if (AmmoNeeded > Ammo[0].AmmoAmount)
			MagAmmo+=Ammo[0].AmmoAmount;
		else
			MagAmmo += AmmoNeeded;
		Ammo[0].UseAmmo (AmmoNeeded, True);
	}
}


simulated function float RateSelf()
{
	if (PlayerController(Instigator.Controller) != None && Ammo[0].AmmoAmount < 1 && MagAmmo < 1)
		CurrentRating = Super.RateSelf() * 0.2;
	else
		return Super.RateSelf();
	return CurrentRating;
}
// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;
	local float Dist;
	local Vector Dir;
	local Vehicle V;

	if (MagAmmo < 1)
		return 1;

	B = Bot(Instigator.Controller);
	if ( B == None  || B.Enemy == None)
		return Rand(2);

	Dir = Instigator.Location - B.Enemy.Location;
	Dist = VSize(Dir);

	if ( ( (DestroyableObjective(B.Squad.SquadObjective) != None && B.Squad.SquadObjective.TeamLink(B.GetTeamNum()))
		|| (B.Squad.SquadObjective == None && DestroyableObjective(B.Target) != None && B.Target.TeamLink(B.GetTeamNum())) )
	     && (B.Enemy == None || !B.EnemyVisible()) )
		return 0;
	if ( FocusOnLeader(B.Focus == B.Squad.SquadLeader.Pawn) )
		return 0;

	if (Dist > 300)
		return 0;

	V = B.Squad.GetLinkVehicle(B);
	if ( V == None )
		V = Vehicle(B.MoveTarget);
	if ( V == B.Target )
		return 0;
	if ( (V != None) && (V.Health < V.HealthMax) && (V.LinkHealMult > 0) && B.LineOfSightTo(V) )
		return 0;

	if (Dist < FireMode[1].MaxRange())
		return 1;
//	if (vector(B.Enemy.Rotation) dot Normal(Dir) < 0.0 && (VSize(B.Enemy.Velocity) < 100 || Normal(B.Enemy.Velocity) dot Normal(B.Velocity) < 0.5))
//		return 1;
//	if (FRand() > Dist/500)
//		return 1;
	return 0;
}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;
	local vector Dir;
	local DestroyableObjective O;
	local Vehicle V;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return AIRating;

	if (HasMagAmmo(0) || Ammo[0].AmmoAmount > 0)
	{
		V = B.Squad.GetLinkVehicle(B);
		if ( (V != None)
			&& (VSize(Instigator.Location - V.Location) < 1.5 * FireMode[0].MaxRange())
			&& (V.Health < V.HealthMax) && (V.LinkHealMult > 0) )
			return 1.2;

		if ( Vehicle(B.RouteGoal) != None && B.Enemy == None && VSize(Instigator.Location - B.RouteGoal.Location) < 1.5 * FireMode[0].MaxRange()
		     && Vehicle(B.RouteGoal).TeamLink(B.GetTeamNum()) )
			return 1.2;

		O = DestroyableObjective(B.Squad.SquadObjective);
		if ( O != None && B.Enemy == None && O.TeamLink(B.GetTeamNum()) && O.Health < O.DamageCapacity
	    	 && VSize(Instigator.Location - O.Location) < 1.1 * FireMode[0].MaxRange() && B.LineOfSightTo(O) )
			return 1.2;
	}

	if (B.Enemy == None)
		return Super.GetAIRating();

	Dir = B.Enemy.Location - Instigator.Location;
	Dist = VSize(Dir);

	Result = Super.GetAIRating();
	if (!HasMagAmmo(0) && Ammo[0].AmmoAmount < 1)
	{
		if (Dist > 400)
			return 0;
		return Result / (1+(Dist/400));
	}
	// Enemy too far away
	if (Dist > 1300)
		Result -= (Dist-1000) / 3000;
	if (Dist < 500)
		Result += 0.5;

	if (Result < 0.14)
	{
		if (CurrentWeaponMode != 0)
		{
			lastModeChangeTime = level.TimeSeconds;
			CurrentWeaponMode = 0;
			A73BPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
		}
	}
	else if (Result < 0.34 && MagAmmo > 10)
	{
		if (CurrentWeaponMode != 1)
		{
			lastModeChangeTime = level.TimeSeconds;
			CurrentWeaponMode = 1;
			A73BPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
		}
	}


	return Result;
}

function bool FocusOnLeader(bool bLeaderFiring)
{
	local Bot B;
	local Pawn LeaderPawn;
	local Actor Other;
	local vector HitLocation, HitNormal, StartTrace;
	local Vehicle V;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return false;
	if ( PlayerController(B.Squad.SquadLeader) != None )
		LeaderPawn = B.Squad.SquadLeader.Pawn;
	else
	{
		V = B.Squad.GetLinkVehicle(B);
		if ( V != None )
		{
			LeaderPawn = V;
			bLeaderFiring = (LeaderPawn.Health < LeaderPawn.HealthMax) && (V.LinkHealMult > 0)
							&& ((B.Enemy == None) || V.bKeyVehicle);
		}
	}
	if ( LeaderPawn == None )
	{
		LeaderPawn = B.Squad.SquadLeader.Pawn;
		if ( LeaderPawn == None )
			return false;
	}
	if (!bLeaderFiring)
		return false;
	if ( (Vehicle(LeaderPawn) != None) )
	{
		StartTrace = Instigator.Location + Instigator.EyePosition();
		if ( VSize(LeaderPawn.Location - StartTrace) < FireMode[0].MaxRange() )
		{
			Other = Trace(HitLocation, HitNormal, LeaderPawn.Location, StartTrace, true);
			if ( Other == LeaderPawn )
			{
				B.Focus = Other;
				return true;
			}
		}
	}

	return false;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	 if (!HasNonMagAmmo(0) && !HasMagAmmo(0)) return 1.2; return 0.5;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return -0.5;	}

function bool CanHeal(Actor Other)
{
	if (DestroyableObjective(Other) != None && DestroyableObjective(Other).LinkHealMult > 0)
		return true;
	if (Vehicle(Other) != None && Vehicle(Other).LinkHealMult > 0)
		return true;

	return false;
}
// End AI Stuff =====




function ServerSwitchWeaponMode (byte NewMode)
{
	if (CurrentWeaponMode > 0 && FireMode[0].IsFiring())
		return;
	super.ServerSwitchWeaponMode (newMode);
	if (!Instigator.IsLocallyControlled())
		A73BPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
	ClientSwitchCannonMode (CurrentWeaponMode);
}
simulated function ClientSwitchCannonMode (byte newMode)
{
	A73BPrimaryFire(FireMode[0]).SwitchCannonMode(newMode);
}

simulated function FirePressed(float F)
{
	if (bNeedReload && MagAmmo > 8)
		bNeedReload = false;
	super.FirePressed(F);
}


simulated event WeaponTick(float DT)
{
	super.WeaponTick(DT);

		if (CurrentWeaponMode == 0 && MagAmmo < 2)
			bNeedReload = true;
	
		else if (CurrentWeaponMode == 1 && MagAmmo < 8)
			bNeedReload = true;
	
//		if (CurrentWeaponMode == 2 && MagAmmo < 1)
//			bNeedReload = true;
	
		else
			bNeedReload = false;		
}

// Returns true if gun will need reloading after a certain amount of ammo is consumed. Subclass for special stuff
simulated function bool MayNeedReload(byte Mode, float Load)
{
	if (!bNoMag && BFireMode[1]!= None && BFireMode[1].bUseWeaponMag && (/*MagAmmo < 7 || */MagAmmo - Load < 8))
		return true;
	return bNeedReload;
//		return true;
//	return false;
}

defaultproperties
{
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     UsedAmbientSound=Sound'BallisticSounds2.A73.A73Hum1'
     BigIconMaterial=Texture'BWBP_SKC_Tex.A73b.BigIcon_A73E'
     BallisticInventoryGroup=5
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_RapidProj=True
     bWT_Energy=True
     SpecialInfo(0)=(Info="300.0;25.0;0.5;85.0;0.2;0.2;0.2")
     BringUpSound=(Sound=Sound'BallisticSounds2.A73.A73Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.A73.A73Putaway')
     ClipHitSound=(Sound=Sound'BallisticSounds2.A73.A73-ClipHit')
     ClipOutSound=(Sound=Sound'BallisticSounds2.A73.A73-ClipOut')
     ClipInSound=(Sound=Sound'BallisticSounds2.A73.A73-ClipIn')
     ClipInFrame=0.700000
     bNonCocking=True
     WeaponModes(0)=(ModeName="Plasma Charge",ModeID="WM_FullAuto")
     WeaponModes(1)=(ModeName="Plasma Bomb",ModeID="WM_FullAuto")
     WeaponModes(2)=(ModeName="ALaser",bUnavailable=True)
     WeaponModes(3)=(ModeName="BLaser",bUnavailable=True)
     WeaponModes(4)=(ModeName="CLaser",bUnavailable=True)
     CurrentWeaponMode=0
     SightPivot=(Pitch=768)
     SightOffset=(X=-12.000000,Z=14.300000)
     SightDisplayFOV=40.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.Misc7',Pic2=Texture'BallisticUI2.Crosshairs.Cross4',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=67,G=68,A=137),Color2=(B=96,G=185,A=208),StartSize1=133,StartSize2=47)
     CrosshairInfo=(SpreadRatios=(X1=0.250000,Y1=0.375000,Y2=0.500000),MaxScale=3.000000)
     CrouchAimFactor=0.600000
     SprintOffSet=(Pitch=-500,Yaw=-1024)
     JumpChaos=0.500000
     ViewAimFactor=0.350000
     ViewRecoilFactor=0.450000
     AimDamageThreshold=75.000000
     ChaosSpeedThreshold=600.000000
     ChaosAimSpread=(X=(Max=2048.000000),Y=(Min=-1536.000000,Max=1536.000000))
     RecoilXCurve=(Points=(,(InVal=0.100000,OutVal=0.010000),(InVal=0.150000,OutVal=0.100000),(InVal=0.250000,OutVal=0.200000),(InVal=0.600000,OutVal=-0.200000),(InVal=0.700000,OutVal=-0.250000),(InVal=1.000000,OutVal=0.100000)))
     RecoilYCurve=(Points=(,(InVal=0.100000,OutVal=0.090000),(InVal=0.150000,OutVal=0.150000),(InVal=0.250000,OutVal=0.120000),(InVal=0.600000,OutVal=-0.150000),(InVal=0.700000,OutVal=0.050000),(InVal=500000.000000,OutVal=0.500000)))
     RecoilPitchFactor=0.800000
     RecoilYawFactor=0.800000
     RecoilXFactor=0.300000
     RecoilYFactor=0.300000
     RecoilMax=1024.000000
     RecoilDeclineTime=1.500000
     FireModeClass(0)=Class'BWBP_SKC_Fix.A73BPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.A73BSecondaryFire'
     BringUpTime=0.500000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     bMeleeWeapon=True
     Description="A73 Elite Skrith Rifle||Manufacturer: Unknown Skrith Engineers|Primary: Energy Bolt|Secondary: Blade Stab||The A73-E is a specialized version of the Skrith standard rifle and is rarely seen on the battlefield. Aside from the red tint, the Elite model is very similar in appearance to the standard. Scans show, however, that this special version fires projectiles at roughly 3 times the standard heat level and has an odd permanent electrical charge coursing through the blades. If encountered in the field, it is advised to report the occurrence to HQ immediately for testing."
     Priority=92
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=5
     GroupOffset=14
     PickupClass=Class'BWBP_SKC_Fix.A73BPickup'
     PlayerViewOffset=(X=-4.000000,Y=10.000000,Z=-10.000000)
     BobDamping=1.600000
     AttachmentClass=Class'BWBP_SKC_Fix.A73BAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.A73b.SmallIcon_A73E'
     IconCoords=(X2=127,Y2=31)
     ItemName="A73-E Skrith Rifle"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=180
     LightSaturation=100
     LightBrightness=192.000000
     LightRadius=12.000000
     Mesh=SkeletalMesh'BallisticAnims2.A73SkrithRifle'
     DrawScale=0.188000
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_Tex.A73b.A73BAmmoSkin'
     Skins(2)=Shader'BWBP_SKC_Tex.A73b.A73BSkin_SD'
     Skins(3)=Texture'BWBP_SKC_Tex.A73b.A73BSkinB0'
     Skins(4)=Shader'BWBP_SKC_Tex.A73b.A73BBladeShader'
     SoundPitch=32
     SoundRadius=32.000000
}
