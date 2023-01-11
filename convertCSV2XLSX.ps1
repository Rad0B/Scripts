[cmdletbinding()]
param(

    [parameter(
                        Mandatory = $true,
                        ValueFromPipeline=$true)]
    [String]$csv,#Name and path of src. csv file, like: \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\Output.xls

    [parameter(
                        Mandatory = $true,
                        ValueFromPipeline=$true)]
    [String]$xlsx,#Name and path of trg. excel file, like: \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\Output.xls

            [parameter(
                        Mandatory = $false,
                        ValueFromPipeline=$true)]
            [string]$sheetName="Sheet1",#Sheet name

    [parameter(
                        Mandatory = $false,
                        ValueFromPipeline=$true)]
    [string]$delimiter="~",#Delimiter

    [parameter(
                        Mandatory = $false,
                        ValueFromPipeline=$true)]
    [string]$replaceTrgExcel="Yes",#Replace trg. excel file or append new sheet

    [parameter(
                        Mandatory = $false,
                        ValueFromPipeline=$true)]
    [string]$showEmptySheet="Yes",#show or hide empty sheets

    [parameter(
                        Mandatory = $false,
                        ValueFromPipeline=$true)]
    [string]$headerColor="15",#Header color

    [parameter(
                        Mandatory = $false,
                        ValueFromPipeline=$true)]
    [string]$dataColor="0",#data color

    [parameter(
                        Mandatory = $false,
                        ValueFromPipeline=$true)]
    [string]$belobColsList="-" #apply belob fomat(###,###,###,###.00) on list of sheets, list separated by _

            )

[System.Threading.Thread]::CurrentThread.CurrentCulture = "en-US"

#Logging that concat 2 strings and write it to the output
Function Log([string]$arg1, [string]$arg2) { 
 $txt=-join($arg1,$arg2)
write-output $txt

}

$newFlag=1
$errorFlag=0

#Starting,tracing input parameters
write-output " "
write-output "///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////"

Log("Src. csv file:        ",$csv)
Log("Trg. excel file:      ",$xlsx)
Log("Sheet name:           ",$sheetName)
Log("Delimiter:            ",$delimiter)
Log("Replace trg. xls:     ",$replaceTrgExcel)
Log("Show empty sheet:     ",$showEmptySheet)
Log("Header color:         ",$headerColor)
Log("Data color:           ",$dataColor)
Log("Belob format on:      ",$belobColsList)

write-output "///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////"



#Function converts number to excel column name, like 1 to A, 3 to C etc.
Function NumToA1 { 
  
  Param([parameter(Mandatory=$true)] 
        [int]$number) 
 
  $a1Value = $null 
  While ($number -gt 0) { 
    $multiplier = [int][system.math]::Floor(($number / 26)) 
    $charNumber = $number - ($multiplier * 26) 
    If ($charNumber -eq 0) { $multiplier-- ; $charNumber = 26 } 
    $a1Value = [char]($charNumber + 64) + $a1Value 
    $number = $multiplier 
  } 
  Return $a1Value 
}

$attemptsNumber=1

Function createExcel()
{
    Try
    {
        write-output ""
        Log("--------------Attempt number:",$attemptsNumber)
        #Get csv rows and columns
        $importCSVVar=Import-Csv  $csv | Measure-Object | Select-Object 
        $countCSVRows=$(Get-Content $csv).Count

        #For empty source csv(only header) - eraze cols count and not format one row excel.
        if($countCSVRows -gt 1){
            $CSVFile = Get-Content $csv
            $countCSVColumns = ($CSVFile[0].split($delimiter)).Count
        }
        else{
            $countCSVColumns=0
        }
        
        #output src. rows cols count
        Log("Source CSV rows count:",$countCSVRows,". Columns count:",$countCSVColumns)


        if($countCSVRows -gt 1 -or $showEmptySheet -eq "Yes"){

            $excel = New-Object -ComObject "Excel.Application" 
            $excel.DisplayAlerts = $False
            # Create a new Excel workbook with one empty sheet


            if (!(Test-Path "$xlsx") -or ($replaceTrgExcel -eq "Yes") )
            {
                        write-output "-------Starting create new EXCEL document:"
                        $workbook = $excel.Workbooks.Add(1)
                $worksheet = $workbook.worksheets.Item(1)
                $worksheet.name = $sheetName
            }
            #Add new sheet to existing excel
            else
            {   
                $newFlag=0
                        write-output "-------Starting append new sheet:"
                $workbook = $excel.Workbooks.Open("$xlsx")
    
                $SheetsCount = $WorkBook.WorkSheets.Count
                $txt = -join("Existin sheets count:", $SheetsCount,". Sheets list:")
                write-output $txt
                foreach ($WorkSheetIter in $WorkBook.WorkSheets)
                {
                    write-output  $WorkSheetIter.name
                } 
     
                $worksheet =  $Workbook.Worksheets.Add([System.Reflection.Missing]::Value,$WorkBook.Worksheets.Item($SheetsCount))
                $worksheet.Name = $sheetName
        

            }

                write-output "Adding new sheet finished. Worksheets in new/updated excel document:"
                foreach ($WorkSheet in $WorkBook.WorkSheets)
                {
                    write-output  $worksheet.name
                } 

            write-output "Starting import data from csv file..."
            # Build the QueryTables.Add command and reformat the data
            $TxtConnector = ("TEXT;" + $csv)
            $Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))
            $query = $worksheet.QueryTables.item($Connector.name)
            $query.TextFileOtherDelimiter = $delimiter
            $query.TextFileParseType  = 1

            $cellsCount = $worksheet.Cells.Columns.Count

            $query.TextFileColumnDataTypes = ,1 * $cellsCount
            $query.AdjustColumnWidth = 1

            write-output "Statring format of new sheet's data..."
            #Format 
            if($countCSVRows -gt 1){ 

                $lastCol=NumToA1($countCSVColumns)
                #Style to all data
                $rangeAll = -join("A1:", "$lastCol",$countCSVRows)
                $worksheet.Range($rangeAll).Borders.LineStyle = 1
                $worksheet.Range($rangeAll).HorizontalAlignment = -4131

                #style to header
                $rangeHeader = -join("A1:", "$lastCol",1)

                $worksheet.Range($rangeHeader).Font.Bold = $True 
                $worksheet.Range($rangeHeader).Interior.ColorIndex=$headerColor

                #style to data
                $rangeData = -join("A2:", "$lastCol",$countCSVRows)
                $worksheet.Range($rangeData).Interior.ColorIndex=$dataColor        

                #Apply belob format to set of columns that comes as script parameter
                                if($belobColsList -ne "-"){
                                           $belobColsList.Split("_") | ForEach {
                                                       $rangeBelob = -join("$_","2:","$_",$countCSVRows)
                                                       Log("Format ###,###,###,###.00 was assigned to Range:", $rangeBelob)
                                                       $worksheet.Range($rangeBelob).NumberFormat = "###,###,###,###.00"
                                           } 
                                }
            }
    
            write-output "Starting save excel,delete query etc."

            # Execute & delete the import query
            $query.Refresh()
            $query.Delete()

            #activate 1 sheet
            $workbook.worksheets.Item(1).activate()

            # Save & close the Workbook as XLSX.
            if($newFlag=1){
                $Workbook.SaveAs($xlsx,51)
            }
            else {
                $Workbook.Save()
            }

            $excel.Quit()
            #Sleep for a few seconds to let ComObject and related excel to be normally saved/closed etc.
            Start-Sleep -s 5


        }
        else{
            write-output "Source CSV file is empty(only header) and showEmptySheet parameter was set to No, so trg. excel wasn't changed."
        }
    }
    Catch
    {       
                        #Do 2 attempts for quiting Excel process
                        Try
                        {
                                   #Close Excel process that did not closed automatically due Excel process fialed
            if($excel){
                write-output "Excel object exists, closing it..."
                                       $excel.Quit()
            }
            else {
                write-output "Excel object does not exists..." 
            }
                        }
                        Catch
                        {
                                   write-output "ERROR:Can't quite excel process right now, sleep for 30 Seconds..."
            Start-Sleep -s 30
                                   Try
                                   {
                                       #Close Excel process that did not closed automatically due Excel process fialed
                if($excel){
                    write-output "Excel object exists, closing it..."
                                           $excel.Quit()
                }
                else {
                    write-output "Excel object does not exists..." 
                }
                                   }
                                   Catch
                                   {
                                               write-output "ERROR:Can't quite excel process now,skip attempts."
                                   }
                        }
                        
                        #Do recursion ,10 times max
        $attemptsNumber++
        Log("ERROR message:",$_.Exception.Message)        

        #Try 10 times,if tens fail - throw message and exit from PWC code, fi eny before 10 succeed - PowerShell code will be finished without errors.
        if($attemptsNumber -lt 11) {
            write-output "Sleep for 30 Seconds..."
            Start-Sleep -s 30
            createExcel
        }
        else{
            Write-Output "ERROR:Process Failed!Excel can't be created at the moment.ERROR message:"+$_.Exception.Message
            exit (1)
        }
    }

}

#Execute main function
createExcel


<#


Test 1.
Descr: Create new excel document.Csv is not empty. Replace if it exists.
powershell.exe \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\CSV_To_Excel_AppendSheet.ps1 -csv \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\VPFonds_Difference_1_2_11_27092017.csv -xlsx \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\Output.xls

Test 2.
Descr: Create new excel document.Replace if it exists.Name sheet.
powershell.exe \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\CSV_To_Excel_AppendSheet.ps1 -csv \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\VPFonds_Difference_1_2_11_27092017.csv -xlsx \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\Output.xls -sheetName "MySheetName"

Test 3.
Descr: Create new excel document.Replace if it exists.A and C excel columns should be presentet with belob formats.
powershell.exe \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\CSV_To_Excel_AppendSheet.ps1 -csv \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\VPFonds_Difference_1_2_11_27092017.csv -xlsx \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\Output.xls -belobColsList "A_C"

Test 4.
Descr: Create new excel document.Replace if it exists.Change data colors.
powershell.exe \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\CSV_To_Excel_AppendSheet.ps1 -csv \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\VPFonds_Difference_1_2_11_27092017.csv -xlsx \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\Output.xls -dataColor "19"

Test 5.
Descr: Append new sheet to existing excel.Name new sheet.Change data colors.
powershell.exe \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\CSV_To_Excel_AppendSheet.ps1 -csv \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\VPFonds_Difference_10_27092017.csv -xlsx \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\Output.xls -replaceTrgExcel "No" -sheetName "Group_10" -dataColor "19"

Test 6.
Descr: Append new empty sheet to existing excel.Name new sheet.Change data colors.
powershell.exe \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\CSV_To_Excel_AppendSheet.ps1 -csv \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\VPFonds_Difference_103_27092017.csv -xlsx \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\Output.xls -replaceTrgExcel "No" -sheetName "Group_103" -dataColor "19"

Test 7.
Descr: Hide empty sheet ,so after adding new empty sheet to exiting excel - nothing will happans, excel will remains the same.
powershell.exe \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\CSV_To_Excel_AppendSheet.ps1 -csv \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\VPFonds_Difference_103_27092017.csv -xlsx \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\Output.xls -replaceTrgExcel "No" -sheetName "Group_103" -showEmptySheet "No" -dataColor "19"

Test 8.
Descr: Create new excel document.Csv is empty. Replace if it exists.
powershell.exe \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\CSV_To_Excel_AppendSheet.ps1 -csv \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\VPFonds_Difference_103_27092017.csv -xlsx \\pwcdevsharesn.res.bec.dk\Infa_shared\Scripts\XLSX_conversion\testSamples\Output_empty.xls


#>
