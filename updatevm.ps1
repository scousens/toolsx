param(
$target,
$action='deploy'
)

$SCRIPT_DIR = Split-Path $myinvocation.mycommand.path

# running: 
# - if deploying to a cluster - need vmware params, else omit
# - if using my vms, need nmc_ip, nmc_username, nmc_password, noc_username, noc_password (nmc or filer)
# - if deploying need auto-deploy, nmc_build, filer_build, +vmware_creds
# Deploying: 
# - On the cluster - need clustername? or assume? defaulted parameter? Need to build vmware params off this!
# MyVms
#  - need IP addresses

function run-tests() {
  $pycmd = "python -m pytest --driver=chrome"
  $vmhost = '--hostname=vcenter-automation.ops.nasuni.net --esx-host-username=svc_devops-envservice@nasuni.com --esx-host-password="=sbEH10MFggHi}@N+}@gNIIM5XsWodAg" --datastore=ps-Shared-Automation --cluster=Automation --network=dvs-Automation-vlan84'
  $credsnoc = "--noc-email=scousens@nasuni.com --noc-password=itsdangerous"
  $credsnmc = "--nmc_username=admin --nmc_password=admin"
  $credsnea = "--nmc_username=admin --nmc_password=nasuni123"
  $vmbuild=''
  $sample = 'python -m pytest --junit-xml=logs/xml/junit-report.xml --alluredir=logs/allure --driver=chrome --envfile=logs/jenkins.env --hostname=vcenter-automation.ops.nasuni.net --esx-host-username=svc_devops-envservice@nasuni.com --esx-host-password="=sbEH10MFggHi}@N+}@gNIIM5XsWodAg" --datastore=ps-Shared-Automation --cluster=Automation --network=dvs-Automation-vlan84 --noc-email=scousens@nasuni.com --noc-password=itsdangerous --nmc_username=admin --nmc_password=admin --nmc_ip 10.66.146.91 --filer_username admin --filer_password admin --filer_ip 10.66.133.4 --filer_ip 10.66.153.182 data_path\cloud_filesystem\test_nmc_api_cloud_filesystem.py::test_toc_list_retrieval'
}


function read-ips() {
  foreach ($dir in @($env:HOME, $env:userprofile, $SCRIPT_DIR)) {
      if ($dir) {
          if (test-path (Join-Path $dir 'bin')) {
            $dir = Join-Path $dir 'bin'
          }
          if (test-path (Join-Path $dir testvms.ini)) {
            $inifile = Join-Path $dir testvms.ini
            break
          }
      }
  }
  write-host "Reading ips from $inifile"
  get-content -Path $inifile | 
    ?{ $_ -notlike "#*" } |
    %{
      $k, $v = $_.split("=")
      set-variable $k $v.Replace("'", "").Replace('"', '') -scope 1
    }
}

read-ips
if ($target -eq "all") {
  echo "all - TBD"
  exit
} elseif ($target -eq "nmc" ){
 $IP=$NMC1
 $APP='nmc'
} elseif ($target -eq "nmcu" ){
 $IP=$NMCU
 $APP='nmc'
} elseif ($target -eq "nea" -or $target -eq "filer") {
 $IP=$NEA1
 $APP='filer'
} elseif ($target -eq "nea2" -or $target -eq "filer2") {
 $IP=$NEA2
 $APP='filer'
} else {
 echo "Need to specify 'nmc' or 'nea'"
 exit 1
}
# debug
echo "Whats left for params is: #$args# [ip=$IP; app=$APP]"

pushd "$($env:MYGIT_DIR)/gh/unity"
#python ../dev-tools/sync_dev.py $IP --$APP -bh -bt
popd
