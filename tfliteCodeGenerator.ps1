cls
$version = "3.9.13"
$url = "https://www.python.org/ftp/python/$version/python-$version-amd64.exe"
write "Instalando Python $version"

$installPath = "$($env:ProgramFiles)\Python$version"
Invoke-WebRequest $url -OutFile python-$version.exe
Start-Process python-$version.exe -ArgumentList "/quiet", "TargetDir=$installPath" -Wait


$envVariable = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($envVariable -notlike "*$installPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$envVariable;$installPath", "Machine")
    Write-Host "Added Python to PATH."
}
Remove-Item python-$version.exe

write 'Atualizando o pip'
python -m pip install --upgrade pip
write 'Instalando  TFLITE-SUPPORT'
pip install tflite-support
write 'Modelos disponíveis:'
Get-ChildItem -Path ./models/* -Include *.tflite
$selectedModel = Read-Host -Prompt 'Digite o nome do modelo que deseja gerar os Wrapers'
$selectedModelPackage = $selectedModel.Substring(0,$selectedModel.LastIndexOf(".")).ToLower()
$modelName = $selectedModel.Substring(0,1).ToUpper() + $selectedModel.Substring(1,$selectedModel.LastIndexOf(".")-1).ToLower()
$modelClassName = $selectedModel.Substring(0,1).ToUpper() + $selectedModel.Substring(1,$selectedModel.LastIndexOf(".")-1).ToLower() + "Model"
write "Gerando wrappers do modelo $selectedModel"
powershell -command "tflite_codegen --model=./models/$selectedModel --package_name=br.com.seveninovacoes.ia.$selectedModelName.wrappers --model_class_name=$modelClassName --destination=./$selectedModelPackage-model"
write 'Processo terminado'