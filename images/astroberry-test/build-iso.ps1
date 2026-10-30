#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$image = 'astroberry-amd64-smoke-builder:local'

docker build --platform linux/amd64 --tag $image --file (Join-Path $PSScriptRoot 'Dockerfile') $root
if ($LASTEXITCODE -ne 0) { throw 'Builder image build failed.' }

docker run --rm --privileged --platform linux/amd64 --volume "${root}:/workspace" --workdir /workspace $image
if ($LASTEXITCODE -ne 0) { throw 'ISO build failed.' }
