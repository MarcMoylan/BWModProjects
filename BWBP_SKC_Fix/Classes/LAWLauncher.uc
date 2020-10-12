//=============================================================================
// LAWLauncher
//
// Big mother hugging rocket launcher. Has a huge blast radius and hurts through
// walls. Long reload and draw/drop times make it hard to use on the fly.
//
// Alt fire is a pulse emitting rocket for shaking out campers and hippies.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class LAWLauncher extends BallisticWeapon;

#EXEC OBJ LOAD FILE=BWBP_SKC_Tex.utx

var() BUtil.FullSound	HatchSound;


var   bool          bRunOffsetting;
var	bool		  bInUse;
var() rotator       RunOffset;

var   Emitter		LaserDot;
var   bool		bLaserOn;
var   LaserActor	Laser;
var   Emitter		LaserBlast;
var() Sound		LaserOnSound;
var() Sound		LaserOffSound;


replication
{
	reliable if (Role == ROLE_Authority)
		bLaserOn;
}

simulated function TickLongGun (float DT)
{
	local Actor		T;
	local Vector	HitLoc, HitNorm, Start;
	local float		Dist;

	LongGunFactor += FClamp(NewLongGunFactor - LongGunFactor, -DT/AimAdjustTime, DT/AimAdjustTime);

	Start = Instigator.Location + Instigator.EyePosition();
	T = Trace(HitLoc, HitNorm, Start + vector(Instigator.GetViewRotation()) * (GunLength+Instigator.CollisionRadius), Start, true);
	if (T == None || T.Base == Instigator || (G5MortarDamageHull(T)!=None && T.Owner == Instigator))
	{
		if (bPendingSightUp && SightingState < SS_Raising && NewLongGunFactor > 0)
			ScopeBackUp(0.5);
		NewLongGunFactor = 0;
	}
	else
	{
		Dist = VSize(HitLoc - Start)-Instigator.CollisionRadius;
		if (Dist < GunLength)
		{
			if (bScopeView)
				TemporaryScopeDown(0.5);
			NewLongGunFactor = Acos(Dist / GunLength)/1.570796;
		}
	}
}

simulated function OutOfAmmo()
{
	local int channel;
	local name anim;
	local float frame, rate;
    if ( Instigator == None || !Instigator.IsLocallyControlled() || HasAmmo() )
        return;

	GetAnimParams(channel, anim, frame, rate);
	
	if (bPreventReload)
		return;
	
    DoAutoSwitch();
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	ServerSwitchlaser(true);
	Super.BringUp(PrevWeapon);
	if (Instigator != None && Laser == None && PlayerController(Instigator.Controller) != None)
		Laser = Spawn(class'BWBP_SKC_Fix.LaserActor_LAW');
	if (Instigator != None && LaserBlast == None && PlayerController(Instigator.Controller) != None)
		LaserBlast = Spawn(class'BWBP_SKC_Fix.LAWLaserBlast');
	if (Instigator != None && LaserDot == None && PlayerController(Instigator.Controller) != None)
		SpawnLaserDot();
	if (Instigator != None && AIController(Instigator.Controller) != None)
		ServerSwitchLaser(FRand() > 0.5);

	if (class'BallisticReplicationInfo'.default.bNoReloading && AmmoAmount(0) > 1)
		SetBoneScale (0, 1.0, 'Rocket');

	if ( ThirdPersonActor != None )
		LAWAttachment(ThirdPersonActor).bLaserOn = bLaserOn;
}

function ServerSwitchLaser(bool bNewLaserOn)
{
	bLaserOn = bNewLaserOn;
	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
	if (ThirdPersonActor!=None)
		LAWAttachment(ThirdPersonActor).bLaserOn = bLaserOn;
    if (Instigator.IsLocallyControlled())
		ClientSwitchLaser();
}



simulated function ClientSwitchLaser()
{
	if (bLaserOn)
	{
		SpawnLaserDot();
		PlaySound(LaserOnSound,,3.7,,32);
	}
	else
	{
		KillLaserDot();
		PlaySound(LaserOffSound,,3.7,,32);
	}
	if (!IsinState('DualAction') && !IsinState('PendingDualAction'))
		PlayIdle();
	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
}



simulated function KillLaserDot()
{
	if (LaserDot != None)
	{
		LaserDot.Kill();
		LaserDot = None;
	}
}
simulated function SpawnLaserDot(optional vector Loc)
{
	if (LaserDot == None)
		LaserDot = Spawn(class'BWBP_SKC_Fix.LAWLaserDot',,,Loc);
}





simulated function PlayIdle()
{
	Super.PlayIdle();
	if (bPendingSightUp || SightingState != SS_None || !CanPlayAnim(IdleAnim, ,"IDLE"))
		return;
	FreezeAnimAt(0.0);
}


simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		if (MagAmmo < 2)
			SetBoneScale (0, 0.0, 'Rocket');
		KillLaserDot();
		if (ThirdPersonActor != None)
			LAWAttachment(ThirdPersonActor).bLaserOn = false;
		return true;
	}

	return false;
}

/*
simulated function vector ConvertFOVs (vector InVec, float InFOV, float OutFOV, float Distance)
{
	local vector ViewLoc, Outvec, Dir, X, Y, Z;
	local rotator ViewRot;

	ViewLoc = Instigator.Location + Instigator.EyePosition();
	ViewRot = Instigator.GetViewRotation();
	Dir = InVec - ViewLoc;
	GetAxes(ViewRot, X, Y, Z);

    OutVec.X = Distance / tan(OutFOV * PI / 360);
    OutVec.Y = (Dir dot Y) * (Distance / tan(InFOV * PI / 360)) / (Dir dot X);
    OutVec.Z = (Dir dot Z) * (Distance / tan(InFOV * PI / 360)) / (Dir dot X);
    OutVec = OutVec >> ViewRot;

	return OutVec + ViewLoc;
}*/

// Draw a laser beam and dot to show exact path of bullets before they're fired
simulated function DrawLaserSight ( Canvas Canvas )
{
	local Vector HitLocation, Start, End, HitNormal, Scale3D, Loc;
	local Rotator AimDir;
	local Actor Other;

	if ((ClientState == WS_Hidden) || (!bLaserOn) || Instigator == None || Instigator.Controller == None || Laser==None)
		return;

	AimDir = BallisticFire(FireMode[0]).GetFireAim(Start);
	Loc = GetBoneCoords('tip2').Origin;

	End = Start + Normal(Vector(AimDir))*5000;
	Other = FireMode[0].Trace (HitLocation, HitNormal, End, Start, true);
	if (Other == None)
		HitLocation = End;

	// Draw dot at end of beam
	if (ReloadState == RS_None && ClientState == WS_ReadyToFire && !IsInState('DualAction') && Level.TimeSeconds - FireMode[0].NextFireTime > 0.2)
		SpawnLaserDot(HitLocation);
	else
		KillLaserDot();
	if (LaserDot != None)
		LaserDot.SetLocation(HitLocation);
	Canvas.DrawActor(LaserDot, false, false, Instigator.Controller.FovAngle);

	// Draw beam from bone on gun to point on wall(This is tricky cause they are drawn with different FOVs)
	Laser.SetLocation(Loc);
	HitLocation = ConvertFOVs(End, Instigator.Controller.FovAngle, DisplayFOV, 400);
	if (ReloadState == RS_None && ClientState == WS_ReadyToFire && !IsInState('DualAction') && Level.TimeSeconds - FireMode[0].NextFireTime > 0.2)
		Laser.SetRotation(Rotator(HitLocation - Loc));
	else
	{
		AimDir = GetBoneRotation('tip2');
		Laser.SetRotation(AimDir);
	}

	if (LaserBlast != None)
	{
		LaserBlast.SetLocation(Laser.Location);
		LaserBlast.SetRotation(Laser.Rotation);
		Canvas.DrawActor(LaserBlast, false, false, DisplayFOV);
	}
	Scale3D.X = VSize(HitLocation-Loc)/128;
	Scale3D.Y = 1;
	Scale3D.Z = 1;
	Laser.SetDrawScale3D(Scale3D);
	Canvas.DrawActor(Laser, false, false, DisplayFOV);
}

simulated event RenderOverlays (Canvas Canvas)
{

	if (!bScopeView)
	{
		Super.RenderOverlays(Canvas);
		DrawLaserSight(Canvas);
		if (SightFX != None)
			RenderSightFX(Canvas);
		return;
	}
	if (!bNoMeshInScope)
	{
		Super.RenderOverlays(Canvas);
		if (SightFX != None)
			RenderSightFX(Canvas);
	}
	else
	{
		SetLocation(Instigator.Location + Instigator.CalcDrawOffset(self));
		SetRotation(Instigator.GetViewRotation());
	}

	// Draw Scope View
    if (ScopeViewTex != None)
    	{
 	        Canvas.SetDrawColor(255,255,255);

        	Canvas.SetPos(Canvas.OrgX, Canvas.OrgY);
    		Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);

        	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, Canvas.SizeY, Canvas.SizeY, 0, 0, 1024, 1024);

        	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);
		
	}
}




simulated function Destroyed ()
{
	default.bLaserOn = false;
	if (Laser != None)
		Laser.Destroy();
	if (LaserDot != None)
		LaserDot.Destroy();
	Super.Destroyed();
}



simulated function WeaponTick(float DT)
{


	Super.WeaponTick(DT);


	if (Instigator.Base != none && VSize(Instigator.velocity - Instigator.base.velocity) > 220 && !bRunOffsetting)
    {
        SetNewAimOffset(CalcNewAimOffset(), AimAdjustTime);
        bRunOffsetting=true;  
    }
    else if (Instigator.Base != none && VSize(Instigator.velocity - Instigator.base.velocity) <= 220 && bRunOffsetting)
    {
        SetNewAimOffset(default.AimOffset, AimAdjustTime);
        bRunOffsetting=false;
    }

}

simulated function Rotator CalcNewAimOffset()
{
	local rotator R;

	R = default.AimOffset;

	if (!BCRepClass.default.bNoJumpOffset && SprintControl != None && SprintControl.bSprinting)
		R += SprintOffset;
    else if (Instigator.Base != none && VSize(Instigator.velocity - Instigator.base.velocity) > 220)
        R += RunOffset;
	return R;
}

simulated function vector ConvertFOVs (vector InVec, float InFOV, float OutFOV, float Distance)
{
	local vector ViewLoc, Outvec, Dir, X, Y, Z;
	local rotator ViewRot;

	ViewLoc = Instigator.Location + Instigator.EyePosition();
	ViewRot = Instigator.GetViewRotation();
	Dir = InVec - ViewLoc;
	GetAxes(ViewRot, X, Y, Z);

    OutVec.X = Distance / tan(OutFOV * PI / 360);
    OutVec.Y = (Dir dot Y) * (Distance / tan(InFOV * PI / 360)) / (Dir dot X);
    OutVec.Z = (Dir dot Z) * (Distance / tan(InFOV * PI / 360)) / (Dir dot X);
    OutVec = OutVec >> ViewRot;

	return OutVec + ViewLoc;
}


// AI Interface =====
function byte BestMode()
{
	return 0;	
}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;
	local vector Dir;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return Super.GetAIRating();

	Dir = B.Enemy.Location - Instigator.Location;
	Dist = VSize(Dir);

	Result = Super.GetAIRating();
	if (Dist < 600)
		Result -= 0.6;
	else if (Dist > 4000)
		Result -= 0.3;
	else if (Dist > 20000)
		Result += (Dist-1000) / 2000;
	result += 0.2 - FRand()*0.4;
	return Result;
}
// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return -0.5;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return -0.9;	}
// End AI Stuff =====



simulated function Notify_G5HatchOpen ()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;
	class'BUtil'.static.PlayFullSound(self, HatchSound);
}
simulated function Notify_G5HideRocket ()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;
	if (!class'BallisticReplicationInfo'.default.bNoReloading || AmmoAmount(0) < 2)
		SetBoneScale (0, 0.0, 'Rocket');
}

defaultproperties
{
     LaserOnSound=Sound'BWBP_SKC_Sounds.AH104.AH104-SightOn'
     LaserOffSound=Sound'BWBP_SKC_Sounds.AH104.AH104-SightOff'
     HatchSound=(Sound=Sound'BallisticSounds2.M75.M75Cliphit',Volume=0.700000,Pitch=1.000000)
     RunOffset=(Pitch=-4000,Roll=1000,Yaw=-2000)
     PlayerSpeedFactor=0.700000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=4.000000
     AimAdjustTime=0.750000
     SightingTime=0.750000
     BigIconMaterial=Texture'BWBP_SKC_TexExp.LAW.BigIcon_LAW'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     InventorySize=60
     bWT_Hazardous=True
     bWT_Splash=True
     bWT_Projectile=True
     bWT_Super=True
     SpecialInfo(0)=(Info="500.0;60.0;1.0;80.0;2.0;0.0;1.5")
     BringUpSound=(Sound=Sound'BWBP_SKC_SoundsExp.LAW.LAW-Draw',Volume=1.100000)
     PutDownSound=(Sound=Sound'BWBP4-Sounds.Artillery.Art-Undeploy',Volume=1.100000)
     MagAmmo=1
     CockSound=(Sound=Sound'BallisticSounds2.G5.G5-Lever')
     ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.LAW.LAW-TubeUnlock',Volume=2.100000)
     ClipInSound=(Sound=Sound'BWBP_SKC_SoundsExp.LAW.LAW-TubeLock',Volume=2.100000)
     ClipHitSound=(Sound=Sound'BWBP_SKC_SoundsExp.LAW.LAW-Cock',Volume=2.100000)
     bNeedCock=False
     bCockOnEmpty=False
     bNonCocking=True
     WeaponModes(0)=(ModeName="Single Fire")
     WeaponModes(1)=(bUnavailable=True)
     WeaponModes(2)=(bUnavailable=True)
     CurrentWeaponMode=0
     ScopeViewTex=Texture'BWBP_SKC_TexExp.LAW.LAW-ScopeView'
     ZoomInSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomIn',Volume=0.500000,Pitch=1.000000)
     ZoomOutSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomOut',Volume=0.500000,Pitch=1.000000)
     FullZoomFOV=10.000000
	 ZoomType=ZT_Logarithmic
     bNoMeshInScope=True
     bNoCrosshairInScope=True
     SightOffset=(Y=6.000000,Z=15.000000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.Misc8',pic2=Texture'BallisticUI2.Crosshairs.Misc11',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=0,G=0,R=255,A=104),Color2=(B=0,G=255,R=255,A=117),StartSize1=45,StartSize2=41)
     CrosshairInfo=(SpreadRatios=(X1=0.250000,Y1=0.250000,X2=1.000000,Y2=1.000000),MaxScale=2.000000)
     CrosshairChaosFactor=0.750000
     CrouchAimFactor=0.400000
     SightAimFactor=0.100000
     SprintOffSet=(Pitch=-6000,Yaw=-8000)
     JumpOffSet=(Pitch=-7000)
     AimSpread=(X=(Min=-70.000000,Max=70.000000),Y=(Min=-180.000000,Max=180.000000))
     ViewAimFactor=0.300000
     ViewRecoilFactor=1.000000
     AimDamageThreshold=300.000000
     ChaosDeclineTime=2.800000
     ChaosSpeedThreshold=380.000000
     ChaosAimSpread=(X=(Min=-2600.000000,Max=2600.000000),Y=(Min=-2600.000000,Max=2600.000000))
     RecoilYawFactor=0.000000
     RecoilMax=9024.000000
     RecoilDeclineTime=1.000000
     RecoilDeclineDelay=0.000000
     FireModeClass(0)=Class'BWBP_SKC_Fix.LAWPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.LAWSecondaryFire'
     PutDownTime=2.500000
     BringUpTime=3.000000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.750000
     CurrentRating=0.750000
     Description="FGM-70 Nuclear Light Anti-Tank Weapon||Manufacturer: UTC Defense Tech|Primary: Launch Mini-Nuke|Secondary: Launch Shockwave Mine||When facing massive hoards of Cryon death-bots, overkill is sometimes not enough. That's where the FGM-70 'Shockwave' Light Anti-tank Weapon comes in. Unlike conventional anti-tank weapons, the FGM-70 LAW launches a mini-nuclear bomb instead of a high speed shaped charge. While the mini-nuke does not necessarily penetrate armor, the massive shockwave it generates will effectively do the job by liquefying the organs of all inside. A marvelous weapon to use against hardened structures and vehicles, the FGM-70 is nevertheless heavily disliked by troops, who are sometimes affected by its massive blast radius and fallout. Fireteams equipped with the weapon almost always come back with minor radiation poisoning and internal bleeding. However, the FGM-70 LAW in the end shows that tactical nuclear munitions can be effective in the right scenarios. ||If this is light, I'd hate to see heavy."
     Priority=164
     CenteredOffsetY=10.000000
     CenteredRoll=0
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=8
     PickupClass=Class'BWBP_SKC_Fix.LAWPickup'
     PlayerViewOffset=(X=10.000000,Z=-7.000000)
     BobDamping=1.800000
     AttachmentClass=Class'BWBP_SKC_Fix.LAWAttachment'
     IconMaterial=Texture'BWBP_SKC_TexExp.LAW.SmallIcon_LAW'
     IconCoords=(X2=127,Y2=31)
     ItemName="FGM-70 'Shockwave' LAW"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=25
     LightSaturation=100
     LightBrightness=192.000000
     LightRadius=12.000000
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.LAW_FP'
     DrawScale=0.400000
}
