# Tinta Laser - verifica que el token de GitHub pueda escribir en el repositorio del proyecto
param(
  [Parameter(Mandatory=$true)][string]$RepoUrl,
  [Parameter(Mandatory=$true)][string]$Token
)
$ErrorActionPreference = 'Stop'

$m = [regex]::Match($RepoUrl, 'github\.com[/:]([^/]+)/([^/]+?)(\.git)?/?$')
if (-not $m.Success) { Write-Host '[X] La URL del repositorio no parece de GitHub.'; exit 1 }
$owner = $m.Groups[1].Value
$repo  = $m.Groups[2].Value

$headers = @{
  Authorization = "Bearer $Token"
  Accept        = 'application/vnd.github+json'
  'User-Agent'  = 'tinta-laser'
}

try {
  $info = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo" -Headers $headers
} catch {
  $code = $_.Exception.Response.StatusCode.value__
  if ($code -eq 401) {
    Write-Host '[X] GitHub rechaza el token (401). Esta vencido o copiado mal. Crea uno nuevo.'
  } elseif ($code -eq 404) {
    Write-Host '[X] GitHub no encuentra el repositorio para este token (404).'
    Write-Host '    Causa habitual: el token no tiene acceso a este repositorio especifico.'
  } else {
    Write-Host "[X] GitHub respondio con codigo $code."
  }
  exit 1
}

Write-Host "[OK] Repositorio encontrado: $($info.full_name)"
if ($info.permissions.push -eq $true) {
  Write-Host '[OK] El token PUEDE escribir en el repositorio. El problema no es el token.'
  exit 0
}
Write-Host '[X] El token NO tiene permiso de escritura en este repositorio.'
Write-Host '    Solucion: crea un token nuevo con Contents = Read and write (ver docs/CUENTAS_TINTA_LASER.md).'
exit 1
