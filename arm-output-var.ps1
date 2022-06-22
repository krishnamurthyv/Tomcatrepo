function Convert-ArmOutputToPsObject {
      param (
        [Parameter(Mandatory=$true)]
        [string]
        $ArmOutputString
      )

      if ($PSBoundParameters['Verbose']) {
        Write-Host "Arm output json is:"
        Write-Host $ArmOutputString
      }

      $armOutputObj = $ArmOutputString | ConvertFrom-Json

      $armOutputObj.PSObject.Properties | ForEach-Object {
       
      $keyname = $_.Name
      $value = $_.Value.value
      ## Creates a standard pipeline variable
      Write-Output "##vso[task.setvariable variable=$keyName;]$value"
		
      ## Creates an output variable
      Write-Output "##vso[task.setvariable variable=$keyName;isOutput=true]$value"
      }
}

Convert-ArmOutputToPsObject -ArmOutputString '$(armOutput)' -Verbose