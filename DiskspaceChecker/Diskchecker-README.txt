Step 1. Run script Make-emailcred.ps1 as the same user that will execute the scheduled task

Step 2. Confirm C:\download\emailcred.txt exists

Step 3. Copy both call-diskspace-checker.bat and DiskspaceChecker-EmailWhenLow.ps1 to C:\download

Step 4. Open the email-diskspace-warning.ps1 file (in the new location) to set your Email to and From, drive letters, and threshold levels.
(currently the script is set to check for 2 drives, but more can be added)

Step 5. Make a scheduled task to run every (1 hour or whatever you'd like) running the .bat file as its triggered action

5a. Make a folder in tasks that is company name (if not already made) 
5b. Create Task (NOT A BASIC TASK)
5c. Run Whether user is logged on or not, and click run with the highest privileges
5d. Make the Trigger Daily, then check repeat task every (1 hour) for a duration of (1 day)
5e. Make sure Trigger is enabled
5f. Make the action the .bat file in DOCUMENTS (or wherever you moved it to)
