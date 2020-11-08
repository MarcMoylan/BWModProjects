//=============================================================================
// VSKTranqRifle.
//
// Special operations gas rifle. Fires anesthetic darts for maximum fun.
// Scope changes rate of fire and sound and stuff.
//
// by Sarge
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class VSKTranqRifle extends BallisticWeapon;

var float		lastModeChangeTime;

replication
{
	reliable if (Role == ROLE_Authority)
		ClientSwitchWeaponMode;

}

simulated event PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	VSKPrimaryFire(FireMode[0]).SwitchScopedMode(CurrentWeaponMode);
}


function ServerSwitchWeaponMode (byte newMode)
{
	if (CurrentWeaponMode > 0 && FireMode[0].IsFiring())
		return;
	super.ServerSwitchWeaponMode (newMode);
	if (!Instigator.IsLocallyControlled())
		VSKPrimaryFire(FireMode[0]).SwitchScopedMode(CurrentWeaponMode);
	ClientSwitchWeaponMode (CurrentWeaponMode);
}
simulated function ClientSwitchWeaponMode (byte newMode)
{
	VSKPrimaryFire(FireMode[0]).SwitchScopedMode(newMode);
}

simulated function SetScopeBehavior()
{
	super.SetScopeBehavior();
	if (bScopeView)
	{
		WeaponModes[0].bUnavailable=true;
		WeaponModes[1].bUnavailable=true;
		WeaponModes[2].bUnavailable=false;
		WeaponModes[3].bUnavailable=false;
		if (CurrentWeaponMode == 1)
			CurrentWeaponMode=3;
		if (CurrentWeaponMode == 0)
			CurrentWeaponMode=2;
		VSKPrimaryFire(FireMode[0]).SwitchScopedMode(CurrentWeaponMode);
	}
	else
	{
		WeaponModes[0].bUnavailable=false;
		WeaponModes[1].bUnavailable=false;
		WeaponModes[2].bUnavailable=true;
		WeaponModes[3].bUnavailable=true;
		if (CurrentWeaponMode == 3)
			CurrentWeaponMode=1;
		if (CurrentWeaponMode == 2)
			CurrentWeaponMode=0;
		VSKPrimaryFire(FireMode[0]).SwitchScopedMode(CurrentWeaponMode);
	}
}




simulated event WeaponTick(float DT)
{
	super.WeaponTick(DT);


		if (CurrentWeaponMode == 0)
		{
			FireMode[0].FireRate 	= 0.15;
     			RecoilXFactor		= 0.3;
     			RecoilYFactor		= 0.2;
		}
		else if (CurrentWeaponMode == 1)
		{
			FireMode[0].FireRate 	= 0.15;
     			RecoilXFactor		= 0.3;
     			RecoilYFactor		= 0.2;
		}
		else if (CurrentWeaponMode == 2)
		{
			FireMode[0].FireRate 	= 0.4;
     			RecoilXFactor		= 0.2;
     			RecoilYFactor		= 0.6;
		}
		else if (CurrentWeaponMode == 3)
		{
			FireMode[0].FireRate 	= 0.4;
     			RecoilXFactor		= 0.2;
     			RecoilYFactor		= 0.6;

		}
		else
		{
			FireMode[0].FireRate 	= BFireMode[0].default.FireRate;
     			RecoilXFactor		= 0.3;
     			RecoilYFactor		= 0.2;
		}

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
function byte BestMode()	{	return 0;	}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return Super.GetAIRating();

	Dist = VSize(B.Enemy.Location - Instigator.Location);

	Result = Super.GetAIRating();
	if (Dist < 1000)
		Result += (Dist/1000) - 1;
	else
		Result += 1-(Abs(Dist-5000)/5000);

	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return -0.1;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.8;	}
// End AI Stuff =====

defaultproperties
{
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.000000
     BigIconMaterial=Texture'BWBP_SKC_Tex.M30A2.BigIcon_M30A2'
     BallisticInventoryGroup=7
     SightFXClass=Class'BallisticFix.M50SightLEDs'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="320.0;25.0;1.0;110.0;2.0;0.1;0.1")
     BringUpSound=(Sound=Sound'BWBP_SKC_Sounds.VSK.VSK-Draw')
     PutDownSound=(Sound=Sound'BWBP_SKC_Sounds.VSK.VSK-Holster')
     MagAmmo=10
     CockAnimPostReload="Cock"
     CockSound=(Sound=Sound'BWBP_SKC_Sounds.VSK.VSK-Cock',Volume=1.000000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_Sounds.VSK.VSK-ClipOut',Volume=1.500000)
     ClipInSound=(Sound=Sound'BWBP_SKC_Sounds.VSK.VSK-ClipIn',Volume=1.500000)
     ClipInFrame=0.650000
     WeaponModes(0)=(ModeName="Semi-Automatic LP")
     WeaponModes(1)=(ModeName="Automatic LP",ModeID="WM_FullAuto")
     WeaponModes(2)=(ModeName="Semi-Automatic HP",bUnavailable=True,ModeID="WM_SemiAuto",Value=1.000000)
     WeaponModes(3)=(ModeName="Automatic HP",bUnavailable=True,ModeID="WM_FullAuto")
     CurrentWeaponMode=1
     bNoCrosshairInScope=true
     ScopeViewTex=Texture'BWBP_SKC_TexExp.VSK.VSKScopeView'
     ZoomInSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomIn',Volume=0.500000,Pitch=1.000000)
     ZoomOutSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomOut',Volume=0.500000,Pitch=1.000000)
	 ZoomType=ZT_Smooth
     FullZoomFOV=15.000000
     bNoMeshInScope=True
     SightPivot=(Pitch=600,Roll=-1024)
     SightOffset=(X=-1.000000,Y=-1.000000,Z=11.600000)
     SightDisplayFOV=20.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.Cross4',pic2=Texture'BallisticUI2.Crosshairs.A73OutA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=25,G=122,R=11,A=255),Color2=(B=255,G=255,R=255,A=255),StartSize1=22,StartSize2=59)     CrouchAimFactor=0.500000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     ViewAimFactor=0.200000
     ViewRecoilFactor=0.600000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.300000),(InVal=0.800000,OutVal=-0.400000),(InVal=1.000000,OutVal=-0.200000)))
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYawFactor=0.400000
     RecoilXFactor=0.300000
     RecoilYFactor=0.200000
     FireModeClass(0)=Class'BWBP_SKC_Fix.VSKPrimaryFire'
     FireModeClass(1)=Class'BCoreFix.BallisticScopeFire'
     PutDownTime=0.700000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     Description="VSK42 'Vampir' Tranqulizer Rifle||Manufacturer: Zavod Tochnogo Voorujeniya (ZTV Export)|Primary: Tranqulizer Dart Fire|Secondary: Zooming Scope||Vintovka Snayperskaya Kisel'eva - Paraliticheskaya. Named the Vampire due to the fact that it literally sucks the life force out of its enemies with its highly potent tranqulizer rounds. Perfect for stealthy take downs, the tactical VSP-42 and non-lethal VSK-42 are high class weapons produced in the post-war Russian Federation. The unique cased subsonic rounds of the VSK are packed with an extremely potent immobilising drug capable of dropping a juggernaut in a single shot. (Usage of more than one shot is not recommended as doses of more than 1 ml carry a 95% casualty rate in humans.) Dart velocity can be adjusted when using gas-assisted firemodes to increase range and hypodermic penetration."
     Priority=65
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.VSKPickup'
     PlayerViewOffset=(X=8.000000,Y=8.000000,Z=-16.000000)
     BobDamping=2.000000
     AttachmentClass=Class'BWBP_SKC_Fix.VSKAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.M30A2.SmallIcon_M30A2'
     IconCoords=(X2=127,Y2=31)
     ItemName="VSK-42 Tranq Rifle"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.VSK_FP'
     DrawScale=0.350000
}
