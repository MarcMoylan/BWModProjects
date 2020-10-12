//=============================================================================
// MARSAssaultRifle.
//
// The MARS-2 Assault Carbine. Fires extremely fast with decent accuracy and power.
// Bad chaos means scope use is essential. 
//
// While harder to control than stock ARs, this can put out more damage.
// Bullpup config reduces chaos, but increases reload time.
//
// Makes use of Camo System V3. MEATVISION ++ IRNV
//
// by Marc "Sergeant Kelly" Moylan.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class MARSAssaultRifle extends BallisticCamoWeapon;


var bool		bFirstDraw;


var() BUtil.FullSound	ThermalOnSound;	// Sound when activating thermal mode
var() BUtil.FullSound	ThermalOffSound;// Sound when deactivating thermal mode
var   Array<Pawn>		PawnList;		// A list of all the potential pawns to view in thermal mode
var() material			WallVisionSkin;	// Texture to assign to players when theyare viewed with Thermal mode
var   bool				bThermal;		// Is thermal mode active?
var   bool				bUpdatePawns;	// Should viewable pawn list be updated
var   Pawn				UpdatedPawns[16];// List of pawns to view in thermal scope
var() material			Flaretex;		// Texture to use to obscure vision when viewing enemies directly through the thermal scope
var() float				ThermalRange;	// Maximum range at which it is possible to see enemies through walls
var   ColorModifier		ColorMod;


var   bool			bMeatVision;
var   Pawn			Target;
var   float			TargetTime;
var   float			LastSendTargetTime;
var   vector		TargetLocation;

var() BUtil.FullSound	NVOnSound;	// Sound when activating NV/Meat mode
var() BUtil.FullSound	NVOffSound; // Sound when deactivating NV/Meat mode
var   actor			NVLight;




replication
{
	reliable if (Role == ROLE_Authority && bNetDirty && bNetOwner)
		Target, bMeatVision;
	reliable if (Role < ROLE_Authority)
		ServerAdjustThermal;
}




//==============================================
//=========== Burst Code - Reduced Recoil ======
//==============================================

simulated function SetBurstModeProps()
{
	if (CurrentWeaponMode == 1 || CurrentWeaponMode == 0)
	{
		RecoilYawFactor=0.300000;
     		RecoilXFactor=0.200000;
     		RecoilYFactor=0.300000;
	}
	else
	{
		RecoilYawFactor=default.RecoilYawFactor;
     		RecoilXFactor=default.RecoilXFactor;
     		RecoilYFactor=default.RecoilYFactor;
	}
}
simulated function ServerSwitchWeaponMode (byte newMode)
{
	super.ServerSwitchWeaponMode (newMode);
	SetBurstModeProps();
}


function ServerWeaponSpecial(optional byte i)
{
	if (bScopeView)
	{
		bMeatVision = !bMeatVision;
		if (bMeatVision)
    			class'BUtil'.static.PlayFullSound(self, NVOnSound);
		else
    			class'BUtil'.static.PlayFullSound(self, NVOffSound);
	}

}


//==============================================
//=========== Scope Code - Targetting + IRNV ===
//==============================================


simulated event WeaponTick(float DT)
{
	local actor T;
	
	local float BestAim, BestDist;
//	local Vector Start;
	local Pawn Targ;

	local vector HitLoc, HitNorm, Start, End;

	super.WeaponTick(DT);



	if (bThermal && bScopeView)
	{
		SetNVLight(true);

		Start = Instigator.Location+Instigator.EyePosition();
		End = Start+vector(Instigator.GetViewRotation())*1500;
		T = Trace(HitLoc, HitNorm, End, Start, true, vect(16,16,16));
		if (T==None)
			HitLoc = End;

		if (VSize(HitLoc-Start) > 400)
			NVLight.SetLocation(Start + (HitLoc-Start)*0.5);
		else
			NVLight.SetLocation(HitLoc + HitNorm*30);
	}
	else
		SetNVLight(false);

	if (!bScopeView || Role < Role_Authority)
		return;

	Start = Instigator.Location + Instigator.EyePosition();
	BestAim = 0.995;
	Targ = Instigator.Controller.PickTarget(BestAim, BestDist, Vector(Instigator.GetViewRotation()), Start, 20000);
	if (Targ != None)
	{
		if (Targ != Target)
		{
			Target = Targ;
			TargetTime = 0;
		}
		else if (Vehicle(Targ) != None)
			TargetTime += 1.2 * DT * (BestAim-0.95) * 20;
		else
			TargetTime += DT * (BestAim-0.95) * 20;
	}
	else
	{
		TargetTime = FMax(0, TargetTime - DT * 0.5);
	}

}

function AdjustPlayerDamage( out int Damage, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	Target = None;
	TargetTime = 0;
	super.AdjustPlayerDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
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

    	if (bThermal)
		DrawThermalMode(Canvas);

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
/*
	Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - (Canvas.SizeY*ImageScaleRatio))/2, Canvas.SizeY, 0, 0, 1, 1);

	Canvas.SetPos((Canvas.SizeX - (Canvas.SizeY*ImageScaleRatio))/2, Canvas.OrgY);
	Canvas.DrawTile(ScopeViewTex, (Canvas.SizeY*ImageScaleRatio), Canvas.SizeY, 0, 0, 1024, 1024);

	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - (Canvas.SizeY*ImageScaleRatio))/2, Canvas.OrgY);
	Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - (Canvas.SizeY*ImageScaleRatio))/2, Canvas.SizeY, 0, 0, 1, 1);
*/
	if (bThermal)
	{
    		Canvas.DrawTile(Texture'BWBP_SKC_TexExp.MARS.MARS-ScopeRed', (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1);

        	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(Texture'BWBP_SKC_TexExp.MARS.MARS-ScopeRed', Canvas.SizeY, Canvas.SizeY, 0, 0, 1024, 1024);

        	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(Texture'BWBP_SKC_TexExp.MARS.MARS-ScopeRed', (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1);
	}
	else if (bMeatVision)
	{
    		Canvas.DrawTile(Texture'BWBP_SKC_TexExp.MARS.MARS-ScopeTarget', (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1);

        	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(Texture'BWBP_SKC_TexExp.MARS.MARS-ScopeTarget', Canvas.SizeY, Canvas.SizeY, 0, 0, 1024, 1024);

        	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(Texture'BWBP_SKC_TexExp.MARS.MARS-ScopeTarget', (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1);
	}
	else
	{
    		Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1);

        	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, Canvas.SizeY, Canvas.SizeY, 0, 0, 1024, 1024);

        	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1);
	}
		
	if (bMeatVision)
		DrawMeatVisionMode(Canvas);
}


simulated event Timer()
{
	if (bUpdatePawns)
		UpdatePawnList();
	else
		super.Timer();
}
simulated function UpdatePawnList()
{
	local Pawn P;
	local int i;
	local float Dist;

	PawnList.Length=0;
	ForEach DynamicActors( class 'Pawn', P)
	{
		PawnList[PawnList.length] = P;
		Dist = VSize(P.Location - Instigator.Location);
		if (Dist <= ThermalRange &&
			( Normal(P.Location-(Instigator.Location+Instigator.EyePosition())) Dot Vector(Instigator.GetViewRotation()) > 1-((Instigator.Controller.FovAngle*0.9)/180) ) &&
			((Instigator.LineOfSightTo(P)) || Normal(P.Location - Instigator.Location) Dot Vector(Instigator.GetViewRotation()) > 0.985 + 0.015 * (Dist/ThermalRange)))
		{
			if (!Instigator.IsLocallyControlled())
			{
				P.NetUpdateTime = Level.TimeSeconds - 1;
				P.bAlwaysRelevant = true;
			}
			UpdatedPawns[i]=P;
			i++;
		}
	}
}

function ServerSetScopeView(bool bNewValue)
{
	super.ServerSetScopeView(bNewValue);
	if (!bScopeView)
	{
		Target = None;
		TargetTime=0;
	}
}
simulated function SetScopeView(bool bNewValue)
{
	bScopeView = bNewValue;
	if (!bScopeView)
	{
		Target = None;
		TargetTime=0;
	}
	if (Level.NetMode == NM_Client)
		ServerSetScopeView(bNewValue);
	bScopeView = bNewValue;
	SetScopeBehavior();

	if (!bNewValue && Target != None)
		class'BUtil'.static.PlayFullSound(self, NVOffSound);
}

// Change some properties when using sights...
simulated function SetScopeBehavior()
{
	super.SetScopeBehavior();

	bUseNetAim = bScopeView;
	if (bScopeView)
	{
     		RecoilDeclineTime=1.000000;
     		RecoilDeclineDelay=0.200000;
	}
	else
	{
     		RecoilDeclineTime=default.RecoilDeclineTime;
     		RecoilDeclineDelay=default.RecoilDeclineDelay;
	}
}


// draws red blob that moves, scanline, and target boxes.
simulated event DrawMeatVisionMode (Canvas C)
{
	local Vector V, V2, V3, X, Y, Z;
	local float ScaleFactor;


	// Draw RED stuff
	C.Style = ERenderStyle.STY_Modulated;
	C.SetPos((C.SizeX - C.SizeY)/2, C.OrgY);
	C.SetDrawColor(255,255,255,255);
	C.DrawTile(FinalBlend'BWBP_SKC_TexExp.MARS.F2000TargetFinal', (C.SizeY*1.3333333) * 0.75, C.SizeY, 0, 0, 1024, 1024);

	// Draw some panning lines
	C.SetPos(C.OrgX, C.OrgY);
	C.DrawTile(FinalBlend'BallisticUI2.M75.M75LinesFinal', C.SizeX, C.SizeY, 0, 0, 512, 512);

    C.Style = ERenderStyle.STY_Alpha;
	
	if (Target == None)
		return;

	// Draw Target Boxers
	ScaleFactor = C.ClipX / 1600;
	GetViewAxes(X, Y, Z);
	V  = C.WorldToScreen(Target.Location - Y*Target.CollisionRadius + Z*Target.CollisionHeight);
	V.X -= 32*ScaleFactor;
	V.Y -= 32*ScaleFactor;
	C.SetPos(V.X, V.Y);
	V2 = C.WorldToScreen(Target.Location + Y*Target.CollisionRadius - Z*Target.CollisionHeight);
	C.SetDrawColor(160,185,200,255);
      C.DrawTileStretched(Texture'BWBP_SKC_Tex.X82.X82Targetbox', (V2.X - V.X) + 32*ScaleFactor, (V2.Y - V.Y) + 32*ScaleFactor);

    V3 = C.WorldToScreen(Target.Location - Z*Target.CollisionHeight);
}



// Draws players through walls and all the other Thermal Mode stuff
simulated event DrawThermalMode (Canvas C)
{
	local Pawn P;
	local int i, j;
	local float Dist, DotP, ImageScaleRatio;//, OtherRatio;
	local Array<Material>	OldSkins;
	local int OldSkinCount;
	local bool bLOS, bFocused;
	local vector Start;
	local Array<Material>	AttOldSkins0;
	local Array<Material>	AttOldSkins1;

	ImageScaleRatio = 1.3333333;

	C.Style = ERenderStyle.STY_Modulated;
	// Draw Spinning Sweeper thing
	C.SetPos((C.SizeX - C.SizeY)/2, C.OrgY);
	C.SetDrawColor(255,255,255,255);
	C.DrawTile(FinalBlend'BWBP_SKC_TexExp.MARS.F2000IRNVFinal', (C.SizeY*ImageScaleRatio) * 0.75, C.SizeY, 0, 0, 1024, 1024);
	/*// Draw Expanding Circle thing 
	C.SetPos((C.SizeX - C.SizeY)/2, C.OrgY);
	C.DrawTile(FinalBlend'BallisticUI2.M75.M75RadarFinal', (C.SizeY*ImageScaleRatio) * 0.75, C.SizeY, 0, 0, 1024, 1024);
	// Draw some panning lines
	C.SetPos(C.OrgX, C.OrgY);
	C.DrawTile(FinalBlend'BallisticUI2.M75.M75LinesFinal', C.SizeX, C.SizeY, 0, 0, 512, 512); */

	if (ColorMod == None)
		return;
	// Draw the players with an orange effect
	C.Style = ERenderStyle.STY_Alpha;
	Start = Instigator.Location + Instigator.EyePosition();
	for (j=0;j<PawnList.length;j++)
	{
		if (PawnList[j] != None && PawnList[j] != Level.GetLocalPlayerController().Pawn)
		{
			P = PawnList[j];
			bFocused=false;
			bLos=false;
			ThermalRange = default.ThermalRange + 2000 * FMin(1, VSize(P.Velocity) / 450);
			Dist = VSize(P.Location - Instigator.Location);
			if (Dist > ThermalRange)
				continue;
			DotP = Normal(P.Location - Start) Dot Vector(Instigator.GetViewRotation());
			if ( DotP < Cos((Instigator.Controller.FovAngle/1.7) * 0.017453) )
				continue;
			// If we have a clear LOS then they can be drawn
			if (Instigator.LineOfSightTo(P))
				bLOS=true;
			if (bLOS)
			{
				DotP = (DotP-0.6) / 0.4;

				DotP = FMax(DotP, 0);

				if (Dist < 500)
					ColorMod.Color.R = DotP * 255.0;
				else
					ColorMod.Color.R = DotP * ( 255 - FClamp((Dist-500)/((ThermalRange-500)*0.8), 0, 1) * 255 );
				ColorMod.Color.G = DotP * ( 128.0 - (Dist/ThermalRange)*96.0 );

				// Remember old skins, set new skins, turn on unlit...
				OldSkinCount = P.Skins.length;
				for (i=0;i<Max(2, OldSkinCount);i++)
				{	if (OldSkinCount > i) OldSkins[i] = P.Skins[i]; else OldSkins[i]=None;	P.Skins[i] = ColorMod;	}
				P.bUnlit=true;

				for (i=0;i<P.Attached.length;i++)
					if (P.Attached[i] != None)
					{
						if (Pawn(P.Attached[i]) != None || ONSWeapon(P.Attached[i]) != None/* || InventoryAttachment(P.Attached[i])!= None*/)
						{
							if (P.Attached[i].Skins.length > 0)
							{	AttOldSkins0[i] = P.Attached[i].Skins[0];	P.Attached[i].Skins[0] = ColorMod;	}
							else
							{	AttOldSkins0[i] = None;	P.Attached[i].Skins[0] = ColorMod;	}
							if (P.Attached[i].Skins.length > 1)
							{	AttOldSkins1[i] = P.Attached[i].Skins[1];	P.Attached[i].Skins[1] = ColorMod;	}
							if (P.Attached[i].Skins.length > 1)
							{	AttOldSkins1[i] = None;	P.Attached[i].Skins[1] = ColorMod;	}
						}
						else
							P.Attached[i].SetDrawType(DT_None);
					}

				C.DrawActor(P, false, true);

				// Set old skins back, Unlit off
				P.Skins.length = OldSkinCount;
				for (i=0;i<P.Skins.length;i++)
					P.Skins[i] = OldSkins[i];
				P.bUnlit=false;

				for (i=0;i<P.Attached.length;i++)
					if (P.Attached[i] != None)
					{
						if (Pawn(P.Attached[i]) != None || ONSWeapon(P.Attached[i]) != None/* || InventoryAttachment(P.Attached[i])!= None*/)
						{
							if (AttOldSkins1[i] == None)
							{
								if (AttOldSkins0[i] == None)
									P.Attached[i].Skins.length = 0;
								else
								{
									P.Attached[i].Skins.length = 1;
									P.Attached[i].Skins[0] = AttOldSkins0[i];
								}
							}
							else
							{
								P.Attached[i].Skins[0] = AttOldSkins0[i];
								P.Attached[i].Skins[1] = AttOldSkins1[i];
							}
						}
						else
							P.Attached[i].SetDrawType(P.Attached[i].default.DrawType);
					}
				AttOldSkins0.length = 0;
				AttOldSkins1.length = 0;
			}
			else
				continue;
		}
	}
}



simulated function AdjustThermalView(bool bNewValue)
{
	if (AIController(Instigator.Controller) != None)
		return;
	if (!bNewValue)
	{
		bUpdatePawns = false;
//		SetTimer(0.0, false);
	}
	else
	{
		bUpdatePawns = true;
		UpdatePawnList();
		SetTimer(1.0, true);
	}
	ServerAdjustThermal(bNewValue);
}
function ServerAdjustThermal(bool bNewValue)
{
	local int i;
//	bThermal = bNewValue;
	if (bNewValue)
	{
		bUpdatePawns = true;
		UpdatePawnList();
		SetTimer(1.0, true);
	}
	else
	{
		bUpdatePawns = false;
//		SetTimer(0.0, false);
		for (i=0;i<ArrayCount(UpdatedPawns);i++)
		{
			if (UpdatedPawns[i] != None)
				UpdatedPawns[i].bAlwaysRelevant = false;
		}
	}
}




//simulated function DoWeaponSpecial(optional byte i)
exec simulated function WeaponSpecial(optional byte i)
{

	if (bScopeView)
	{
		if (!bThermal && !bMeatVision) //Nothing on, turn on IRNV!
		{
			bThermal = !bThermal;
			if (bThermal)
    				class'BUtil'.static.PlayFullSound(self, ThermalOnSound);
			else
    				class'BUtil'.static.PlayFullSound(self, ThermalOffSound);
			AdjustThermalView(bThermal);
			return;
		}
		if (bThermal && !bMeatVision) //IRNV on! turn it off and turn on targeting!
		{
			bThermal = !bThermal;
			if (bThermal)
    				class'BUtil'.static.PlayFullSound(self, ThermalOnSound);
			else
    				class'BUtil'.static.PlayFullSound(self, ThermalOffSound);
			AdjustThermalView(bThermal);

			bMeatVision = !bMeatVision;
			if (bMeatVision)
    				class'BUtil'.static.PlayFullSound(self, NVOnSound);
			else
    				class'BUtil'.static.PlayFullSound(self, NVOffSound);
			return;
		}
		if (!bThermal && bMeatVision) //targeting on! turn it off!
		{
			bMeatVision = !bMeatVision;
			if (bMeatVision)
    				class'BUtil'.static.PlayFullSound(self, NVOnSound);
			else
    				class'BUtil'.static.PlayFullSound(self, NVOffSound);
			return;
		}
	}
}

//==============================================
//=========== First Draw =======================
//==============================================

simulated function BringUp(optional Weapon PrevWeapon)
{


	if (bFirstDraw && MagAmmo > 0)
	{
     		BringUpTime=1.200000;
     		SelectAnim='FancyPullout';
		bFirstDraw=false;
	}
	else
	{
     		BringUpTime=default.BringUpTime;
		SelectAnim='Pullout';
	}

	if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{
		ReloadAnim = 'ReloadEmpty';
	}
	else
	{
		ReloadAnim = 'Reload';
	}

	Super.BringUp(PrevWeapon);

	if (ColorMod != None)
		return;
	ColorMod = ColorModifier(Level.ObjectPool.AllocateObject(class'ColorModifier'));
	if ( ColorMod != None )
	{
		ColorMod.Material = FinalBlend'BallisticEffects.M75.OrangeFinal';
		ColorMod.Color.R = 255;
		ColorMod.Color.G = 96;
		ColorMod.Color.B = 0;
		ColorMod.Color.A = 255;
		ColorMod.AlphaBlend = false;
		ColorMod.RenderTwoSided=True;
	}
}

//==============================================
//=========== Bullet in mag ====================
//==============================================

simulated function PlayReload()
{
//	if (MagAmmo < 1)
//		SetBoneScale (1, 0.0, 'Bullet');

    if (MagAmmo < 1)
    {
       ReloadAnim='ReloadEmpty';
    }
    else
    {
       ReloadAnim='Reload';
    }
	SafePlayAnim(ReloadAnim, ReloadAnimRate, , 0, "RELOAD");
}
simulated function Notify_ClipOutOfSight()
{
//	SetBoneScale (1, 1.0, 'Bullet');
}


//==============================================
//=========== Camouflage =======================
//==============================================

simulated function AdjustCamoProperties(optional int Index)
{
	local float f;

		f = FRand();

			if ((Index == -1 && f > 0.90) || Index == 2) //10%
			{
				Skins[1]=CamoMaterials[2];
				Skins[3]=CamoMaterials[3];
				CamoIndex=2;
			}
			else if ((Index == -1 && f > 0.75) || Index == 1) // 15%
			{
				Skins[1]=CamoMaterials[1];
				CamoIndex=1;
			}
			else
			{
				Skins[1]=CamoMaterials[0];
				CamoIndex=0;
			}

}

//==============================================
//=========== Light + Garbage Cleanup ==========
//==============================================

simulated event Destroyed()
{
	if (ColorMod != None)
	{
		Level.ObjectPool.FreeObject(ColorMod);
		ColorMod = None;
	}
	AdjustThermalView(false);

	if (NVLight != None)
		NVLight.Destroy();
		
	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = false;

	super.Destroyed();
}

simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		AdjustThermalView(false);
		return true;
	}

	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = false;

	return false;
}


simulated function SetNVLight(bool bOn)
{
	if (!Instigator.IsLocallyControlled())
		return;
	if (bOn)
	{
		if (NVLight == None)
		{
			NVLight = Spawn(class'MARSNVLight',,,Instigator.location);
			NVLight.SetBase(Instigator);
		}
		NVLight.bDynamicLight = true;
	}
	else if (NVLight != None)
		NVLight.bDynamicLight = false;
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
     ThermalOnSound=(Sound=Sound'BallisticSounds2.M75.M75ThermalOn',Volume=0.500000,Pitch=1.000000)
     ThermalOffSound=(Sound=Sound'BallisticSounds2.M75.M75ThermalOff',Volume=0.500000,Pitch=1.000000)
     WallVisionSkin=FinalBlend'BallisticEffects.M75.OrangeFinal'
     Flaretex=FinalBlend'BallisticEffects.M75.OrangeFlareFinal'
     ThermalRange=2500.000000
     NVOnSound=(Sound=Sound'BWBP_SKC_Sounds.AH104.AH104-SightOn',Volume=1.600000,Pitch=0.900000)
     NVOffSound=(Sound=Sound'BWBP_SKC_Sounds.AH104.AH104-SightOff',Volume=1.600000,Pitch=0.900000)

     CamoMaterials[3]=Shader'BWBP_SKC_TexExp.MARS.F2000-LensShineAlt'
     CamoMaterials[2]=Texture'BWBP_SKC_TexExp.MARS.F2000-MainSplitter'
     CamoMaterials[1]=Texture'BWBP_SKC_TexExp.MARS.F2000-MainGreen'
     CamoMaterials[0]=Shader'BWBP_SKC_TexExp.MARS.F2000-Shine'

     PickupTextureIndex=1
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.000000
     BigIconMaterial=Texture'BWBP_SKC_TexExp.MARS.BigIcon_F2000'
     BallisticInventoryGroup=5
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="320.0;25.0;1.0;110.0;0.8;0.5;0.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.M50.M50Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M50.M50Putaway')
     MagAmmo=30
     CockSound=(Sound=Sound'BWBP_SKC_SoundsExp.MARS.MARS-BoltPull',Volume=1.100000)
     ClipHitSound=(Sound=Sound'BWBP_SKC_SoundsExp.MARS.MARS-MagFiddle',Volume=1.400000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.MARS.MARS-MagOut',Volume=1.400000)
     ClipInSound=(Sound=Sound'BWBP_SKC_SoundsExp.MARS.MARS-MagIn',Volume=1.400000)
     ClipInFrame=0.650000
     bNeedCock=False
     bFirstDraw=True
     bNoCrosshairInScope=True
     bCockOnEmpty=False
     BringUpTime=0.600000
     WeaponModes(0)=(ModeName="Semi-Automatic")
     CurrentWeaponMode=2
     ScopeViewTex=Texture'BWBP_SKC_TexExp.MARS.MARS-Scope'
     ZoomInSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomIn',Volume=0.500000,Pitch=1.000000)
     ZoomOutSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomOut',Volume=0.500000,Pitch=1.000000)
     FullZoomFOV=45.000000
	 ZoomType=ZT_Logarithmic
	 ZoomStages=2.000000
     ChaosDeclineTime=0.500000
     ChaosAimSpread=(X=(Min=-2048.000000,Max=2048.000000),Y=(Min=-2048.000000,Max=2048.000000))
     bNoMeshInScope=True
     SightOffset=(X=-5.000000,Y=-7.340000,Z=27.170000)
     SightDisplayFOV=25.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M50OutA',Pic2=Texture'BallisticUI2.Crosshairs.M50InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=0,G=255,R=255,A=134),Color2=(B=0,G=0,R=255,A=255),StartSize1=50,StartSize2=51)
     CrouchAimFactor=0.500000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     ViewAimFactor=0.200000
     	ViewRecoilFactor=0.600000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.300000),(InVal=0.800000,OutVal=-0.400000),(InVal=1.000000,OutVal=-0.200000)))
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYawFactor=0.400000
     RecoilXFactor=0.300000
     RecoilYFactor=0.400000
	RecoilMax=3400
     FireModeClass(0)=Class'BWBP_SKC_Fix.MARSPrimaryFire'
     FireModeClass(1)=Class'BCoreFix.BallisticScopeFire'
     PutDownTime=0.700000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     Description="MARS-2 Assault Rifle||Manufacturer: NDTR Industries|Primary: 5.56mm STN Rifle Rounds|Secondary: Integrated Scope||The 2 variant of the Modular Assault Rifle System is one of many rifles built under NDTR Industries' MARS project. The project, which aimed to produce a successor to the army's current M50 and M30 rifles, has produced a number of functional prototypes. The 2 variant is a sharpshooter model with a longer barrel and an advanced IRNV integral scope. The advanced scope mounted on the MARS-2 can switch between standard, infrared/night vision, and an advanced targeting system to help the user target foes where visibility may be impared. Current tests show the MARS-2 to be reliable and effective, yet expensive."
     Priority=65
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.MARSPickup'
//     PlayerViewOffset=(X=0.500000,Y=12.000000,Z=-18.000000)
     PlayerViewOffset=(X=0.500000,Y=14.000000,Z=-20.000000)
     BobDamping=2.000000
     AttachmentClass=Class'BWBP_SKC_Fix.MARSAttachment'
     IconMaterial=Texture'BWBP_SKC_TexExp.MARS.SmallIcon_F2000'
     IconCoords=(X2=127,Y2=31)
     ItemName="MARS-2 Assault Rifle"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.F2000_FP'
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Shader'BWBP_SKC_TexExp.MARS.F2000-Shine'
     Skins(2)=Shader'BWBP_SKC_TexExp.MARS.F2000-ScopeShine'
     Skins(3)=Shader'BWBP_SKC_TexExp.MARS.F2000-LensShineAlt'
     DrawScale=0.350000
}
