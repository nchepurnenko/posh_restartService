$SmtpServer = 'mail.example.com'
$To = 'example@example.com'
$From = 'example@example.com' 
$password = ""
chcp 65001
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = New-Object System.Drawing.Point(300,300)
$Form.text                       = "RestartService"
$Form.TopMost                    = $false

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Press the button. Check 'test' for test run"
# $Label1.AutoSize                 = $true
$Label1.width                    = 292
$Label1.height                   = 150
$Label1.location                 = New-Object System.Drawing.Point(8,100)
$Label1.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Restart MSSQL on SRVSQL3"
$Button1.width                   = 87
$Button1.height                  = 73
$Button1.location                = New-Object System.Drawing.Point(8,5)
$Button1.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Button2                         = New-Object system.Windows.Forms.Button
$Button2.text                    = "Restart MSSQL on SRVSQL4"
$Button2.width                   = 87
$Button2.height                  = 73
$Button2.location                = New-Object System.Drawing.Point(104,5)
$Button2.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Button3                         = New-Object system.Windows.Forms.Button
$Button3.text                    = "Restart 1C on SRVSQL4"
$Button3.width                   = 87
$Button3.height                  = 73
$Button3.location                = New-Object System.Drawing.Point(200,5)
$Button3.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox1                       = New-Object system.Windows.Forms.CheckBox
$CheckBox1.text                  = "Test"
$CheckBox1.AutoSize              = $true
$CheckBox1.width                 = 95
$CheckBox1.height                = 20
$CheckBox1.location              = New-Object System.Drawing.Point(8,270)
$CheckBox1.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Form.controls.AddRange(@($Label1,$Button1,$Button2, $button3, $CheckBox1))

function RestartService ($computerName, $serviceName, $label) {
  
  $code = 0
  $caption = "Achtung!"
  $label.text = ""
  if ($CheckBox1.Checked) {
    $text = "This is test run. No service will be restarted. Continue?"
    $command = {Get-Service -Name $Using:serviceName}
    $code = 2
  } else {
    $text = "Service $serviceName will be restarted on server $computerName. Continue?"
    $command = {Restart-Service -Name $Using:serviceName -Force -PassThru}
  }

  $msgBoxInput = [System.Windows.Forms.MessageBox]::Show($text,$caption, 'YesNo','Warning')
  switch ($msgBoxInput) {
    'Yes' {
      $result = Invoke-Command -ComputerName $computerName -ScriptBlock $command
      if ($null -eq $result){
        $label.Text = $Error[0]
        return 1
      } else {
        $label.Text = $result.Name + " " +$result.Status
      }
      break
    }
    'No' {
      break
    }
  }
  return $code 
}

function SendReport($computerName, $serviceName){

  $mypass = ConvertTo-SecureString $password -AsPlainText -Force
  $mycreds = New-Object System.Management.Automation.PSCredential ($From, $mypass)

  $subject = "The service $serviceName was restarted on server $computerName"
  $body = "The user $env:USERNAME restarted the service $serviceName on the server $computerName"

  if ($null -eq $serviceName ){
    $subject = "The server $computerName was restarted"
    $body = "The user $env:USERNAME restarted the server $computerName"
  }

  Send-MailMessage `
  -SmtpServer $SmtpServer `
  -To $To `
  -From $From `
  -Subject $subject `
  -Body $body `
  -Encoding 'UTF8' `
  -Credential $mycreds
}

#Write your logic code here
$Button1.Add_Click(
  {
    $this.Enabled = $false 
    $computerName = "srvsql3"
    $serviceName = "MSSQLSERVER"
    $restartResult = RestartService -computerName $computerName -serviceName $serviceName -label $Label1
    if ($restartResult -eq 0) {
      SendReport -computerName $computerName -serviceName $serviceName
    }    
    $this.Enabled = $true
  }  
)

$Button2.Add_Click(
  {
    $this.Enabled = $false 
    $computerName = "srvsql4"
    $serviceName = "MSSQLSERVER"
    $restartResult = RestartService -computerName $computerName -serviceName $serviceName -label $Label1
    if ($restartResult -eq 0) {
      SendReport -computerName $computerName -serviceName $serviceName
    }    
    $this.Enabled = $true
  }  
)

$Button3.Add_Click(
  {
    $this.Enabled = $false 
    $computerName = "srv1c2"
    $serviceName = "1C:Enterprise 8.3 Server Agent (x86-64)"
    $restartResult = RestartService -computerName $computerName -serviceName $serviceName -label $Label1
    if ($restartResult -eq 0) {
      SendReport -computerName $computerName -serviceName $serviceName
    }    
    $this.Enabled = $true
  }  
)

[void]$Form.ShowDialog()

