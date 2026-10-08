# Builds the small Obsidian plugin in ./src into a plain main.js + manifest.json.
# No buildNpmPackage/package-lock needed — zod (the plugin's only runtime
# dependency, used for addMcpTool's input schemas) has zero deps of its own,
# so esbuild can bundle it directly from the fetched npm tarball.
{
  stdenvNoCC,
  fetchurl,
  esbuild,
}:

let
  zod = fetchurl {
    url = "https://registry.npmjs.org/zod/-/zod-4.6.5.tgz";
    hash = "sha256-p4wMUz3jDcHEr8JZrEOsBuOQyw2o0uMurjVTAbULNvw=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "obsidian-dataview-mcp-extension";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [ esbuild ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    mkdir -p node_modules/zod
    tar -xzf ${zod} -C node_modules/zod --strip-components=1

    esbuild src/main.ts \
      --bundle --platform=node --format=cjs \
      --external:obsidian \
      --outfile=main.js

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp main.js manifest.json $out/
    runHook postInstall
  '';
}
