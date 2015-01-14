--
--  AppDelegate.applescript
--  MacManagementXC4
--
--  Created by Houle, Todd on 8/19/14.
--  Copyright (c) 2014 Partners. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
	property appPatch : false  --bool should patch or not
    property betaPatch : false  --bool should get beta patches
    property theWindow : missing value
    property deptList : {} --popup of depts taken from txt file
    property spinner : true
    global saveDone
    global thisDept
    global deptSetYes
    
    
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened
        try
            set appPatchString to (do shell script "defaults read /Library/Preferences/org.Partners.PEASManagement appPatch")
            if appPatchString is "1" then set my appPatch to true
            if appPatchString is "0" then set my appPatch to false
        end try
        try
            set betaPatchString to (do shell script "defaults read /Library/Preferences/org.Partners.PEASManagement betaPatch")
            if betaPatchString is "1" then set my betaPatch to true
            if betaPatchString is "0" then set my betaPatch to false
        end try
        try
            set deptGroup to (do shell script "defaults read /Library/Preferences/org.Partners.PEASManagement deptGroup")
        on error
            set deptGroup to ""
        end try
        
        set saveDone to false  --set to true when its been saved
        
        --get path to root folder
        set rootPath to current application's NSBundle's mainBundle()'s resourcePath() as text
        set oldDelimiters to AppleScript's text item delimiters -- always preserve original delimiters
        set AppleScript's text item delimiters to {"/"}
        set pathItems to text items of (rootPath as text)
        set numItems to (number of items of pathItems)
        set fewFewer to (numItems - 2) --in main app bundle
        set fewFewer2 to (numItems - 3) --To This App
        
        set rootPathB to ((items 1 thru fewFewer of pathItems as string)) --gets path to root app folder
        set appPath to (items 1 thru fewFewer2 of pathItems as string) --path to this application
        set AppleScript's text item delimiters to oldDelimiters

        --populate the department list
        if deptGroup is "" then
            set deptList to {"None"} --clear the list
        else
            set deptList to {deptGroup,"-None-"} as list
        end if
        
        set deptListRef to rootPathB & "/depts.txt"
        set catString to quoted form of deptListRef
        set divsionList to do shell script "cat " & catString
        set divisParas to paragraphs of divsionList
        repeat with x in divisParas
            if (x as string) is not (deptGroup as string) --because deptGroup is already there from defaults
                set my deptList to deptList & word 1 of x
            end if
        end repeat
    
        set deptSetYes to false --set to true when dept popup chosen - used to set defaults.
	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
        if saveDone is false
            set xyz to button returned of (display dialog "Settings not Saved.  Save now?" buttons  {"No","Yes"} default button 2 with icon 2)
            if xyz is "Yes"
                saveMe_(sender)
            end if
        end if
		-- Insert code here to do any housekeeping before your application quits
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
    on helpMe_(sender)
        display dialog "The PEAS program will update common software on this computer if you choose to receive them.  Check the 'I Agree' checkbox to Update this computer to participate. \n\nBefore all computers are patched, the PEAS program tests the patches internally, then on users who choose to receive PILOT patches.  Check the Pilot checkbox to receive patches early for testing. \n\nIf you were instructed to participate in a patch group, select the name of the group from the popup." buttons "OK" default button 1 with icon 1
    end helpMe_
    
    on saveMe_(sender)
        theWindow's makeFirstResponder_(missing value)
        set my spinner to false  --show spin window
        tell theWindow to displayIfNeeded()  --tell window to redraw

        log "Saving Settings: appPatch " & (appPatch as string) & ", beta " & (betaPatch as string)
        do shell script "defaults write /Library/Preferences/org.Partners.PEASManagement appPatch -bool " & appPatch with administrator privileges
        do shell script "defaults write /Library/Preferences/org.Partners.PEASManagement betaPatch -bool " & betaPatch with administrator privileges
        if deptSetYes is true
            do shell script "defaults write /Library/Preferences/org.Partners.PEASManagement deptGroup -string " & thisDept with administrator privileges
        end if
        set saveDone to true

        do shell script "jamf recon" with administrator privileges

        display dialog "Your settings have been saved!" buttons "OK" default button 1 with icon 1

        tell me to quit
    end saveMe_

    on checkBeta_(sender)
        log betaPatch
        if (betaPatch as string) is not ("false" as string)
            display dialog "Pilot patches are updates which will eventually be installed on all computers but are in final testing.  By selecting the Pilot checkbox, your computer will be part of the final test population." buttons "OK" default button 1 with icon 2
        end if
    end checkBeta_

    on deptChosen_(sender)
        set newDept to sender's selectedItem()'s title()
        set thisDept to newDept  --coerce format
        set deptSetYes to true
    end deptChosen_

end script