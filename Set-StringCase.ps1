function Set-StringCase {

    param(
    [string[]]$String,
    [switch]$ToLower,
    [switch]$ToUpper,
    [switch]$ToTitle
    )

    Begin{}
    Process{

        if($ToLower){
        
            Return $String.ToLower()

        }
        if($ToUpper){

            Return $String.ToUpper()    

        }
        if($ToTitle){
            foreach($str in $String){
                (Get-Culture).TextInfo.ToTitleCase($str)
            }
        }
        else{
            Return $String
        }
    }
}