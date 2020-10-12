//=============================================================================
// M30A2AssaultRifle.
//
// M30A2 Assault Rifle, aka thez Z. Med fire rate, good damage, high accuracy, good range, Burst, Semi-Auto
// Has underslung
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class MG33MachineGun extends BallisticWeapon;

var   Emitter		LaserDot;
var   LaserActor	Laser;
var() Sound			LaserOnSound;
var() Sound			LaserOffSound;
var   bool			bLaserOn;


replication
{
	reliable if (Role < ROLE_Authority)
		bLaserOn;
}

simulated event PostNetReceive()
{
	if (level.NetMode != NM_Client)
		return;
	if (bLaserOn != default.bLaserOn)
	{
		if (bLaserOn)
			AimAdjustTime = default.AimAdjustTime * 1.5;
		else
			AimAdjustTime = default.AimAdjustTime;
		default.bLaserOn = bLaserOn;
		ClientSwitchLaser();
	}
	Super.PostNetReceive();
}
function ServerSwitchLaser(bool bNewLaserOn)
{
	bLaserOn = bNewLaserOn;
	bUseNetAim = bLaserOn;
	if (ThirdPersonActor!=None)
		MG33Attachment(ThirdPersonActor).bLaserOn = bLaserOn;
	if (bLaserOn)
		AimAdjustTime = default.AimAdjustTime * 1.5;
	else
		AimAdjustTime = default.AimAdjustTime;
    if (Instigator.IsLocallyControlled())
		ClientSwitchLaser();
}

simulated function ClientSwitchLaser()
{
	if (bLaserOn)
	{
		SpawnLaserDot();
		PlaySound(LaserOnSound,,0.7,,32);
	}
	else
	{
		KillLaserDot();
		PlaySound(LaserOffSound,,0.7,,32);
	}
	bUseNetAim = bLaserOn;
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
		LaserDot = Spawn(class'BWBP_SKC_Fix.AH104LaserDot',,,Loc);
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);
	if (Instigator != None && Laser == None && PlayerController(Instigator.Controller) != None)
		Laser = Spawn(class'BallisticFix.LaserActor');
	if (Instigator != None && LaserDot == None && PlayerController(Instigator.Controller) != None)
		SpawnLaserDot();
	if (Instigator != None && AIController(Instigator.Controller) != None)
		ServerSwitchLaser(FRand() > 0.5);

	if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{
		IdleAnim = 'Idle';
		ReloadAnim = 'Reload';
	}
	else
	{
		IdleAnim = 'Idle';
		ReloadAnim = 'Reload';
	}

	if ( ThirdPersonActor != None )
		MG33Attachment(ThirdPersonActor).bLaserOn = bLaserOn;
}


simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		KillLaserDot();
		if (ThirdPersonActor != None)
			MG33Attachment(ThirdPersonActor).bLaserOn = false;
		return true;
	}
	return false;
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
	Scale3D.X = VSize(HitLocation-Loc)/128;
	Scale3D.Y = 1;
	Scale3D.Z = 1;
	Laser.SetDrawScale3D(Scale3D);
	Canvas.DrawActor(Laser, false, false, DisplayFOV);
}
simulated event RenderOverlays( Canvas Canvas )
{
	super.RenderOverlays(Canvas);
	if (!IsInState('Lowered'))
		DrawLaserSight(Canvas);
}

function ServerUpdateLaser(bool bNewLaserOn)
{
	bUseNetAim = bNewLaserOn;
}

exec simulated function WeaponSpecial(optional byte i)
{
		if (!bLaserOn)
		{
			bLaserOn=true;
		}
		else
		{
			if (bLaserOn)
			{
				bLaserOn=false;
			}
			else
			{
				bLaserOn=true;
			}
		}
	bUseNetAim = bLaserOn;
	ServerUpdateLaser(bLaserOn);
}



//Draw special weapon info on the hud
simulated function NewDrawWeaponInfo(Canvas C, float YPos)
{
	if (bLaserOn)	{
		CrosshairCfg.Color1.A = 0;
		CrosshairCfg.Color2.A /= 2;
	}
	Super.NewDrawWeaponInfo (C, YPos);

	if (bLaserOn)	{
		CrosshairCfg.Color1.A = default.CrosshairCfg.Color1.A ;
		CrosshairCfg.Color2.A = default.CrosshairCfg.Color2.A ;
	}
}

simulated function float RateSelf()
{
	if (!HasAmmo())
		CurrentRating = 0;
	else if (Ammo[0].AmmoAmount < 1 && MagAmmo < 1)
		CurrentRating = Instigator.Controller.RateWeapon(self)*0.3;
	else
		return Super.RateSelf();
	return CurrentRating;
}
// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if (B.Skill > Rand(6))
	{
		if (Chaos < 0.1 || Chaos < 0.5 && VSize(B.Enemy.Location - Instigator.Location) > 500)
			return 1;
	}
	else if (FRand() > 0.75)
		return 1;
	return 0;
}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	Dist = VSize(B.Enemy.Location - Instigator.Location);

	Result = Super.GetAIRating();
	if (Dist < 500)
		Result -= 1-Dist/500;
	else if (Dist < 3000)
		Result += (Dist-1000) / 2000;
	else
		Result = (Result + 0.66) - (Dist-3000) / 2500;
	if (Result < 0.34)
	{
		if (CurrentWeaponMode != 2)
		{
			CurrentWeaponMode = 2;
		}
	}

	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return 0.0;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====

defaultproperties
{
     PlayerSpeedFactor=0.900000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.000000
     BigIconMaterial=Texture'BWBP_SKC_Tex.M30A2.BigIcon_M30A2'
     BallisticInventoryGroup=6
     SightFXClass=Class'BallisticFix.M50SightLEDs'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="320.0;25.0;1.0;110.0;0.8;0.5;0.0")
     LaserOnSound=Sound'BallisticSounds2.M806.M806LSight'
     LaserOffSound=Sound'BallisticSounds2.M806.M806LSight'
     BringUpSound=(Sound=Sound'BallisticSounds2.M50.M50Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M50.M50Putaway')
     MagAmmo=100
     InventorySize=40
     CockAnimPostReload="ReloadEndCock"
     CockSound=(Sound=Sound'BallisticSounds2.M50.M50Cock')
     ClipHitSound=(Sound=Sound'BallisticSounds2.M50.M50ClipHit')
     ClipOutSound=(Sound=Sound'BallisticSounds2.M50.M50ClipOut')
     ClipInSound=(Sound=Sound'BallisticSounds2.M50.M50ClipIn')
     ClipInFrame=0.650000
     	ReloadAnimRate=0.45
     bNeedCock=True
     WeaponModes(0)=(ModeName="Semi-Automatic")
     CurrentWeaponMode=2
     bNoCrosshairInScope=true
     ScopeViewTex=Texture'BWBP_SKC_Tex.M36.M36-Scope'
     ZoomInSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomIn',Volume=0.500000,Pitch=1.000000)
     ZoomOutSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomOut',Volume=0.500000,Pitch=1.000000)
     FullZoomFOV=45.000000
	 ZoomType=ZT_Logarithmic
	 ZoomStages=1
     	ChaosDeclineTime=1.500000
     	RecoilDeclineDelay=0.3
	RecoilDeclineTime=2.2
	RecoilMax=1600
     bNoMeshInScope=True
     SightPivot=(Pitch=600,Roll=-1024)
     SightOffset=(X=-1.000000,Y=-1.000000,Z=11.600000)
     SightDisplayFOV=20.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M353OutA',Pic2=Texture'BallisticUI2.Crosshairs.M50InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=0,G=0,R=255,A=197),Color2=(B=0,G=255,R=255,A=255),StartSize1=79,StartSize2=55)
     CrouchAimFactor=0.500000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     ViewAimFactor=0.300000
     ViewRecoilFactor=0.700000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.300000),(InVal=0.800000,OutVal=-0.400000),(InVal=1.000000,OutVal=-0.200000)))
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYawFactor=0.300000
     RecoilXFactor=0.200000
     RecoilYFactor=0.200000
     FireModeClass(0)=Class'BWBP_SKC_Fix.MG33PrimaryFire'
     FireModeClass(1)=Class'BCoreFix.BallisticScopeFire'
     PutDownTime=0.700000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     Description="MARS-2 Assault Rifle||Manufacturer: Enravion Combat Solutions|Primary: Accurate Rifle Fire|Secondary: Charged Gauss Fire|Special: Laser Dot||A further improvement on their crowning achievement, the M30A1 is the long range version of the famed rifle. With a forward mounted laser sight and heavy 7.62 rifle rounds, the M30A1 Tactical Rifle can accurately snipe targets at any distance. In order to compensate for the slower firing speed and increased recoil, Enravion added a secondary gauss projectile accelerator to the barrel. By simply depressing the trigger twice in quick succession, the user can activate the system and propel the bullet at a much higher velocity through the armor and flesh of unsuspecting victims. (With regards to a 2 second recharge time.) The A1 comes equipped with a mounted camera sight for increased accuracy."
     Priority=65
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.MG33Pickup'
     PlayerViewOffset=(X=0.500000,Y=6.000000,Z=-8.200000)
     BobDamping=2.000000
     AttachmentClass=Class'BWBP_SKC_Fix.MG33Attachment'
     IconMaterial=Texture'BWBP_SKC_Tex.M30A2.SmallIcon_M30A2'
     IconCoords=(X2=127,Y2=31)
     ItemName="[B]MG33 Light Machine Gun"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BallisticAnims2.M50Assault'
     DrawScale=0.350000
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_Tex.M30A2.M30A2-SA'
     Skins(2)=Texture'BWBP_SKC_Tex.M30A2.M30A2-SB'
     Skins(3)=Combiner'BWBP_SKC_Tex.M30A2.M30A2-GunScope'
     Skins(4)=Texture'BWBP_SKC_Tex.M30A2.M30A2-Laser'
     Skins(5)=Texture'BWBP_SKC_Tex.M30A2.M30A2-Gauss'
     Skins(6)=Texture'ONSstructureTextures.CoreGroup.Invisible'
}
