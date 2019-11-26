function copy_sprites_spaceplane --description 'compile and copy sprite sheet for spaceplane'
	set resources ~/code/spaceplane/resources
set sheep_dir ~/code/libs/sheep
cd $sheep_dir
set asset_dir /mnt/space/media/images/workspaces/bbss/exports
cargo run pack $asset_dir/*.png --format amethyst_named
mv -fv $sheep_dir/out.ron $resources/sprites.ron
mv -fv $sheep_dir/out.png $resources/sprites.png
end
