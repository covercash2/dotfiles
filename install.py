# python 3 install script
import os

home = os.environ['HOME']

home_files = ['zshenv', 'zshrc', 'emacs.d']
home_files_location = list(map(
    lambda s: home + '/.' + s,
    home_files
))

print("linking files...")
for f in home_files:
    print("linking ")
