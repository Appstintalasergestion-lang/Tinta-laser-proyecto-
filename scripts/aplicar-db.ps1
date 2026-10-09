# Tinta Laser - aplica migraciones SQL a Supabase usando el access token (sbp_...)
# No requiere contrasena de base de datos. Registra lo aplicado en public.schema_migrations.
param(
  [Parameter(Mandatory=$true)][string]$ConfigFile,
  [Parameter(Mandatory=$true)][string]$MigDir
)
$ErrorActionPreference = 'Stop'

function Get-Cfg([string]$key) {
  $line = Get-Content -Path $ConfigFile -Encoding UTF8 | Where-Object { $_ -match "^$key=" } | Select-Object -First 1
  if ($line) { return $line.Substring($key.Length + 1).Trim() }
  return ''
}

$url   = Get-Cfg 'SUPABASE_URL'
$token = Get-Cfg 'SUPABASE_ACCESS_TOKEN'
if (-not $url -or -not $token) {
  Write-Host '[X] Faltan SUPABASE_URL o SUPABASE_ACCESS_TOKEN en config.env'
  exit 1
}

$ref = ($url -replace 'https://', '') -replace '\.supabase\.co.*', ''
$api = "https://api.supabase.com/v1/projects/$ref/database/query"
$headers = @{ Authorization = "Bearer $token" }

function Invoke-Sql([string]$sql) {
  $body = @{ query = $sql } | ConvertTo-Json -Depth 3
  return Invoke-RestMethod -Method Post -Uri $api -Headers $headers -ContentType 'application/json' -Body $body
}

Write-Host "[..] Proyecto $ref"
Invoke-Sql "create table if not exists public.schema_migrations (name text primary key, applied_at timestamptz not null default now());" | Out-Null
Invoke-Sql "alter table public.schema_migrations enable row level security;" | Out-Null

$rows = Invoke-Sql "select name from public.schema_migrations;"
$done = @()
if ($rows) { $done = @($rows | ForEach-Object { $_.name }) }

$files = Get-ChildItem -Path $MigDir -Filter *.sql | Sort-Object Name
if (-not $files) { Write-Host '[X] No hay migraciones en supabase\migrations'; exit 1 }

foreach ($f in $files) {
  if ($done -contains $f.Name) { Write-Host "[--] Ya aplicada: $($f.Name)"; continue }
  Write-Host "[..] Aplicando $($f.Name)"
  try {
    $sql = Get-Content -Path $f.FullName -Raw -Encoding UTF8
    Invoke-Sql $sql | Out-Null
    Invoke-Sql ("insert into public.schema_migrations (name) values ('" + $f.Name + "');") | Out-Null
    Write-Host "[OK] $($f.Name)"
  } catch {
    Write-Host "[X] Error en $($f.Name): $($_.Exception.Message)"
    exit 1
  }
}
Write-Host '[OK] Base de datos al dia.'
exit 0
