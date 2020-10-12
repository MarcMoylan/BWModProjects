//=============================================================================
// AH208Pistol.
//
// A powerful sidearm designed for long range combat. The .44 bulelts are very
// deadly. Secondary is a pistol whip.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class AH250Pistol extends BallisticCamoWeapon;

var bool		bFirstDraw;
var   Emitter		LaserDot;
var   bool			bLaserOn;

var() Sound			LaserOnSound;
var() Sound			LaserOffSound;

var(AH250Pistol) name		RDSBone;			// Bone to use for hiding Red Dot Sight
var(AH250Pistol) name		MuzzBone;			// Bone to use for hiding Compensator
var(AH250Pistol) name		LAMBone;			// Bone to use for hiding LAM
var(AH250Pistol) name		ScopeBone;			// Bone to use for hiding scope
var(AH208Pistol) name		BulletBone;			// Bone to use for hiding bullet

var(AH250Pistol) sound		CamoSound1; //For Silver
var(AH250Pistol) sound		CamoSound2; //For Gold


simulated function AdjustCamoProperties(optional int Index)
{
	local float f;

		f = FRand();

		if ((Index == -1 && f > 0.99) || Index == 4) //Golden
		{
			Skins[1]=CamoMaterials[4];
			Skins[3]=CamoMaterials[6];
			SetBoneScale (3, 0.0, MuzzBone);
			CamoIndex=4;
			BallisticInstantFire(FireMode[0]).BallisticFireSound.Sound=CamoSound1;
			BallisticInstantFire(FireMode[0]).Damage = 90;
			BallisticInstantFire(FireMode[0]).DamageHead = 135;
			BallisticInstantFire(FireMode[0]).DamageLimb = 35;
		}
		else if ((Index == -1 && f > 0.96) || Index == 3) //Silver Scopeless!
		{
			Skins[1]=CamoMaterials[3];
			Skins[4]=CamoMaterials[9];
			BallisticInstantFire(FireMode[0]).BallisticFireSound.Sound=CamoSound2;
			if (bAllowCamoEffects)
			{
				SetBoneScale (1, 0.0, ScopeBone);
				SightOffset = vect(-20,-7.35,41.7);

     				ScopeViewTex=None;
     				ZoomInSound.Sound=None;
     				ZoomOutSound.Sound=None;
     				FullZoomFOV=80;
				SightDisplayFOV=40;
     				bNoMeshInScope=False;
			}
			CamoIndex=3;
		}
		else if ((Index == -1 && f > 0.85) || Index == 2) //white
		{
			Skins[1]=CamoMaterials[2];
			Skins[3]=CamoMaterials[5];
			Skins[4]=CamoMaterials[7];
			CamoIndex=2;
		}
		else if ((Index == -1 && f > 0.75) || Index == 1) //LAM equipped
		{
			Skins[1]=CamoMaterials[2];
			Skins[3]=CamoMaterials[5];
			CamoIndex=1;
		}
		else
		{
			Skins[1]=CamoMaterials[1];
			Skins[3]=CamoMaterials[5];
			Skins[4]=CamoMaterials[8];
			CamoIndex=0;
		}
}

replication
{
	reliable if (Role < ROLE_Authority)
		ServerUpdateLaser;
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	if (CamoIndex != 1)
		SetBoneScale (0, 0.0, LAMBone);
	SetBoneScale (2, 0.0, RDSBone);
	if (CamoIndex != 4)
		SetBoneScale (3, 1.0, MuzzBone);
	if (bFirstDraw && MagAmmo > 0)
	{
     		BringUpTime=1.700000;
     		SelectAnim='PulloutFancy';
		bFirstDraw=false;
		SetBoneScale(4,1.0,BulletBone);
	}
	else if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{
		IdleAnim = 'OpenIdle';
		ReloadAnim = 'OpenReload';
		SelectAnim = 'OpenPullout';
		BringUpTime=default.BringUpTime;
		SetBoneScale(4,0.0,BulletBone);
	}
	else
	{
		IdleAnim = 'Idle';
		ReloadAnim = 'Reload';
		SelectAnim = 'Pullout';
		BringUpTime=default.BringUpTime;
	}


	Super.BringUp(PrevWeapon);

}


//Draw special weapon info on the hud
simulated function NewDrawWeaponInfo(Canvas C, float YPos)
{
	if (bLaserOn)	{
		CrosshairCfg.Color1.A /= 2;
		CrosshairCfg.Color2.A /= 2;
	}
	Super.NewDrawWeaponInfo (C, YPos);

	if (bLaserOn)	{
		CrosshairCfg.Color1.A = default.CrosshairCfg.Color1.A ;
		CrosshairCfg.Color2.A = default.CrosshairCfg.Color2.A ;
	}
}

simulated function Destroyed ()
{
	default.bLaserOn = false;
	if (LaserDot != None)
		LaserDot.Destroy();
	Super.Destroyed();
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
		LaserDot = Spawn(class'BallisticFix.G5LaserDot',,,Loc);
}

simulated function bool PutDown()
{
	if (super.PutDown())
	{
		bLaserOn=false;
		KillLaserDot();
		return true;
	}
	return false;
}

// Change some properties when using sights...
simulated function SetScopeBehavior()
{
	super.SetScopeBehavior();

	bUseNetAim = bScopeView || bLaserOn;
	if (bScopeView)
	{
     		RecoilDeclineTime=2.000000;
     		RecoilDeclineDelay=0.300000;
	}
	else
	{
     		RecoilDeclineTime=default.RecoilDeclineTime;
     		RecoilDeclineDelay=default.RecoilDeclineDelay;
	}
}



simulated function DrawLaserSight ( Canvas Canvas )
{
	local Vector HitLocation, Start, End, HitNormal;
	local Rotator AimDir;
	local Actor Other;

	if (ClientState != WS_ReadyToFire || Firemode[1].bIsFiring || !bLaserOn/* || !bScopeView */|| ReloadState != RS_None || IsInState('DualAction')/* || Level.TimeSeconds - FireMode[0].NextFireTime < 0.2*/)
	{
		KillLaserDot();
		return;
	}

	AimDir = BallisticFire(FireMode[0]).GetFireAim(Start);

	End = Start + Normal(Vector(AimDir))*5000;
	Other = FireMode[0].Trace (HitLocation, HitNormal, End, Start, true);
	if (Other == None)
		HitLocation = End;

	// Draw dot at end of beam
	SpawnLaserDot(HitLocation);
	if (LaserDot != None)
		LaserDot.SetLocation(HitLocation);
	Canvas.DrawActor(LaserDot, false, false, Instigator.Controller.FovAngle);
}

function ServerUpdateLaser(bool bNewLaserOn)
{
	bUseNetAim = default.bUseNetAim || bScopeView || bNewLaserOn;
}
simulated event RenderOverlays (Canvas Canvas)
{
	local float ImageScaleRatio;

	if (!bScopeView)
	{
		Super.RenderOverlays(Canvas);
		if (SightFX != None)
			RenderSightFX(Canvas);
		return;
	}
	if (bScopeView && ( (PlayerController(Instigator.Controller).DesiredFOV == PlayerController(Instigator.Controller).DefaultFOV && PlayerController(Instigator.Controller).bZooming==false)
		|| (Level.bClassicView && (PlayerController(Instigator.Controller).DesiredFOV == 90)) ))
	{
		SetScopeView(false);
		PlayAnim(ZoomOutAnim);
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
	// Draw the Scope View Tex
	Canvas.SetDrawColor(255,255,255,255);
	Canvas.SetPos(Canvas.OrgX, Canvas.OrgY);
	Canvas.Style = ERenderStyle.STY_Alpha;
	ImageScaleRatio = 1.3333333;


        	Canvas.SetPos(Canvas.OrgX, Canvas.OrgY);
    		Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);

        	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, Canvas.SizeY, Canvas.SizeY, 0, 0, 1024, 1024);

        	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);
		
}



// Animation notify for when cocking action starts. Used to time sounds
simulated function Notify_CockSim()
{
	PlayOwnedSound(CockSound.Sound,CockSound.Slot,CockSound.Volume,CockSound.bNoOverride,CockSound.Radius,CockSound.Pitch,CockSound.bAtten);
}

simulated function Notify_HideBullet()
{
	if (MagAmmo < 2)
		SetBoneScale(4,0.0,BulletBone);
}

simulated function Notify_ShowBullet()
{
	SetBoneScale(4,1.0,BulletBone);
}



simulated event AnimEnd (int Channel)
{
    local name Anim;
    local float Frame, Rate;

    GetAnimParams(0, Anim, Frame, Rate);

	if (Anim == 'OpenFire' || Anim == 'Fire' || Anim == 'OpenFire' || Anim == 'OpenSightFire' || Anim == CockAnim || Anim == ReloadAnim)
	{
		if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
		{
			IdleAnim = 'OpenIdle';
			ReloadAnim = 'OpenReload';
			PutDownAnim = 'OpenPutaway';
			SelectAnim = 'OpenPullout';
		}
		else
		{
			IdleAnim = 'Idle';
			ReloadAnim = 'Reload';
			PutDownAnim = 'Putaway';
			SelectAnim = 'Pullout';
		}
	}
	Super.AnimEnd(Channel);
}

simulated function PlayCocking(optional byte Type)
{
	if (Type == 2)
		PlayAnim('ReloadEndCock', CockAnimRate, 0.2);
	else
		PlayAnim(CockAnim, CockAnimRate, 0.2);
}

// Secondary fire doesn't count for this weapon
simulated function bool HasAmmo()
{
	//First Check the magazine
	if (!bNoMag && FireMode[0] != None && MagAmmo >= FireMode[0].AmmoPerFire)
		return true;
	//If it is a non-mag or the magazine is empty
	if (Ammo[0] != None && FireMode[0] != None && Ammo[0].AmmoAmount >= FireMode[0].AmmoPerFire)
			return true;
	return false;	//This weapon is empty
}



// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()	{	return 0;	}


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
	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return 0.3;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====

defaultproperties
{
     LaserOnSound=Sound'BWAddPack-RS-Sounds.TEC.RSMP-LaserClick'
     LaserOffSound=Sound'BWAddPack-RS-Sounds.TEC.RSMP-LaserClick'
     PlayerSpeedFactor=1.000000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.500000
     BigIconMaterial=Texture'BWBP_SKC_Tex.Eagle.BigIcon_EagleAlt'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
		bFirstDraw=True
		bNeedCock=False

     CamoSound1=Sound'BWBP_SKC_Sounds.AH104.AH104-Blast'
     CamoSound2=Sound'BWBP_SKC_Sounds.M781.M784-Single';

     CamoMaterials[2]=Shader'BWBP_SKC_Tex.Eagle.Eagle-MainShine'
     CamoMaterials[1]=Shader'BWBP_SKC_Tex.Eagle.Eagle-BlackShine'
     CamoMaterials[3]=Shader'BWBP_SKC_Tex.Eagle.Eagle-SilverShine'
     CamoMaterials[4]=Shader'BWBP_SKC_Tex.Eagle.Eagle-GoldShine'
     CamoMaterials[5]=Texture'BWBP_SKC_Tex.Eagle.Eagle-Scope'
     CamoMaterials[6]=Texture'BWBP_SKC_Tex.Eagle.Eagle-ScopeGold'
     CamoMaterials[7]=Texture'BWBP_SKC_Tex.Eagle.Eagle-Front'
     CamoMaterials[8]=Texture'BWBP_SKC_Tex.Eagle.Eagle-FrontBlack'
     CamoMaterials[9]=Texture'BWBP_SKC_Tex.Eagle.Eagle-FrontSilver'

	MuzzBone="Compensator"
	RDSBone="RedDotSight"
	LAMBone="LAM"
	ScopeBone="Scope"
	BulletBone="Bullet"
     InventorySize=25
     bWT_Bullet=True
     SpecialInfo(0)=(Info="140.0;12.0;0.7;70.0;0.55;0.0;-999.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.M806.M806Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M806.M806Putaway')
     MagAmmo=8
     CockSound=(Sound=Sound'BWBP_SKC_Sounds.Eagle.Eagle-Cock',Volume=5.100000)
     ClipHitSound=(Sound=Sound'BWBP_SKC_Sounds.Eagle.Eagle-ClipHit',Volume=2.500000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_Sounds.Eagle.Eagle-ClipOut',Volume=2.500000)
     ClipInSound=(Sound=Sound'BWBP_SKC_Sounds.Eagle.Eagle-ClipIn',Volume=2.500000)
     ClipInFrame=0.650000
     WeaponModes(0)=(ModeName="Semi-Automatic")
     WeaponModes(1)=(ModeName="Mode-2",bUnavailable=True,Value=7.000000)
     WeaponModes(2)=(bUnavailable=True)
     CurrentWeaponMode=0
     ScopeViewTex=Texture'BWBP_SKC_Tex.Eagle.Eagle-ScopeView'
     ZoomInSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomIn',Volume=0.500000,Pitch=1.000000)
     ZoomOutSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomOut',Volume=0.500000,Pitch=1.000000)
     FullZoomFOV=40.000000
	 ZoomType=ZT_Fixed
     bNoMeshInScope=True
     bNoCrosshairInScope=true
     SightOffset=(X=70.000000,Y=-7.350000,Z=45.400000)
     SightDisplayFOV=40.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.G5OutA',Pic2=Texture'BallisticUI2.Crosshairs.M806InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(A=122),Color2=(B=122),StartSize1=64,StartSize2=76)
     CrosshairInfo=(SpreadRatios=(X1=0.750000,Y1=0.750000,X2=0.300000,Y2=0.300000))
     GunLength=4.000000
     JumpOffSet=(Pitch=1000,Yaw=-500)
     JumpChaos=0.300000
     AimSpread=(X=(Min=-128.000000,Max=128.000000),Y=(Min=-128.000000,Max=128.000000))
     ViewAimFactor=0.150000
//     ViewRecoilFactor=0.250000
     ViewRecoilFactor=0.550000
//     ChaosDeclineTime=0.850000
     ChaosDeclineTime=1.400000
     ChaosTurnThreshold=150000.000000
     ChaosSpeedThreshold=1400.000000
     ChaosAimSpread=(X=(Min=-2900.000000,Max=2900.000000),Y=(Min=-2900.000000,Max=2900.000000))
     RecoilXFactor=0.600000
     RecoilYFactor=0.900000
     RecoilYawFactor=1.000000
     RecoilPitchFactor=1.000000
     RecoilMax=7168.000000
     RecoilDeclineTime=1.600000
     RecoilDeclineDelay=0.200000
//     RecoilDeclineTime=1.000000
//     RecoilDeclineDelay=0.150000
     FireModeClass(0)=Class'BWBP_SKC_Fix.AH250PrimaryFire'
     FireModeClass(1)=Class'BCoreFix.BallisticScopeFire'
     PutDownTime=0.800000
     BringUpTime=1.200000
     SelectForce="SwitchToAssaultRifle"
     bUseOldWeaponMesh=True
     Description="AH-250 'Hawk' Assault Pistol||Manufacturer: Enravion Combat Solutions|Primary: Magnum Rounds|Secondary: Scope|The new AH-250 is an updated version of Enravion's AH-208 model. Equipped with a compensator for recoil, match-grade internals, and a precision scope, the AH-250 is a powerful and precise sidearm. Big game hunters have taken a liking to the gun and it can be seen in almost every outer planet action flick. Military adoption remains low due to the heavy recoil and impracticality of carrying around such a large sidearm."
     Priority=96
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=2
     GroupOffset=13
     PickupClass=Class'BWBP_SKC_Fix.AH250Pickup'
     PlayerViewOffset=(X=0.000000,Y=19.500000,Z=-30.000000)
     BobDamping=1.200000
     AttachmentClass=Class'BWBP_SKC_Fix.AH250Attachment'
     IconMaterial=Texture'BWBP_SKC_Tex.Eagle.SmallIcon_EagleAlt'
     IconCoords=(X2=127,Y2=31)
     ItemName="AH250 Assault Pistol"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.DEagle_FP'
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Shader'BWBP_SKC_Tex.Eagle.Eagle-MainShine'
     Skins(2)=Texture'BWBP_SKC_Tex.Eagle.Eagle-Misc'
     Skins(3)=Texture'BWBP_SKC_Tex.Eagle.Eagle-Scope'
     Skins(4)=Texture'BWBP_SKC_Tex.Eagle.Eagle-Front'
     Skins(5)=Shader'BWBP_SKC_Tex.Eagle.Eagle-SightDot'
     DrawScale=0.800000
}
