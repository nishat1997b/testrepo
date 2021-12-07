*** Settings ***
Documentation  8_13_DownloadtherecommnededsoftpaqsunderDRIVERScategorytoagivenlocation
Library           RobotLib\\RebootAPI.py
Library           BuiltIn
Library           OperatingSystem
Library           String
Library           RobotLib\\BpsAPI.py
Library           RobotLib\\ReadDownloadConfig.py
Library           RobotLib\\WindowHandler.py
Resource          Keyword\\hp_documentation.txt
Resource          Keyword\\HPIAssistant.txt
Suite Setup       Read JSON Parameters
Suite Teardown    Close


*** Variable ***

${exe_cmd}      HPImageAssistant.exe /TargetFile:"C:\\\\HP_FIILES\\TargetImage.xml" /Operation:Analyze /Category:Drivers /InstallType:INFInstallable /Action:Download /SoftpaqDownloadFolder:"C:\\\\download_folder" /ReportFolder:"C:\\\\report_folder" /Silent /Debug /Noninteractive

*** Test Cases ***

Step 01: Verify the existance of HPAI Image Assistanse ImagePal folder
    [Documentation]      Verify the existance of PAI Image Assistanse ImagePal folder
    Validate Folder Exists      ${package_path}
 
Step 02: Verify the existance of Folders
    [Documentation]      Launch HPIAssistant
    Hp Image Assistant Application Launch        ${package_path}\\HPImageAssistant.exe

Step 03: Analyze HPIAssistant
    [Documentation]     Analyze HPIAssistant
    ${Result}           Analyse HPIA With Custom Settings       <This Computer>
    Run Keyword If      ${Result}==False     Fail       msg=Failed to analyze
    
Step 04: Creating a zip file in c HP_FIILES
    [Documentation]     creating a zip file in c HP_FIILES
    ${Result}           ctrl_shift_s
    Sleep      2s
    Run Keyword If      ${Result}==False     Fail       msg=Failed to Creat a zip
    
Step 05: Unzip file in c HP_FIILES
    [Documentation]     unzip file in c HP_FIILES
    ${Result}           Unzip The File Into Destination Folder      C:\\HP_FIILES.zip        C:\\HP_FIILES
    Run Keyword If      ${Result}==False     Fail       msg=Failed to unzip
    Close Hp Image Assistant Application
    
Step 06: Execute the command to download softpaqs
    [Documentation]      Execute the command to download softpaqs
    ${Result}           Command Prompt Run     ${package_path}       ${exe_cmd}
    Run Keyword If      ${Result}==False     Fail       msg=Failed to execute the command

Step 07: Checking Cva And Html And Exe files With Splist In Recommendations
    [Documentation]     Checking Cva And Html And Exe files With Splist In Recommendations
    Hp Image Assistant Application Launch        ${package_path}\\HPImageAssistant.exe
    ${Result}       Analyse HPIA With Custom Settings        <This Computer>
    Run Keyword If      ${Result}==False     Fail       msg=Failed to execute the command
    ${Recommendation}       select_tabs        Recommendations
    ${Select_All}       selectFromDownloadDropdown        All
    ${Spnums}        get_softpaqnumber_from_recommendation
    Set Suite Variable      ${Spnums}
    ${Result}           Verify Splist In Recommendations With Downloaded SPList      C:\\download_folder
    Run Keyword If      ${Result}==False     Fail       msg=Failed to match softpaqs in recommendations with downloaded softpaqs
    Close Hp Image Assistant Application

Step 08: Verifying readme file
    [Documentation]     verifying readme file
    ${Result}            Check File Exists With Endswith Or Startswith       C:\\report_folder       starts_with=Readme     ends_with=None
    Run Keyword If      ${Result}==False        Fail        msg=Readme file not found
    File Should Exist       C:\\download_folder\\InstallAll.cmd

Step 09: Run InstallAll cmd script on the system
    [Documentation]      Run InstallAll cmd script on the system
    ${Result}       Start Cmd Prompt Run     C:\\download_folder       InstallAll.cmd /Noninteractive
    Run Keyword If      ${Result}==False        Fail     msg=Failed to execute the command
    sleep     1m
    ${Result}       exit_cmd        exit
    Run Keyword If      ${Result}==False        Fail     msg=Failed to execute the command
    #Reboot
	
Step 10: Verify the softpaqs versions on hp support site
    [Documentation]     Verify the softpaqs versions on hp support site
    ${Result}           Check Softpaqs Versions On hp support Site        https://support.hp.com/in-en/drivers/laptops        System Model        C:\\download_folder       Category        US      Version     Revision
    Run Keyword If      ${Result}==False        Fail        msg=Softpaq versions not matching with the hp support site
	Sleep      5s

Step 11: Go Control panel and Device manger to verify the information
    [Documentation]     Go to Control panel and Device manger to verify the information
	Sleep      10s
    ${Result}       Verify Driver and Application information in Device Manager and Control Panel       C:\\download_folder
	Run Keyword if     ${Result} == False      Fail   msg=Failed to check drivers and applications in device manager and control panel 
    

*** Keywords ***


Read JSON Parameters
    ${TEMP} =    Get Environment Variable    TEMP
    Set Suite Variable    ${TEMP}

    #Verifying DownloadConfig.json file exists or not in temp location
    ${file_status}=    Run Keyword And Return Status    File Should Exist    ${TEMP}\\DownloadConfig.json
    Run Keyword If   ${file_status} != True    FATAL ERROR

    #Retriving package name and package path from DownloadConfig.json file
    ${package_name}    ${package_path}=    Read Download Config Json    ${TEMP}\\DownloadConfig.json
    #Log To Console    \n${package_name} and ${package_path}
    Set Suite Variable  ${package_name}
    Set Suite Variable  ${package_path}
    
    Delete Folder


Delete Folder
    Remove File           C:\\HP_FIILES.zip
    Remove Directory      C:\\download_folder     True
    Remove Directory      C:\\report_folder     True
    Remove Directory      C:\\HP_FIILES     True

Close
    Delete Folder