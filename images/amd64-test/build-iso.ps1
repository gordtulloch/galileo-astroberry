param(
    [ValidateSet("stable", "nightly")]
    [string]$Channel = "stable"
)

$ErrorActionPreference = "Stop"

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$repositoryRoot = (Resolve-Path (Join-Path $scriptDirectory "..\..")).Path
$imageName = "galileo-linux-amd64-smoke-builder:local"
$dockerfile = Join-Path $scriptDirectory "Dockerfile"

docker info --format "{{.ServerVersion}}" | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Docker Engine is unavailable. Start Docker Desktop and retry."
}

docker build --platform linux/amd64 --build-arg "CHANNEL=$Channel" --tag $imageName --file $dockerfile $repositoryRoot
if ($LASTEXITCODE -ne 0) {
    throw "Failed to build the Debian ISO builder container."
}

$workspaceMount = "${repositoryRoot}:/workspace"
docker run --rm --privileged --platform linux/amd64 `
    --volume $workspaceMount `
    --workdir /workspace `
    $imageName
if ($LASTEXITCODE -ne 0) {
    throw "The ISO build or validation failed."
}
