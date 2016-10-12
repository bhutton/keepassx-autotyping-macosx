on open location localURL
	-- kpx://proto?username:password:address:port/path
	-- * kpx://ssh?alice:xyz:wonderland.com:22022
	-- * kpx://https?alice:xyz:wonderland.com:40443/home
	-- kpx-proto://username:password@address:port/path
	-- * kpx-ssh://alice:xyz@wonderland.com:22022
	-- * kpx-https://alice:xyz@wonderland.com:40443/home	
	
	set myTerm to "Terminal"
	set altKey to ""
	
	-- display dialog "URL: " & localURL
	
	if (text 1 thru 4 of localURL) is "kpx:" then
		set thePath to text 7 thru -1 of localURL
		if (text 1 thru 4 of thePath) is "ssh?" then
			-- ssh?
			set theProto to "ssh"
			set theData to text 5 thru -1 of thePath
		else
			if (text 1 thru 7 of thePath) is "https??" then
				-- https? and form requires extra tab
				set altKey to "extratab"
				set theProto to "https"
				set theData to text 8 thru -1 of thePath
			else if (text 1 thru 6 of thePath) is "https?" then
				-- https?
				set theProto to "https"
				set theData to text 7 thru -1 of thePath
			else
				if (text 1 thru 6 of thePath) is "http??" then
					-- http? and form requires extra tab
					set altKey to "extratab"
					set theProto to "http"
					set theData to text 7 thru -1 of thePath
				else if (text 1 thru 5 of thePath) is "http?" then
					-- http?
					set theProto to "http"
					set theData to text 6 thru -1 of thePath
				else
					-- assume http
					set theProto to "http"
					set theData to thePath
				end if
			end if
		end if
	else
		set thePath to text 5 thru -1 of localURL
		if (text 1 thru 4 of thePath) is "ssh:" then
			-- ssh:
			set theProto to "ssh"
			set theData to text 7 thru -1 of thePath
		else
			if (text 1 thru 6 of thePath) is "https:" then
				-- https:
				set theProto to "https"
				set theData to text 9 thru -1 of thePath
			else
				if (text 1 thru 5 of thePath) is "http:" then
					-- http:
					set theProto to "http"
					set theData to text 8 thru -1 of thePath
				else
					-- assume http
					set theProto to "http"
					set theData to thePath
				end if
			end if
		end if
	end if
	
	set theCLPos to offset of ":" in theData
	if theCLPos = 0 then
		display dialog "INVALID URL - NO USER"
		return
	end if
	set theUser to text 1 thru (theCLPos - 1) of theData
	set theData1 to text (theCLPos + 1) thru -1 of theData
	set theData to theData1
	set theCLPos to offset of "@" in theData
	if theCLPos = 0 then
		set theCLPos to offset of ":" in theData
		if theCLPos = 0 then
			display dialog "INVALID URL - NO PASSWORD"
			return
		end if
	end if
	
	set thePass to text 1 thru (theCLPos - 1) of theData
	set theAddr to text (theCLPos + 1) thru -1 of theData
	
	-- display dialog "URL: " & theProto & "://" & theUser & ":xyz@" & theAddr
	
	if theProto is "ssh" then
		set theCLPos to offset of ":" in theAddr
		if theCLPos = 0 then
			set theSSHUrl to "ssh " & theUser & "@" & theAddr
		else
			set theHost to text 1 thru (theCLPos - 1) of theAddr
			set thePort to text (theCLPos + 1) thru -1 of theAddr
			set theSSHUrl to "ssh -p " & thePort & " " & theUser & "@" & theHost
		end if
		if myTerm is "Terminal" then
			-- display dialog "Terminal"
			
			tell application "Terminal"
				activate
				delay 1
				do script with command theSSHUrl
				delay 1
				set theButton to button returned of (display dialog "Auto type? (" & theAddr & ")" buttons {"No", "Yes"} default button "Yes")
				if theButton is "Yes" then
					tell application "System Events"
						keystroke thePass
						key code 52
					end tell
				end if
			end tell
		end if
	else
		set theHTTPUrl to theProto & "://" & theAddr
		tell application "Safari"
			activate
			delay 1
			tell window 1 of application "Safari" to make new tab
			tell front window of application "Safari" to set current tab to last tab
			set the URL of document 1 to theHTTPUrl
			set theButton to button returned of (display dialog "Auto type? (" & theAddr & ")" buttons {"No", "Yes"} default button "Yes")
			if theButton is "Yes" then
				tell application "System Events"
					-- if form requires extra tab
					if altKey is "extratab" then
						key code 48
					end if
					keystroke theUser
					key code 48
					keystroke thePass
					key code 52
				end tell
			end if
		end tell
	end if
	
end open location

