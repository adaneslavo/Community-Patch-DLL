/*	-------------------------------------------------------------------------------------------------------
	� 1991-2012 Take-Two Interactive Software and its subsidiaries.  Developed by Firaxis Games.  
	Sid Meier's Civilization V, Civ, Civilization, 2K Games, Firaxis Games, Take-Two Interactive Software 
	and their respective logos are all trademarks of Take-Two interactive Software, Inc.  
	All other marks and trademarks are the property of their respective owners.  
	All rights reserved. 
	------------------------------------------------------------------------------------------------------- */
#pragma once

#ifndef CIV5_PROJECT_CLASSES_H
#define CIV5_PROJECT_CLASSES_H

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  CLASS:      CvProjectEntry
//!  \brief		A single project available in the game
//
//!  Key Attributes:
//!  - Used to be called CvProjectInfo
//!  - Populated from XML\GameInfo\CIV5ProjectInfo.xml
//!  - Array of these contained in CvProjectXMLEntries class
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
class CvProjectEntry: public CvBaseInfo
{
public:
	CvProjectEntry(void);
	virtual ~CvProjectEntry(void);

	virtual bool CacheResults(Database::Results& kResults, CvDatabaseUtility& kUtility);

	int GetVictoryPrereq() const;
	int GetTechPrereq() const;
	int GetAnyoneProjectPrereq() const;
	void SetAnyoneProjectPrereq(int i);
	int GetMaxGlobalInstances() const;
	int GetMaxTeamInstances() const;
	int GetProductionCost() const;
	int GetNukeInterception() const;
	int GetCultureBranchesRequired() const;
	int GetTechShare() const;
	int GetEveryoneSpecialUnit() const;
	int GetVictoryDelayPercent() const;
	int GetFlavorValue(int i) const;
	bool IsSpaceship() const;
	bool IsAllowsNukes() const;
#if defined(MOD_BALANCE_CORE)
	int CostScalerNumberOfRepeats() const;
	int GetGoldMaintenance() const;
	int CostScalerEra() const;
	PolicyTypes GetFreePolicy() const;
	BuildingClassTypes  GetFreeBuilding() const;
	int GetNumRequiredTier3Tenets() const;
	bool InfluenceAllRequired() const;
	bool IdeologyRequired() const;
	bool IsRepeatable() const;
	int GetHappiness() const;
	int GetEmpireSizeModifierReduction() const;
	int GetDistressFlatReduction() const;
	int GetPovertyFlatReduction() const;
	int GetIlliteracyFlatReduction() const;
	int GetBoredomFlatReduction() const;
	int GetReligiousUnrestFlatReduction() const;
	int GetBasicNeedsMedianModifier() const;
	int GetGoldMedianModifier() const;
	int GetScienceMedianModifier() const;
	int GetCultureMedianModifier() const;
	int GetReligiousUnrestModifier() const;
	int GetEspionageMod() const;
#endif

	const char* GetMovieArtDef() const;

	const char* GetCreateSound() const;
	void SetCreateSound(const char* szVal);

	// Arrays
	int GetResourceQuantityRequirement(int i) const;
	int GetVictoryThreshold(int i) const;
	int GetVictoryMinThreshold(int i) const;
	int GetProjectsNeeded(int i) const;

protected:
	int m_iVictoryPrereq;
	int m_iTechPrereq;
	int m_iAnyoneProjectPrereq;
	int m_iMaxGlobalInstances;
	int m_iMaxTeamInstances;
	int m_iProductionCost;
	int m_iNukeInterception;
	int m_iCultureBranchesRequired;
	int m_iTechShare;
	int m_iEveryoneSpecialUnit;
	int m_iVictoryDelayPercent;

	bool m_bSpaceship;
	bool m_bAllowsNukes;
#if defined(MOD_BALANCE_CORE)
	int m_iGoldMaintenance;
	int m_iCostScalerEra;
	int m_iCostScalerNumRepeats;
	BuildingClassTypes m_eFreeBuilding;
	PolicyTypes m_eFreePolicy;
	bool m_bIsRepeatable;
	int m_iNumRequiredTier3Tenets;
	bool m_bInfluenceAllRequired;
	bool m_bIdeologyRequired;
	int m_iHappiness;
	int m_iEmpireSizeModifierReduction;
	int m_iDistressFlatReduction;
	int m_iPovertyFlatReduction;
	int m_iIlliteracyFlatReduction;
	int m_iBoredomFlatReduction;
	int m_iReligiousUnrestFlatReduction;
	int m_iBasicNeedsMedianModifier;
	int m_iGoldMedianModifier;
	int m_iScienceMedianModifier;
	int m_iCultureMedianModifier;
	int m_iReligiousUnrestModifier;
	int m_iEspionageMod;
#endif

	CvString m_strCreateSound;
	CvString m_strMovieArtDef;

	// Arrays
	int* m_piResourceQuantityRequirements;
	int* m_piVictoryThreshold;
	int* m_piVictoryMinThreshold;
	int* m_piProjectsNeeded;
	int* m_piFlavorValue;
};

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  CLASS:      CvProjectXMLEntries
//!  \brief		Game-wide information about projects
//
//! Key Attributes:
//! - Plan is it will be contained in CvGameRules object within CvGame class
//! - Populated from XML\GameInfo\CIV5ProjectInfo.xml
//! - Contains an array of CvProjectEntry from the above XML file
//! - One instance for the entire game
//! - Accessed heavily by the [what stores info on projects built?] class
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
class CvProjectXMLEntries
{
public:
	CvProjectXMLEntries(void);
	~CvProjectXMLEntries(void);

	// Accessor functions
	std::vector<CvProjectEntry*>& GetProjectEntries();
	int GetNumProjects();
	_Ret_maybenull_ CvProjectEntry* GetEntry(int index);

	void DeleteArray();

private:
	std::vector<CvProjectEntry*> m_paProjectEntries;
};

#endif //CIV5_PROJECT_CLASSES_H