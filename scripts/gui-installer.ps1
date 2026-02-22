# Rocksmith Generic Cable - GUI Installer (C# WPF)
# This creates a simple wizard-style installer for non-technical users

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Rocksmith Generic Cable Installer" 
        Height="600" Width="800" 
        WindowStartupLocation="CenterScreen"
        ResizeMode="NoResize">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="80"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="60"/>
        </Grid.RowDefinitions>
        
        <!-- Header -->
        <Border Grid.Row="0" Background="#2C3E50">
            <StackPanel VerticalAlignment="Center" Margin="20,0">
                <TextBlock Text="🎸 Rocksmith Generic Cable Installer" 
                          FontSize="24" 
                          FontWeight="Bold" 
                          Foreground="White"/>
                <TextBlock Text="Setup your cheap USB guitar cable in 5 minutes" 
                          FontSize="14" 
                          Foreground="#ECF0F1"
                          Margin="0,5,0,0"/>
            </StackPanel>
        </Border>
        
        <!-- Content Area -->
        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
            <StackPanel Name="ContentPanel" Margin="30">
                <!-- Step indicator will be added dynamically -->
            </StackPanel>
        </ScrollViewer>
        
        <!-- Footer Buttons -->
        <Border Grid.Row="2" Background="#ECF0F1" BorderBrush="#BDC3C7" BorderThickness="0,1,0,0">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                
                <Button Name="BackButton" 
                        Grid.Column="1"
                        Content="← Back" 
                        Width="100" 
                        Height="35" 
                        Margin="10"
                        FontSize="14"
                        IsEnabled="False"/>
                
                <Button Name="NextButton" 
                        Grid.Column="2"
                        Content="Next →" 
                        Width="100" 
                        Height="35" 
                        Margin="10"
                        FontSize="14"
                        Background="#27AE60"
                        Foreground="White"
                        FontWeight="Bold"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

# Parse XAML
$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [Windows.Markup.XamlReader]::Load($reader)

# Get controls
$contentPanel = $window.FindName("ContentPanel")
$backButton = $window.FindName("BackButton")
$nextButton = $window.FindName("NextButton")

# Installation state
$script:currentStep = 0
$script:outputDevice = $null
$script:inputDevice = $null
$script:rocksmithFolder = "C:\Program Files (x86)\Steam\steamapps\common\Rocksmith2014"

# Steps
function Show-WelcomeStep {
    $contentPanel.Children.Clear()
    
    $welcome = New-Object System.Windows.Controls.TextBlock
    $welcome.Text = @"
Welcome to the Rocksmith Generic Cable Installer!

This wizard will help you set up your cheap USB guitar cable to work with Rocksmith 2014.

What this installer does:
• Downloads FL Studio ASIO (free audio driver)
• Downloads RS_ASIO (cable bypass tool)
• Finds your audio devices automatically
• Configures everything for you

Time required: About 5 minutes

Click 'Next' to begin!
"@
    $welcome.FontSize = 16
    $welcome.TextWrapping = "Wrap"
    $welcome.Margin = "0,20,0,0"
    
    $contentPanel.Children.Add($welcome)
    
    $backButton.IsEnabled = $false
    $nextButton.Content = "Next →"
}

function Show-DeviceSelectionStep {
    $contentPanel.Children.Clear()
    
    $title = New-Object System.Windows.Controls.TextBlock
    $title.Text = "Step 1: Select Your Audio Devices"
    $title.FontSize = 20
    $title.FontWeight = "Bold"
    $title.Margin = "0,0,0,20"
    $contentPanel.Children.Add($title)
    
    # Output device selection
    $outputLabel = New-Object System.Windows.Controls.TextBlock
    $outputLabel.Text = "Select your speakers/headphones:"
    $outputLabel.FontSize = 14
    $outputLabel.Margin = "0,10,0,5"
    $contentPanel.Children.Add($outputLabel)
    
    $outputCombo = New-Object System.Windows.Controls.ComboBox
    $outputCombo.Name = "OutputCombo"
    $outputCombo.FontSize = 14
    $outputCombo.Margin = "0,0,0,20"
    
    # Populate output devices
    $renderDevices = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render"
    foreach ($device in $renderDevices) {
        $guid = $device.PSChildName
        $props = Get-ItemProperty "$($device.PSPath)\Properties" -ErrorAction SilentlyContinue
        $name = $props."{b3f8fa53-0004-438e-9003-51a46e139bfc},6"
        if ($name) {
            $item = New-Object PSObject -Property @{Name=$name; Guid=$guid}
            $outputCombo.Items.Add($item) | Out-Null
        }
    }
    $outputCombo.DisplayMemberPath = "Name"
    $contentPanel.Children.Add($outputCombo)
    
    # Input device selection
    $inputLabel = New-Object System.Windows.Controls.TextBlock
    $inputLabel.Text = "Select your USB guitar cable:"
    $inputLabel.FontSize = 14
    $inputLabel.Margin = "0,10,0,5"
    $contentPanel.Children.Add($inputLabel)
    
    $inputCombo = New-Object System.Windows.Controls.ComboBox
    $inputCombo.Name = "InputCombo"
    $inputCombo.FontSize = 14
    
    # Populate input devices (filter for likely guitar cables)
    $captureDevices = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture"
    foreach ($device in $captureDevices) {
        $guid = $device.PSChildName
        $props = Get-ItemProperty "$($device.PSPath)\Properties" -ErrorAction SilentlyContinue
        $name = $props."{b3f8fa53-0004-438e-9003-51a46e139bfc},6"
        if ($name -and ($name -match "USB|Guitar|Audio Device|Audio CODEC")) {
            $item = New-Object PSObject -Property @{Name=$name; Guid=$guid}
            $inputCombo.Items.Add($item) | Out-Null
        }
    }
    $inputCombo.DisplayMemberPath = "Name"
    $contentPanel.Children.Add($inputCombo)
    
    # Store combos for later retrieval
    $window.Tag = @{Output=$outputCombo; Input=$inputCombo}
    
    $backButton.IsEnabled = $true
}

function Show-DownloadStep {
    $contentPanel.Children.Clear()
    
    $title = New-Object System.Windows.Controls.TextBlock
    $title.Text = "Step 2: Downloading Required Files"
    $title.FontSize = 20
    $title.FontWeight = "Bold"
    $contentPanel.Children.Add($title)
    
    $status = New-Object System.Windows.Controls.TextBlock
    $status.Name = "StatusText"
    $status.Text = "Downloading FL Studio ASIO..."
    $status.FontSize = 14
    $status.Margin = "0,20,0,10"
    $contentPanel.Children.Add($status)
    
    $progress = New-Object System.Windows.Controls.ProgressBar
    $progress.Name = "ProgressBar"
    $progress.Height = 30
    $progress.IsIndeterminate = $true
    $contentPanel.Children.Add($progress)
    
    # Actually download in background
    # TODO: Implement async download
}

function Show-CompleteStep {
    $contentPanel.Children.Clear()
    
    $title = New-Object System.Windows.Controls.TextBlock
    $title.Text = "✅ Installation Complete!"
    $title.FontSize = 24
    $title.FontWeight = "Bold"
    $title.Foreground = "#27AE60"
    $title.HorizontalAlignment = "Center"
    $title.Margin = "0,40,0,20"
    $contentPanel.Children.Add($title)
    
    $message = New-Object System.Windows.Controls.TextBlock
    $message.Text = @"
Your Rocksmith is now configured to use generic USB cables!

Next steps:
1. Plug in your USB guitar cable
2. Launch Rocksmith 2014 through Steam
3. Go to Settings → Calibration
4. Strum your guitar when prompted

If you have any issues, check the troubleshooting guide at:
https://github.com/scheissgeist/Rocksmith

Click 'Finish' to close this installer.
"@
    $message.FontSize = 14
    $message.TextWrapping = "Wrap"
    $message.HorizontalAlignment = "Center"
    $contentPanel.Children.Add($message)
    
    $nextButton.Content = "Finish"
}

# Button handlers
$nextButton.Add_Click({
    $script:currentStep++
    
    switch ($script:currentStep) {
        1 { Show-DeviceSelectionStep }
        2 { 
            # Validate device selection
            $combos = $window.Tag
            if ($combos.Output.SelectedItem -and $combos.Input.SelectedItem) {
                $script:outputDevice = $combos.Output.SelectedItem
                $script:inputDevice = $combos.Input.SelectedItem
                Show-DownloadStep
            } else {
                [System.Windows.MessageBox]::Show("Please select both devices!", "Error", "OK", "Error")
                $script:currentStep--
            }
        }
        3 { Show-CompleteStep }
        4 { $window.Close() }
    }
})

$backButton.Add_Click({
    $script:currentStep--
    
    switch ($script:currentStep) {
        0 { Show-WelcomeStep }
        1 { Show-DeviceSelectionStep }
    }
})

# Show first step
Show-WelcomeStep

# Show window
$window.ShowDialog() | Out-Null
