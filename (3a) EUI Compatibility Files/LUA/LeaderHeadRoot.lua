-------------------------------------------------
-- LeaderHeadRoot.lua
-- modified by bc1 from civ5 brave new world and civBE code
-- to add an event when displayed
-- code is common using *_mode switches
-------------------------------------------------
local gk_mode = Game.GetReligionName ~= nil
local bnw_mode = Game.GetActiveLeague ~= nil
local civ5_mode = InStrategicView ~= nil
local civBE_mode = not civ5_mode

include( "InstanceManager" )
include( "GameplayUtilities" )
local GameplayUtilities = GameplayUtilities

include( "EUI_utilities" )
local IconHookup = EUI.IconHookup
local CivIconHookup = EUI.CivIconHookup
--include( "EUI_tooltips" )
local GetMoodInfo = EUI.GetMoodInfo

local g_iAIPlayer = -1;
local g_iAITeam = -1;

local g_DiploUIState = -1;

local g_iRootMode = 0;
local g_iTradeMode = 1;
local g_iDiscussionMode = 2;

local g_strLeaveScreenText = Locale.ConvertTextKey("TXT_KEY_DIPLOMACY_ANYTHING_ELSE");

local offsetOfString = 32;
local bonusPadding = 16
local innerFrameWidth = 654;
local outerFrameWidth = 650;
local offsetsBetweenFrames = 4;

local g_oldCursor = 0;
local g_isAnimateOutComplete = false;
local g_isAnimatingIn = false;
local g_bRootWasShownThisEvent = false;


-- ===========================================================================
--
--	LEADER MESSAGE HANDLER
--	. If this can handle the type of leader message, it triggers show
--	. If it cannot handle the message it hides it's contents (not the context)
--
-- ===========================================================================
function LeaderMessageHandler( iPlayer, iDiploUIState, szLeaderMessage, iAnimationAction, iData1 )

	g_DiploUIState = iDiploUIState;

	g_iAIPlayer = iPlayer;
	g_iAITeam = Players[g_iAIPlayer]:GetTeam();

	local pActivePlayer = Players[Game.GetActivePlayer()];
	local pActiveTeam = Teams[pActivePlayer:GetTeam()];
	if civ5_mode then
		CivIconHookup( iPlayer, 64, Controls.ThemSymbolShadow, Controls.CivIconBG, Controls.CivIconShadow, false, true );
	else
		CivIconHookup( iPlayer, 45, Controls.CivIcon, Controls.CivIconBG, nil, false, false, Controls.CivIconHighlight );
	end

	-- Update title even if we're not in this mode, as we could exit to it somehow
	local player = Players[iPlayer];
	local strTitleText = GameplayUtilities.GetLocalizedLeaderTitle(player);
	Controls.TitleText:SetText(strTitleText);

	playerLeaderInfo = GameInfo.Leaders[player:GetLeaderType()];

	-- Leader head fix for more than 22 civs DLL...
	local leaderTextures = {
		["LEADER_ALEXANDER"] = "alexander.dds",
		["LEADER_ASKIA"] = "askia.dds",
		["LEADER_AUGUSTUS"] = "augustus.dds",
		["LEADER_BISMARCK"] = "bismark.dds",
		["LEADER_CATHERINE"] = "catherine.dds",
		["LEADER_DARIUS"] = "darius.dds",
		["LEADER_ELIZABETH"] = "elizabeth.dds",
		["LEADER_GANDHI"] = "ghandi.dds",
		["LEADER_HARUN_AL_RASHID"] = "alrashid.dds",
		["LEADER_HIAWATHA"] = "hiawatha.dds",
		["LEADER_MONTEZUMA"] = "montezuma.dds",
		["LEADER_NAPOLEON"] = "napoleon.dds",
		["LEADER_ODA_NOBUNAGA"] = "oda.dds",
		["LEADER_RAMESSES"] = "ramesses.dds",
		["LEADER_RAMKHAMHAENG"] = "ramkhamaeng.dds",
		["LEADER_SULEIMAN"] = "sulieman.dds",
		["LEADER_WASHINGTON"] = "washington.dds",
		["LEADER_WU_ZETIAN"] = "wu.dds",
		["LEADER_GENGHIS_KHAN"] = "genghis.dds",
		["LEADER_ISABELLA"] = "isabella.dds",
		["LEADER_PACHACUTI"] = "pachacuti.dds",
		["LEADER_KAMEHAMEHA"] = "kamehameha.dds",
		["LEADER_HARALD"] = "harald.dds",
		["LEADER_SEJONG"] = "sejong.dds",
		["LEADER_NEBUCHADNEZZAR"] = "nebuchadnezzar.dds",
		["LEADER_ATTILA"] = "attila.dds",
		["LEADER_BOUDICCA"] = "boudicca.dds",
		["LEADER_DIDO"] = "dido.dds",
		["LEADER_GUSTAVUS_ADOLPHUS"] = "gustavus adolphus.dds",
		["LEADER_MARIA"] = "mariatheresa.dds",
		["LEADER_PACAL"] = "pacal_the_great.dds",
		["LEADER_THEODORA"] = "theodora.dds",
		["LEADER_SELASSIE"] = "haile_selassie.dds",
		["LEADER_WILLIAM"] = "william_of_orange.dds",		
		["LEADER_SHAKA"] = "Shaka.dds",
		["LEADER_POCATELLO"] = "Pocatello.dds",
		["LEADER_PEDRO"] = "Pedro.dds",
		["LEADER_MARIA_I"] = "Maria_I.dds",
		["LEADER_GAJAH_MADA"] = "Gajah.dds",
		["LEADER_ENRICO_DANDOLO"] = "Dandolo.dds",
		["LEADER_CASIMIR"] = "Casimir.dds",
		["LEADER_ASHURBANIPAL"] = "Ashurbanipal.dds",
		["LEADER_AHMAD_ALMANSUR"] = "Almansur.dds",
	}
	
	if iPlayer > 21 then
		print ("LeaderMessageHandler: Player ID > 21")
		local backupTexture = "loadingbasegame_9.dds"
		if leaderTextures[playerLeaderInfo.Type] then
			backupTexture = leaderTextures[playerLeaderInfo.Type]
		end

		-- get screen and texture size to set the texture on full screen

		Controls.BackupTexture:SetTexture( backupTexture )
		local screenW, screenH = Controls.BackupTexture:GetSizeVal() -- works, but maybe there is a direct way to get screen size ?
			
		Controls.BackupTexture:SetTextureAndResize( backupTexture )
		local textureW, textureH = Controls.BackupTexture:GetSizeVal()	
		
		print ("Screen Width = " .. tostring(screenW) .. ", Screen Height = " .. tostring(screenH) .. ", Texture Width = " .. tostring(textureW) .. ", Texture Height = " .. tostring(textureH))

		local ratioW = screenW / textureW
		local ratioH = screenH / textureH
		
		print ("Width ratio = " .. tostring(ratioW) .. ", Height ratio = " .. tostring(ratioH))

		local ratio = ratioW
		if ratioH > ratioW then
			ratio = ratioH
		end
		Controls.BackupTexture:SetSizeVal( math.floor(textureW * ratio), math.floor(textureH * ratio) )

		Controls.BackupTexture:SetHide( false )
	else
		
		Controls.BackupTexture:UnloadTexture()
		Controls.BackupTexture:SetHide( true )

	end
	-- End of leader head fix
	
	-- Mood
	local iApproach = pActivePlayer:GetApproachTowardsUsGuess(g_iAIPlayer);
	local strMoodText = Locale.ConvertTextKey("TXT_KEY_EMOTIONLESS");

	if (Players[g_iAIPlayer]:IsAlive()) then
		if (not pActivePlayer:IsAlive()) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_NEUTRAL", playerLeaderInfo.Description );
		else
			if (pActiveTeam:IsAtWar(g_iAITeam)) then
				strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR" );
			elseif (Players[g_iAIPlayer]:IsDenouncingPlayer(Game.GetActivePlayer())) then
				strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_DENOUNCING" );
			elseif (Players[g_iAIPlayer]:WasResurrectedThisTurnBy(iActivePlayer)) then
				strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_LIBERATED" );
			else
				if( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_WAR ) then
					strMoodText = Locale.ConvertTextKey( "TXT_KEY_WAR_CAPS" );
				elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE ) then
					strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_HOSTILE", playerLeaderInfo.Description );
				elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED ) then
					strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_GUARDED", playerLeaderInfo.Description );
				elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID ) then
					strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_AFRAID", playerLeaderInfo.Description );
				elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY ) then
					strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_FRIENDLY", playerLeaderInfo.Description );
				else
					strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_NEUTRAL", playerLeaderInfo.Description );
				end
			end
		end
	end

	Controls.MoodText:SetText(strMoodText);
	Controls.MoodText:SetToolTipString( GetMoodInfo(g_iAIPlayer) );

-- CBP
	-- Warscore
	if (pActiveTeam:IsAtWar(g_iAITeam)) then
		Controls.WarScore:SetHide(false);
		local iWarScore = pActivePlayer:GetWarScore(g_iAIPlayer);
		local strWarScore = Locale.ConvertTextKey("TXT_KEY_WAR_SCORE", iWarScore);

		Controls.WarScore:SetText(strWarScore);
	
		local strWarInfo = Locale.ConvertTextKey("TXT_KEY_WAR_SCORE_EXPLANATION");

		if(Players[g_iAIPlayer]:IsWantsPeaceWithPlayer(Game.GetActivePlayer())) then
			local iPeaceValue = Players[g_iAIPlayer]:GetTreatyWillingToOffer(Game.GetActivePlayer());
			if(iPeaceValue >  PeaceTreatyTypes.PEACE_TREATY_WHITE_PEACE) then
				if( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_ARMISTICE ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_OFFER_PEACE_TREATY_ARMISTICE" );
				elseif( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_SETTLEMENT ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_OFFER_PEACE_TREATY_SETTLEMENT" );
				elseif( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_BACKDOWN ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_OFFER_PEACE_TREATY_BACKDOWN" );
				elseif( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_SUBMISSION ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_OFFER_PEACE_TREATY_SUBMISSION" );
				elseif( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_SURRENDER ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_OFFER_PEACE_TREATY_SURRENDER" );
				elseif( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_CESSION ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_OFFER_PEACE_TREATY_CESSION" );
				elseif( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_CAPITULATION ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_OFFER_PEACE_TREATY_CAPITULATION" );
				elseif( iPeaceValue == PeaceTreatyTypes.PEACE_TREATY_UNCONDITIONAL_SURRENDER ) then
					strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_OFFER_PEACE_TREATY_UNCONDITIONAL_SURRENDER" );
				end
			end
		else
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_NO_PEACE_OFFER" );
		end

		local iStrengthAverage = pActivePlayer:GetMilitaryStrengthComparedToUs(g_iAIPlayer);
		if( iStrengthAverage == StrengthTypes.STRENGTH_PATHETIC ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_STRENGTH_PATHETIC" );
		elseif( iStrengthAverage == StrengthTypes.STRENGTH_WEAK ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_STRENGTH_WEAK" );
		elseif( iStrengthAverage == StrengthTypes.STRENGTH_POOR ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_STRENGTH_POOR" );
		elseif( iStrengthAverage == StrengthTypes.STRENGTH_AVERAGE ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_STRENGTH_AVERAGE" );
		elseif( iStrengthAverage == StrengthTypes.STRENGTH_STRONG ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_STRENGTH_STRONG" );
		elseif( iStrengthAverage == StrengthTypes.STRENGTH_POWERFUL ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_STRENGTH_POWERFUL" );
		elseif( iStrengthAverage == StrengthTypes.STRENGTH_IMMENSE ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_STRENGTH_IMMENSE" );
		end

		local iEconomicAverage = pActivePlayer:GetEconomicStrengthComparedToUs(g_iAIPlayer);
		if( iEconomicAverage == StrengthTypes.STRENGTH_PATHETIC ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_ECONOMY_PATHETIC" );
		elseif( iEconomicAverage == StrengthTypes.STRENGTH_WEAK ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_ECONOMY_WEAK" );
		elseif( iEconomicAverage == StrengthTypes.STRENGTH_POOR ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_ECONOMY_POOR" );
		elseif( iEconomicAverage == StrengthTypes.STRENGTH_AVERAGE ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_ECONOMY_AVERAGE" );
		elseif( iEconomicAverage == StrengthTypes.STRENGTH_STRONG ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_ECONOMY_STRONG" );
		elseif( iEconomicAverage == StrengthTypes.STRENGTH_POWERFUL ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_ECONOMY_POWERFUL" );
		elseif( iEconomicAverage == StrengthTypes.STRENGTH_IMMENSE ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_ECONOMY_IMMENSE" );
		end

		local iOurWarDamage = pActivePlayer:GetWarDamageValue(g_iAIPlayer);
		local iTheirWarDamage = Players[g_iAIPlayer]:GetWarDamageValue(Game.GetActivePlayer());
		local iTotal = iTheirWarDamage - iOurWarDamage;

		if (iTotal > 0) then
			if (iTotal >= GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_CRIPPLED) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_DAMAGE_THEM_CRIPPLED" );
			elseif (iTotal >= GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_SERIOUS) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_DAMAGE_THEM_SERIOUS" );
			elseif (iTotal >= GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_MAJOR) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_DAMAGE_THEM_MAJOR" );
			elseif (iTotal >= GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_MINOR) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_DAMAGE_THEM_MINOR" );
			end
		elseif (iTotal < 0) then
			if (iTotal <= -GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_CRIPPLED) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_DAMAGE_US_CRIPPLED" );
			elseif (iTotal <= -GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_SERIOUS) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_DAMAGE_US_SERIOUS" );
			elseif (iTotal <= -GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_MAJOR) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_DAMAGE_US_MAJOR" );
			elseif (iTotal <= -GameDefines.WAR_DAMAGE_LEVEL_THRESHOLD_MINOR) then
				strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_DAMAGE_US_MINOR" );
			end
		end

		local iTheirWarWeariness = Players[g_iAIPlayer]:GetHighestWarWearinessPercent();
		if(iTheirWarWeariness <= 0)then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_WEARINESS_THEM_NONE" );
		elseif( iTheirWarWeariness <= 25 ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_WEARINESS_THEM_MINOR" );
		elseif( iTheirWarWeariness <= 50 ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_WEARINESS_THEM_MAJOR" );
		elseif( iTheirWarWeariness <= 75 ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_WEARINESS_THEM_SERIOUS" );
		elseif( iTheirWarWeariness > 75 ) then
			strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey( "TXT_KEY_WAR_WEARINESS_THEM_CRIPPLED" );
		end

		local iOurWarWeariness = pActivePlayer:GetWarWearinessPercent(g_iAIPlayer);
		strWarInfo = strWarInfo .. '[NEWLINE]' .. Locale.ConvertTextKey("TXT_KEY_WAR_WEARINESS_US_PERCENT", iOurWarWeariness);

		Controls.WarScore:SetToolTipString(strWarInfo);
	else
		Controls.WarScore:SetHide(true);
	end
	-- END

	-- Whether it's handled here or in a leaderhead sub-screen, the root context should be visible if a
	-- leaderhead message is coming through...
	-- If animations need to kick off (coming from InGame) let that be signaled by the transition manager.
	if civBE_mode and ContextPtr:IsHidden() then
		ContextPtr:SetHide( false );
	end

	-- Is this a mode that this screen can handle?
	if g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DEFAULT_ROOT
		or iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_WAR_DECLARED_BY_HUMAN
		or iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_PEACE_MADE_BY_HUMAN
	then
		UI.SetLeaderHeadRootUp( true );
		Controls.LeaderSpeech:SetText( szLeaderMessage );

		if civ5_mode then
			-- Resize the height of the box to fit the text
			local contentSize = Controls.LeaderSpeech:GetSizeY() + offsetOfString + bonusPadding;
			Controls.LeaderSpeechBorderFrame:SetSizeY( contentSize );
			Controls.LeaderSpeechFrame:SetSizeY( contentSize - offsetsBetweenFrames );
		elseif Controls.RootOptions:IsHidden() then
			g_bRootWasShownThisEvent = true;
			Controls.RootOptions:SetHide( false );
		end

	else
		if civBE_mode then
			-- Hide the contents of the page, as another screen is handling it.
			Controls.RootOptions:SetHide( true );
		end
		Controls.LeaderSpeech:SetText( g_strLeaveScreenText );		-- Seed the text box with something reasonable so that we don't get leftovers from somewhere else

	end

	-- While leaderheadroot is a root context, it is necessary to invoke this as a popup
	-- so that any other pop-ups are dismissed.
	UIManager:QueuePopup( ContextPtr, PopupPriority.LeaderHead );

end
Events.AILeaderMessage.Add( LeaderMessageHandler );


-- ===========================================================================
--	Request from use to close; either a button or the keyboard.
-- ===========================================================================
function OnClose()
	if civ5_mode then
		UIManager:DequeuePopup( ContextPtr );
	end
	UI.SetLeaderHeadRootUp( false );
	UI.RequestLeaveLeader();
end
Controls.BackButton:RegisterCallback( Mouse.eLClick, OnClose );
OnReturn = OnClose --compatibility

function OnLeavingLeader()
	-- we shouldn't be able to leave without this already being set to false,
	-- but just in case...
	UI.SetLeaderHeadRootUp( false );
	if civ5_mode then
		UIManager:DequeuePopup( ContextPtr );
	else
		g_bRootWasShownThisEvent = false;
		g_DiploUIState = DiploUIStateTypes.NO_DIPLO_UI_STATE;
	end
end
Events.LeavingLeaderViewMode.Add( OnLeavingLeader );


-- ===========================================================================
function UpdateDisplay()

	local pActivePlayer = Players[Game.GetActivePlayer()];
	local pActiveTeam = Teams[Game.GetActiveTeam()];

	-- Hide or show war/peace and demand buttons
	if (Game.GetActiveTeam() == g_iAITeam) then
		Controls.WarButton:SetHide(true);
		Controls.DemandButton:SetHide(true);
	elseif (not pActivePlayer:IsAlive()) then
		Controls.WarButton:SetHide(true);
		Controls.DemandButton:SetHide(true);
	else
		Controls.WarButton:SetHide(false);
		Controls.DemandButton:SetHide(false);
	end

	-- Discussion is always valid, but there may be nothing to say
	Controls.DiscussButton:SetDisabled(false);

	g_oldCursor = UIManager:SetUICursor(0); -- make sure we start with the default cursor

	if (g_iAITeam ~= -1 and g_iAIPlayer ~= -1) then
		if (pActiveTeam:IsAtWar(g_iAITeam)) then
			Controls.WarButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE" ));
			Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE_TT" ));
			Controls.TradeButton:SetDisabled(true);
			Controls.DemandButton:SetDisabled(true);
			Controls.DemandButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DEMAND_BUTTON" ));
			Controls.DemandButton:SetToolTipString(nil);

			if (pActiveTeam:CanChangeWarPeace(g_iAITeam) and not Teams[g_iAITeam]:IsVassalLockedIntoWar(Game.GetActiveTeam())) then
				Controls.WarButton:SetDisabled(false);
			else
				Controls.WarButton:SetDisabled(true);

				if (pActiveTeam:IsVassalLockedIntoWar(g_iAITeam)) then
					Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE_VASSAL_BLOCKED_TT" ));
				elseif (Teams[g_iAITeam]:IsVassalLockedIntoWar(Game.GetActiveTeam())) then
					local iMaster = Teams[g_iAITeam]:GetMaster();
					if (iMaster ~= -1) then
						local pMaster = Teams[iMaster];
						Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_MAKE_PEACE_VASSAL", pMaster:GetName() ));
					end
				else
					local iLockedTurnsUs = pActiveTeam:GetNumTurnsLockedIntoWar(g_iAITeam);
					local iLockedTurnsThem = Teams[g_iAITeam]:GetNumTurnsLockedIntoWar(Game.GetActiveTeam());

					if (iLockedTurnsUs ~= 0) then
						Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE_BLOCKED_TT", iLockedTurnsUs ));
					elseif (iLockedTurnsThem ~= 0) then
						Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE_BLOCKED_THEM_TT", iLockedTurnsThem ));
					else
						Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE_BLOCKED_MOD_TT" ));
					end
				end
			end
		else
			Controls.WarButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DECLARE_WAR" ));
			Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DECLARES_WAR_TT" ));
			Controls.TradeButton:SetDisabled(false);
			Controls.DemandButton:SetDisabled(false);

			if (pActivePlayer:IsDoF(g_iAIPlayer)) then
				Controls.DemandButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_REQUEST_HELP_BUTTON" ));
				Controls.DemandButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_REQUEST_HELP_BUTTON_TT" ));
			else
				Controls.DemandButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DEMAND_BUTTON" ));
				Controls.DemandButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DEMAND_BUTTON_TT" ));
			end

			if (pActiveTeam:CanDeclareWar(g_iAITeam)) then
				Controls.WarButton:SetDisabled(false);
			else
				Controls.WarButton:SetDisabled(true);

				if (pActiveTeam:IsVassalOfSomeone()) then
					if (pActiveTeam:IsVassal(g_iAIPlayer)) then
						Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DECLARE_WAR_VASSAL_BLOCKED_MASTER_TT" ));
					else
						Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DECLARE_WAR_VASSAL_BLOCKED_TT" ));
					end
				elseif (pActiveTeam:IsForcePeace(g_iAITeam)) then
					Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_ATTACK" ));
				elseif (pActiveTeam:IsWarBlockedByPeaceTreaty(g_iAITeam)) then
					Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_ATTACK_DP" ));
				else
					Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_ATTACK_MOD" ));
				end
			end

		end
	end
	if civBE_mode then
		Controls.TalkOptionStack:CalculateSize();
		Controls.TalkOptionStack:ReprocessAnchoring();
	end
end

----------------------------------------------------------------
-- ===========================================================================
--	SHOW/HIDE
-- ===========================================================================
function OnShowHide( isHide, isInit )
	if isInit then
		if civBE_mode then
			-- set blackbar based on %
			local screenWidth, screenHeight = UIManager:GetScreenSizeVal();
			local blackBarTopSize			= (screenHeight * .20) / 2;		-- slightly less, male model's head is cropped otherwise in min-spec
			local blackBarBottomSize		= (screenHeight * .26) / 2;
			Controls.BlackBarTop:SetSizeY( blackBarTopSize );
			Controls.BlackBarBottom:SetSizeY( blackBarBottomSize );
			Controls.AnimBarTop:SetBeginVal(0, -blackBarTopSize);
			Controls.AnimBarBottom:SetBeginVal(0, blackBarBottomSize);
		end
	elseif isHide then
		-- Hiding Screen
		UIManager:SetUICursor(g_oldCursor); -- make sure we retrun the cursor to the previous state
		-- Do not attempt to set default leader text here; it's possible for this same screen to be queued.
	else
		-- Showing Screen
		LuaEvents.EUILeaderHeadRoot()
		if civ5_mode then
			Controls.RootOptions:SetHide( not UI.GetLeaderHeadRootUp() );
		end
		UpdateDisplay();
	end
end
ContextPtr:SetShowHideHandler( OnShowHide );


-- ===========================================================================
-- Key Down Processing
-- ===========================================================================
function InputHandler( uiMsg, wParam, lParam )
	if( uiMsg == KeyEvents.KeyDown )
	then
		if( wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN ) then
			if bnw_mode or Controls.WarConfirm:IsHidden() then
				OnClose();
			else
				Controls.WarConfirm:SetHide(true);
			end
		end
	end
	return true;
end
ContextPtr:SetInputHandler( InputHandler );




-- ===========================================================================
function OnDiscuss()
	Controls.LeaderSpeech:SetText( g_strLeaveScreenText );		-- Seed the text box with something reasonable so that we don't get leftovers from somewhere else

	Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_WANTS_DISCUSSION, g_iAIPlayer, 0, 0 );
end
Controls.DiscussButton:RegisterCallback( Mouse.eLClick, OnDiscuss );


-- ===========================================================================
function OnTrade()
	-- This calls into CvDealAI and sets up the initial state of the UI
	Players[g_iAIPlayer]:DoTradeScreenOpened();

	Controls.LeaderSpeech:SetText( g_strLeaveScreenText );		-- Seed the text box with something reasonable so that we don't get leftovers from somewhere else

	UI.OnHumanOpenedTradeScreen(g_iAIPlayer);
end
Controls.TradeButton:RegisterCallback( Mouse.eLClick, OnTrade );


-- ===========================================================================
function OnDemand()

	Controls.LeaderSpeech:SetText( g_strLeaveScreenText );		-- Seed the text box with something reasonable so that we don't get leftovers from somewhere else

	UI.OnHumanDemand(g_iAIPlayer);
end
Controls.DemandButton:RegisterCallback( Mouse.eLClick, OnDemand );


-- ===========================================================================
function OnWarOrPeace()

	local bAtWar = Teams[Game.GetActiveTeam()]:IsAtWar(g_iAITeam);

	-- Asking for Peace (currently at war) - bring up the trade screen
	if (bAtWar) then
		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_NEGOTIATE_PEACE, g_iAIPlayer, 0, 0 );

	-- Declaring War (currently at peace)
	elseif bnw_mode then
		UI.AddPopup{ Type = ButtonPopupTypes.BUTTONPOPUP_DECLAREWARMOVE, Data1 = g_iAITeam, Option1 = true};
	else
		Controls.WarConfirm:SetHide(false);
	end

end
Controls.WarButton:RegisterCallback( Mouse.eLClick, OnWarOrPeace );


-- ===========================================================================
function WarStateChangedHandler( iTeam1, iTeam2, bWar )

	-- Active player changed war state with this AI
	if (iTeam1 == Game.GetActiveTeam() and iTeam2 == g_iAITeam) then

		if (bWar) then
			Controls.WarButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE" ));
			Controls.TradeButton:SetDisabled(true);
			Controls.DemandButton:SetDisabled(true);
			Controls.DemandButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DEMAND_BUTTON" ));
			Controls.DemandButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DEMAND_BUTTON_TT" ));
			Controls.DiscussButton:SetDisabled(false);
		else
			Controls.WarButton:SetText(Locale.ConvertTextKey( "TXT_KEY_DIPLO_DECLARE_WAR" ));
			Controls.TradeButton:SetDisabled(false);
			Controls.DemandButton:SetDisabled(false);
			Controls.DiscussButton:SetDisabled(false);
		end

	end

end
Events.WarStateChanged.Add( WarStateChangedHandler );

if not bnw_mode then
	function OnYes( )
		Controls.WarConfirm:SetHide(true);

		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_DECLARES_WAR, g_iAIPlayer, 0, 0 );
	end
	Controls.Yes:RegisterCallback( Mouse.eLClick, OnYes );

	function OnNo( )
		Controls.WarConfirm:SetHide(true);
	end
	Controls.No:RegisterCallback( Mouse.eLClick, OnNo );
end
---------------------------------------------------------------------------------------
-- Support for Modded Add-in UI's
---------------------------------------------------------------------------------------
g_uiAddins = {};
for addin in Modding.GetActivatedModEntryPoints("DiplomacyUIAddin") do
	local addinFile = Modding.GetEvaluatedFilePath(addin.ModID, addin.Version, addin.File);
	local addinPath = addinFile.EvaluatedPath;

	-- Get the absolute path and filename without extension.
	local extension = Path.GetExtension(addinPath);
	local path = string.sub(addinPath, 1, #addinPath - #extension);

	table.insert(g_uiAddins, ContextPtr:LoadNewContext(path));
end

if civBE_mode then
	-- ===========================================================================
	--	Animate all controls for when the screen first comes up
	--	Kicked off by the game engine
	-- ===========================================================================
	function OnAnimateIn()

		if g_isAnimatingIn then
			return;
		end

		-- Reset
		g_isAnimatingIn = true;
		Controls.AnimBarTop:RegisterAnimCallback( function() end );
		Controls.AnimBarBottom:RegisterAnimCallback( function() end );
		Controls.GamestateTransitionAnimOut:SetToBeginning();

		Controls.AnimBarTop:SetToBeginning();
		Controls.AnimBarBottom:SetToBeginning();
		Controls.AnimAlphaTop:SetToBeginning();
		Controls.AnimAlphaBottom:SetToBeginning();

		Controls.AnimBarTop:Play();
		Controls.AnimBarBottom:Play();
		Controls.AnimAlphaTop:Play();
		Controls.AnimAlphaBottom:Play();
		Controls.BackButton:SetDisabled( false );
	end
	Controls.GamestateTransitionAnimIn:RegisterAnimCallback( OnAnimateIn );

	-- ===========================================================================
	--	Animate all controls for when the screen is being dismissed
	-- ===========================================================================
	function OnAnimateOut()

		-- Reset variables for next animation in.
		g_isAnimatingIn			= false;
		g_isAnimateOutComplete	= false;
		Controls.GamestateTransitionAnimIn:SetToBeginning();

		-- Play controls backwards

		Controls.AnimBarTop:Reverse();
		Controls.AnimBarTop:Play();
		Controls.AnimBarTop:RegisterAnimCallback( OnUpdateAnimate );

		Controls.AnimBarBottom:Reverse();
		Controls.AnimBarBottom:Play();
		Controls.AnimBarBottom:RegisterAnimCallback( OnUpdateAnimate );

		Controls.AnimAlphaTop:Reverse();
		Controls.AnimAlphaTop:Play();

		Controls.AnimAlphaBottom:Reverse();
		Controls.AnimAlphaBottom:Play();

		Controls.BackButton:SetDisabled( true );
	end
	Controls.GamestateTransitionAnimOut:RegisterAnimCallback( OnAnimateOut );

	-- ===========================================================================
	--	Callback, per-frame, for animation
	-- ===========================================================================
	function OnUpdateAnimate()
		if ( Controls.AnimBarTop:IsStopped() and Controls.AnimBarBottom:IsStopped() ) then
			OnAnimateOutComplete();
		end
	end

	-- ===========================================================================
	--	Called once when completed animating out
	-- ===========================================================================
	function OnAnimateOutComplete()
		if g_isAnimateOutComplete then
			return;
		end

		g_isAnimateOutComplete	= true;
		ContextPtr:SetHide( true );
		UIManager:DequeuePopup( ContextPtr );
	end


	-- ===========================================================================
	--	Raised from sub-screens when they are closed
	-- ===========================================================================
	function OnLeaderheadPopupClosed()

		-- If the popup screen was raised through the menu, just bring the menu (root) options back
		-- otherwise dismiss the whole leaderhead system because the pop-up was directly invoked.
		if g_bRootWasShownThisEvent then
			Controls.RootOptions:SetHide( false );
		else
			UI.SetLeaderHeadRootUp( false );
			UI.RequestLeaveLeader();
		end
	end
	LuaEvents.LeaderheadPopupClosed.Add( OnLeaderheadPopupClosed );


	-- ===========================================================================
	--	Raised from sub-screens as they exit (e.g., Trade logic)
	-- ===========================================================================
	function OnLeaderheadShow()
		-- If this wasn't shown, ignore the event as it may be raised by shared
		-- subscreend (e.g., tradelogic in multiplayer.)
		if g_bRootWasShownThisEvent then
			Controls.RootOptions:SetHide( false );
			ContextPtr:SetHide( false );
		else
			LuaEvents.LeaderheadPopupClosed();
		end
	end
	LuaEvents.LeaderheadRootShow.Add( OnLeaderheadShow );
end