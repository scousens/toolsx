param(
  $d1,
  $d2=$null)

# MYGIT_DIR is set in $PROFILE
cd $env:MYGIT_DIR

if (Test-Path -Path $d1 -PathType 'Container') {
  cd $d1
} else {
  switch ($d1) {
    ($_ -eq "g" -or "gh") {
      $d1 = "gh"
      break
    }
    ($_ -eq "n" -or "ntlie" -or "nt") {
      $d1="nt"
      break
    }
    ($_ -eq "f" -or "fork") {
      $d1="nt"
      break
    }
  }
  if (Test-Path -Path "$d1*") {
    $d1 = (Get-ChildItem "$d1*" -Attributes Directory | select -first 1).name
    cd $d1
  }
}

if ($d2) {
  if (Test-Path -Path $d2 -PathType 'Container') {
    cd $d2
  } else {
    switch ($d2) {
      "pa" {
        $d2 = "pytest-automation"; break
      }
      "u" {
        $d2 = "unity"; break
      }
      default {
        foreach ($name in Get-ChildItem -Attributes Directory) {
          $name = $name.name
          $pieces = $name -split '-'
          if ($d2.length -eq 1) {
            if ($name -match "^$($d2[0][0])[a-z0-9]+") {
              $d2 = $name
              break
            }
          }
          elseif ($d2.length -eq 2) {
            if ($name -match "^$($d2[0][0])[a-z0-9]+\-$($d2[1][0])[a-z0-9]+") {
              $d2 = $name
              break
            }
          }
          else {
            $d2 = $null
          }
        }
        Write-Host -fore green "Dynamic code result: $d2"
      }
    }
    if ($d2 -and (Test-Path -Path $d2 -PathType 'Container')) {
      cd $d2
    }
  }
}
Write-Host -fore yellow "final: $(pwd)  [$d1/$d2]"
